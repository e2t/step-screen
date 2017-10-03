import sys
from PyQt5 import QtWidgets
sys.path.append('..')
import gui
from screen import StepScreen, calc_step_screen, FIRST_STAIR
from manifest import VERSION, DESCRIPTION
from dry.qt import get_number, msgbox, BaseMainWindow, move_cursor_to_begin
from dry.core import InputException


# Толщина стальных пластин: 0 - подвижные, 1 - неподвижные
THICKNESS_STEEL = {
    '3 + 3': (3, 3),
    '3 + 2': (2, 3),
    '2 + 2': (2, 2)
}

ORIENTAL_WIDTHS = {'%02d' % i: i * 100 + 50.0 for i in range(4, 23)}
HEIGHTS = {'%02d' % i: i * 100 + 950.0 for i in range(6, 40, 3)}
STEEL_GAPS = '3', '5', '6'


class MainWindow(BaseMainWindow, gui.Ui_Dialog):  # type: ignore
    def __init__(self) -> None:
        BaseMainWindow.__init__(self, DESCRIPTION, VERSION)

    def init_widgets(self) -> None:
        self.cmb_thickness.addItems(THICKNESS_STEEL)
        self.cmb_width_size.addItems(ORIENTAL_WIDTHS)
        self.cmb_height_size.addItems(HEIGHTS)
        self.cmb_gap.addItems(STEEL_GAPS)
        self.cmb_gap.setCurrentIndex(1)

    def connect_actions(self) -> None:
        self.btn_run.clicked.connect(self.run)

    def clear_results(self) -> None:
        self.edt_results.clear()

    def run(self) -> None:
        self.clear_results()

        thick_moving, thick_fixed = THICKNESS_STEEL[
            self.cmb_thickness.currentText()]
        ejection_height = HEIGHTS[self.cmb_height_size.currentText()]
        try:
            depth_channel = get_number(
                self.edt_depth_channel, (FIRST_STAIR, False),
                (ejection_height, False))
            gap = float(self.cmb_gap.currentText())
        except (InputException, ValueError) as err:
            msgbox(str(err))
        else:
            screen = calc_step_screen(
                oriental_ext_width=ORIENTAL_WIDTHS[
                    self.cmb_width_size.currentText()],
                ejection_height=ejection_height,
                moving_plate_thickness=thick_moving,
                fixed_plate_thickness=thick_fixed,
                gap=gap,
                depth_channel=depth_channel)
            self.output_results(screen)

    def output_results(self, screen: StepScreen) -> None:
        if screen.parameters_plates.gap_patch > 0:
            warning = ''
        else:
            warning = f' (зазор {screen.parameters_plates.gap_patch} мм)'
        self.edt_results.appendPlainText('\n'.join((
            f'Масса решетки {screen.weight:.1f} кг',
            f'Наружная ширина {screen.external_width:g} мм',
            f'Внутренняя ширина {screen.internal_width:g} мм',
            f'Высота сброса до дна {screen.ejection_height:g} мм',
            f'Высота стального полотна {screen.steel_strips_height:.0f} мм',
            '',
            f'Подвижные пластины {screen.parameters_plates.number_mov_plates} шт.',
            f'- сталь {screen.parameters_plates.thickness_mov_steel} мм, '
            f'пластик {screen.parameters_plates.thickness_mov_plastic:g} мм',
            f'Неподвижные пластины {screen.parameters_plates.number_fix_plates} шт.',
            f'- сталь {screen.parameters_plates.thickness_fix_steel} мм, '
            f'пластик {screen.parameters_plates.thickness_fix_plastic:g} мм',
            f'Шаг пластин по ширине {screen.parameters_plates.step_plates:g} мм',
            '',
            f'Толщина накладки {screen.parameters_plates.thickness_patch:g} мм{warning}',
            'Зазор между:',
            f'- пластиковыми пластинами {screen.parameters_plates.gap_plastic:g} мм',
            f'- боковиной и пластиковой пластиной {screen.parameters_plates.side_gap_plastic:g} мм',
            f'- боковиной и стальной пластиной {screen.parameters_plates.side_gap_steel:g} мм',
        )))
        move_cursor_to_begin(self.edt_results)


def main() -> None:
    app = QtWidgets.QApplication(sys.argv)
    form = MainWindow()
    form.show()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
