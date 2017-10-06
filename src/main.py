import sys
from collections import OrderedDict
from PyQt5 import QtWidgets
sys.path.append('..')
import gui
from screen import StepScreen, calc_step_screen, FIRST_STAIR
from manifest import VERSION, DESCRIPTION
from dry.qt import msgbox, BaseMainWindow, move_cursor_to_begin, \
    get_float_number
from dry.core import InputException


# Толщина стальных пластин: 0 - подвижные, 1 - неподвижные
THICKNESS_STEEL = OrderedDict({
    '3 + 3': (3, 3),
    '3 + 2': (2, 3),
    '2 + 2': (2, 2)
})

# Типоразмер по ширине : условная наружная ширина решетки
ORIENTAL_WIDTHS = OrderedDict(
    {'%02d' % i: i * 100 + 50.0 for i in range(4, 23)})
# Типоразмер по высоте : высота сброса от дна канала.
HEIGHTS = OrderedDict({'%02d' % i: i * 100 + 950.0 for i in range(6, 40, 3)})

STEEL_GAPS = '3', '5', '6'  # Прозоры стальных пластин.
MIN_SHORT_HEIGHT = 550  # Минимальная высота сброса над каналом.


def max_depth_channel(ejection_height: float) -> float:
    return ejection_height - MIN_SHORT_HEIGHT


# Расчет мощности привода для конкретной решетки.
def calc_power_drive(external_width: float, moving_weight: float) -> float:
    if moving_weight > 700:
        result = 2.2
    elif external_width > 800:
        result = 1.5
    elif moving_weight > 300:
        result = 1.5
    else:
        result = 0.75
    return result


# Выбор максильной мощности привода при разных зазорах и толщинах.
def select_max_power(oriental_ext_width: float,
                     ejection_height: float) -> float:
    depth_channel = max_depth_channel(ejection_height)
    power_drives = set()
    for moving_plate_thickness, fixed_plate_thickness in \
            THICKNESS_STEEL.values():
        for gap in (float(i) for i in STEEL_GAPS):
            screen = calc_step_screen(
                oriental_ext_width=oriental_ext_width,
                ejection_height=ejection_height,
                moving_plate_thickness=moving_plate_thickness,
                fixed_plate_thickness=fixed_plate_thickness,
                gap=gap,
                depth_channel=depth_channel)
            power = calc_power_drive(screen.external_width,
                                     screen.moving_weight)
            power_drives.add(power)
    return max(power_drives)


class MainWindow(BaseMainWindow, gui.Ui_Dialog):
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

        oriental_ext_width = ORIENTAL_WIDTHS[self.cmb_width_size.currentText()]
        moving_plate_thickness, fixed_plate_thickness = THICKNESS_STEEL[
            self.cmb_thickness.currentText()]
        ejection_height = HEIGHTS[self.cmb_height_size.currentText()]
        try:
            depth_channel = get_float_number(
                self.edt_depth_channel, (FIRST_STAIR, False),
                (max_depth_channel(ejection_height), True))
            gap = float(self.cmb_gap.currentText())
        except (InputException, ValueError) as err:
            msgbox(str(err))
        else:
            screen = calc_step_screen(
                oriental_ext_width=oriental_ext_width,
                ejection_height=ejection_height,
                moving_plate_thickness=moving_plate_thickness,
                fixed_plate_thickness=fixed_plate_thickness,
                gap=gap,
                depth_channel=depth_channel)
            power_drive = select_max_power(oriental_ext_width, ejection_height)
            self.output_results(screen, power_drive)

    def output_results(self, screen: StepScreen, power_drive: float) -> None:
        if screen.parameters_plates.gap_patch > 0:
            warning = ''
        else:
            warning = f' (зазор {screen.parameters_plates.gap_patch} мм)'
        self.edt_results.appendPlainText('\n'.join((
            f'Масса решетки {screen.weight:.0f} кг',
            f'Наружная ширина {screen.external_width:g} мм',
            f'Внутренняя ширина {screen.internal_width:g} мм',
            f'Высота сброса до дна {screen.ejection_height:g} мм',
            f'Высота стального полотна {screen.steel_strips_height:.0f} мм',
            '',
            f'Привод {power_drive} кВт',
            f'Вес подвижных частей {screen.moving_weight:.0f} кг',
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
