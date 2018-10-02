import sys
from collections import OrderedDict
from typing import Tuple, Dict
from PyQt5 import QtWidgets
sys.path.append(f'{sys.path[0]}/..')
import gui
from screen import StepScreen, calc_step_screen, FIRST_STAIR
from manifest import VERSION, DESCRIPTION
from Dry.qt import msgbox, BaseMainWindow, move_cursor_to_begin, \
    get_float_number
from Dry.core import InputException


# Толщина стальных пластин: 0 - подвижные, 1 - неподвижные
THICKNESS_STEEL = OrderedDict({
    '3 + 3': (3, 3),
    '3 + 2': (2, 3),
    '2 + 2': (2, 2)
})

# Зазор на каждую сторону.
STANDARD_EACH_SIDE_GAP = 25  # СНГ
WIDE_EACH_SIDE_GAP = 10  # Европа

# Ширина пластиковых ламелей.
WIDTH_PLASTIC = 227


WidthSizes = Dict[str, float]


def sign_of_size(value: int) -> str:
    return f'{value:02d}'


def screen_size(first: int, last: int) -> WidthSizes:
    return OrderedDict({sign_of_size(i):
                        (i + 1) * 100 for i in range(first, last)})


def big_and_small_sizes(first_small: int, first_big: int, last: int) -> \
        Tuple[WidthSizes, WidthSizes]:
    return screen_size(first_small, first_big), screen_size(first_big, last)


# Малые решетки, большие решетки (по ширине).
# Малые 04-07, большие 08-22.
NARROW_CHANNELS, WIDE_CHANNELS = big_and_small_sizes(4, 8, 23)

# Типоразмер по ширине : условная наружная ширина решетки.
CHANNEL_WIDTHS: WidthSizes = OrderedDict()
CHANNEL_WIDTHS.update(NARROW_CHANNELS)
CHANNEL_WIDTHS.update(WIDE_CHANNELS)

# Высота сброса над каналом
DROP_HEIGHT_FROM_CHANNEL = 950

# Типоразмер по высоте : высота сброса от дна канала.
HEIGHTS = OrderedDict({
    sign_of_size(i): i * 100 + DROP_HEIGHT_FROM_CHANNEL for i in range(6, 40, 3)
})

# Прозоры стальных пластин.
STEEL_GAPS = 3, 5, 6

# Минимальная высота сброса над каналом.
MIN_SHORT_HEIGHT = 550


def calc_max_width(width_size: str, is_wide_screen: bool) -> float:
    if is_wide_screen:
        each_side_gap = WIDE_EACH_SIDE_GAP
    else:
        each_side_gap = STANDARD_EACH_SIDE_GAP
    return CHANNEL_WIDTHS[width_size] - 2 * each_side_gap


# Расчет мощности привода для конкретной решетки.
def calc_power_drive(moving_weight: float, is_small_screen: bool) -> float:
    if moving_weight > 700:
        return 2.2
    if not is_small_screen:
        return 1.5
    if moving_weight > 300:
        return 1.5
    return 0.75


def calc_is_small_size(wide_size: str) -> bool:
    return wide_size in NARROW_CHANNELS


# Выбор максильной мощности привода при разных зазорах и толщинах.
def select_max_power(wide_size: str, ejection_height: float,
        only_steel_strips: bool) -> float:
    depth_channel = ejection_height - MIN_SHORT_HEIGHT
    power_drives = set()
    for moving_plate_thickness, fixed_plate_thickness in \
            THICKNESS_STEEL.values():
        for gap in (float(i) for i in STEEL_GAPS):
            is_small_screen = calc_is_small_size(wide_size)
            oriental_ext_width = calc_max_width(wide_size, True)
            screen = calc_step_screen(
                oriental_ext_width=oriental_ext_width,
                ejection_height=ejection_height,
                moving_plate_thickness=moving_plate_thickness,
                fixed_plate_thickness=fixed_plate_thickness,
                gap=gap,
                depth_channel=depth_channel,
                is_small_screen=is_small_screen,
                only_steel_strips=only_steel_strips)
            power = calc_power_drive(screen.moving_weight, is_small_screen)
            power_drives.add(power)
    return max(power_drives)


class MainWindow(BaseMainWindow, gui.Ui_Dialog):
    def __init__(self) -> None:
        BaseMainWindow.__init__(self, DESCRIPTION, VERSION)

    def init_widgets(self) -> None:
        self.cmb_thickness.addItems(THICKNESS_STEEL)
        self.cmb_width_size.addItems(CHANNEL_WIDTHS)
        self.cmb_height_size.addItems(HEIGHTS)
        self.cmb_gap.addItems(str(i) for i in STEEL_GAPS)
        self.cmb_gap.setCurrentIndex(1)

    def connect_actions(self) -> None:
        self.btn_run.clicked.connect(self.run)

    def clear_results(self) -> None:
        self.edt_results.clear()

    def run(self) -> None:
        self.clear_results()

        width_size = self.cmb_width_size.currentText()
        is_wide_screen = self.rad_is_wide_width.isChecked()
        oriental_ext_width = calc_max_width(width_size, is_wide_screen)
        is_small_screen = calc_is_small_size(width_size)
        thickness_size = self.cmb_thickness.currentText()
        moving_plate_thickness, fixed_plate_thickness = \
            THICKNESS_STEEL[thickness_size]
        height_size = self.cmb_height_size.currentText()
        ejection_height = HEIGHTS[height_size]
        only_steel_strips = self.chk_only_steel_strips.isChecked()
        try:
            depth_channel = get_float_number(
                self.edt_depth_channel, (FIRST_STAIR, False),
                (ejection_height, True))
            gap = get_float_number(self.cmb_gap, (1, True), (10, True))
        except (InputException, ValueError) as err:
            msgbox(str(err))
        else:
            screen = calc_step_screen(
                oriental_ext_width=oriental_ext_width,
                ejection_height=ejection_height,
                moving_plate_thickness=moving_plate_thickness,
                fixed_plate_thickness=fixed_plate_thickness,
                gap=gap,
                depth_channel=depth_channel,
                is_small_screen=is_small_screen,
                only_steel_strips=only_steel_strips)
            if gap < min(STEEL_GAPS):
                power_drive = calc_power_drive(screen.moving_weight,
                                               is_small_screen)
            else:
                power_drive = select_max_power(width_size, ejection_height,
                                               only_steel_strips)
            mark_screen = width_size + height_size
            self.output_results(screen, power_drive, mark_screen, gap,
                                thickness_size, depth_channel, is_small_screen,
                                only_steel_strips)

    def output_results(self, screen: StepScreen, power_drive: float,
                       mark_screen: str, gap: float,
                       thickness_size: str, depth_channel: float,
                       is_small_screen: bool, only_steel_strips: bool) -> None:
        if screen.parameters_plates.gap_patch > 0:
            warning = ''
        else:
            warning = f' (зазор {screen.parameters_plates.gap_patch} мм)'
        if is_small_screen:
            small = ' (малая)'
        else:
            small = ''
        self.edt_results.appendPlainText('\n'.join((
            f'РСК {mark_screen}, прозор {gap:g}, ламели {thickness_size}, '
            f'канал {depth_channel:g}{small}',
            '',
            f'Масса решетки {screen.weight:.0f} кг',
            f'Наружная ширина {screen.external_width:g} мм',
            f'Внутренняя ширина {screen.internal_width:g} мм',
            f'Высота сброса до дна {screen.ejection_height:g} мм',
            '',
            f'Привод {power_drive} кВт',
            f'Вес подвижных частей {screen.moving_weight:.0f} кг',
            '',
            f'Подвижных пластин {screen.parameters_plates.number_mov_plates} шт.',
            f'- сталь {screen.parameters_plates.thickness_mov_steel} мм',
        )))
        if not only_steel_strips:
            self.edt_results.appendPlainText('\n'.join((
                f'- пластик {screen.length_plastic:.0f}х{WIDTH_PLASTIC}х{screen.parameters_plates.thickness_mov_plastic:g} мм',
            )))
        self.edt_results.appendPlainText('\n'.join((
            f'Неподвижных пластин {screen.parameters_plates.number_fix_plates} шт.',
            f'- сталь {screen.parameters_plates.thickness_fix_steel} мм',
        )))
        if not only_steel_strips:
            self.edt_results.appendPlainText('\n'.join((
                f'- пластик {screen.length_plastic:.0f}х{WIDTH_PLASTIC}х{screen.parameters_plates.thickness_fix_plastic:g} мм',
            )))
        self.edt_results.appendPlainText('\n'.join((
            f'Шаг пластин по ширине {screen.parameters_plates.step_plates:g} мм',
            '',
            f'Толщина накладки {screen.parameters_plates.thickness_patch:g} мм{warning}',
            'Зазор между:',
            f'- боковиной и стальной пластиной {screen.parameters_plates.side_gap_steel:g} мм',
        )))
        if not only_steel_strips:
            self.edt_results.appendPlainText('\n'.join((
                f'- боковиной и пластиковой пластиной {screen.parameters_plates.side_gap_plastic:g} мм',
                f'- пластиковыми пластинами {screen.parameters_plates.gap_plastic:g} мм',
            )))
        self.edt_results.appendPlainText('\nПластины и опоры:')
        for mm, kg in screen.steel_sheet_weight.items():
            if kg:
                self.edt_results.appendPlainText(f'- сталь {mm:.0f} мм {kg:.0f} кг')
        for mm, kg in screen.plastic_sheet_weight.items():
            if kg:
                self.edt_results.appendPlainText(f'- пластик {mm:.0f} мм {kg:.0f} кг')
        move_cursor_to_begin(self.edt_results)


def main() -> None:
    app = QtWidgets.QApplication(sys.argv)
    form = MainWindow()
    form.show()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
