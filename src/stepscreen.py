"""Расчет параметров ступенчатой решетки конструкции HUBER."""
from typing import NamedTuple, Tuple, Optional
from math import radians, sin, cos, ceil
from mypy_extensions import TypedDict
from Dry.allgui import to_mm, from_mm
from Dry.allcalc import (
    WidthSerie, HeightSerie, Mass, Distance, Power, Angle, Torque, GRAV_ACC, InputDataError)


SCREEN_WIDTH_SERIES = [WidthSerie(i) for i in range(5, 23)]
SCREEN_HEIGHT_SERIES = [HeightSerie(i) for i in range(6, 33, 3)]

# Толщина стальных пластин: 0 - подвижные (тоньше), 1 - неподвижные (толще)
THICKNESS_STEEL = ((Distance(0.003), Distance(0.003)),
                   (Distance(0.002), Distance(0.003)),
                   (Distance(0.002), Distance(0.002)))

# Покупные пластиковые листы: 0 - подвижные (тоньше), 1 - неподвижные (толще)
# Выбираются из ряда: 4, 5, 6, 8, 10, 12 мм.
THICKNESS_PLASTIC = {Distance(0.008): (Distance(0.004), Distance(0.004)),
                     Distance(0.010): (Distance(0.005), Distance(0.005)),
                     Distance(0.012): (Distance(0.006), Distance(0.006)),
                     Distance(0.014): (Distance(0.006), Distance(0.008)),
                     Distance(0.016): (Distance(0.008), Distance(0.008)),
                     Distance(0.018): (Distance(0.008), Distance(0.01))}

# Прозоры стальных пластин.
STEEL_GAPS = Distance(0.0034), Distance(0.0054), Distance(0.0064)

TEETH_XX21 = 41
DIFF_TEETH_SERIES = {33: 15,
                     30: 11,
                     27: 8,
                     24: 4,
                     21: 0,
                     18: -4,
                     15: -7,
                     12: -11,
                     9: -15,
                     6: -19}

LEVER_ARM = 0.053                             # Плечо кривошипа.
TILT_ANGLE = Angle(radians(50))               # Угол наклона решетки.
TEETH_STEP = Distance(0.105)                  # Шаг зубьев пластин.
TEETH_STEP_Y = TEETH_STEP * sin(TILT_ANGLE)   # Шаг зубьев по вертикали.
TEETH_STEP_X = TEETH_STEP * cos(TILT_ANGLE)   # Шаг зубьев по горизонтали.
BETW_DISCHARGE_AND_TOP = Distance(0.64668)    # Расстояние от сброса до верхней точки решетки.
BETW_DISCHARGE_AND_AXE_X = Distance(0.31494)  # Расстояние от края сброса до оси опоры (гориз.).
BETW_EXTREME_FIXED_BEAMS = Distance(3.795)    # Расстояние между крайними неподвижными балками.
BETW_EXTREME_MOVING_BEAMS = Distance(3.24)    # Расстояние между крайними подвижными балками.

START_DISCHARGE_FULL_HEIGHT = Distance(3.05)  # Высота сброса, H1.
START_HORIZ_LENGTH = Distance(3.09774)        # Длина в плане, D.
START_SCREEN_LENGTH = Distance(4.73198)       # Длина решетки, L.
START_AXE_HEIGHT = Distance(3.13)             # Расстояние от дна канала до оси опоры.

MIN_DISCHARGE_HEIGHT = Distance(0.66)         # Минимальная высота сброса над каналом.

# Допустимый зазор между пластиковыми пластинами.
PLASTIC_GAP = (0.0004, 0.001)


class DriveUnit(NamedTuple):
    """Основные характеристики привода."""

    name: str
    mass: Mass
    power: Power
    output_torque: Torque


DRIVE_UNITS_05XX = (
    DriveUnit('SK9022.1-80', mass=Mass(49), power=Power(750), output_torque=Torque(586)),
)


DRIVE_UNITS = (
    DriveUnit('SK32100-80', mass=Mass(67), power=Power(750), output_torque=Torque(423)),
    DriveUnit('SK32100-90', mass=Mass(73), power=Power(1500), output_torque=Torque(845)),
    DriveUnit('SK32100-100', mass=Mass(84), power=Power(2200), output_torque=Torque(1004)),
    DriveUnit('SK9032.1-100', mass=Mass(86), power=Power(2200), output_torque=Torque(1591)),
)


class InputData(NamedTuple):
    """Структура входных данных для расчета решетки."""

    screen_ws: WidthSerie     # Типоразмер решетки по ширине.
    screen_hs: HeightSerie    # Типоразмер решетки по высоте.
    main_steel_gap: Distance  # Прозор стальных пластин, м.
    fixed_steel_s: Distance   # Толщина стальной неподвижной пластины, м.
    moving_steel_s: Distance  # Толщина стальной подвижной пластины, м.
    channel_height: Distance  # Глубина канала, м.
    have_plastic_part: bool   # True - с пластиковым полотном, False - только стальные пластины.


class StepScreenMass(TypedDict):
    """Структура масс отдельных узлов решетки."""

    push_button_post: Mass  # Кнопочный пост КПС 820.000
    support: Mass  # Опора решетки на поверхность канала
    pin_sensor: Mass  # Датчик штыревой
    anchors: Mass  # 10 анкерных болтов в МЧ
    drive_support: Mass  # Узел привода (без самого привода)
    chute: Mass  # Кожух сброса
    air_supply: Mass  # Узел подачи воздуха
    stirring_up: Mass  # Узел взмучивания
    pitman_arm: Mass  # Шатун
    front_cover_00: Mass  # Передняя крышка (нижняя)
    front_cover_01: Mass  # Передняя крышка (верхняя)
    top_cover: Mass  # Верхняя крышка
    back_cover: Mass  # Задняя крышка
    top_cover_fixing_beam: Mass  # Нижняя балка крепления верхней крышки
    front_cover_00_fixing_beam: Mass  # Нижняя балка крепления передней крышки (нижней)
    front_cover_01_fixing_beam: Mass  # Нижняя балка крепления передней крышки (верхней)
    fixing_strip: Mass  # Планка крепежная
    terminal_box: Mass  # Клеммная коробка
    connecting_rod: Mass  # Подвеска (шатун)
    crank: Mass  # Кривошип
    bottom_flap: Mass  # Нижняя заслонка
    fixing_plates_clip: Mass  # Прижим неподвижных ламелей
    moving_plates_clip: Mass  # Прижим подвижных ламелей
    botton_rake: Mass  # Гребенка для крепления неподвижных пластин
    bottom_frame_beam: Mass  # Нижняя балка рамы (опора на дно канала) + муфта и ребра
    middle_frame_beam: Mass  # Средняя балка рамы (перемычка)
    top_frame_beam: Mass  # Верхняя балка рамы (крепление клеммной коробки)
    fixing_plates_beam: Mass  # Поперечная балка крепления неподвижных пластин (приварная)
    moving_plates_beam: Mass  # Поперечная балка крепления подвижных пластин
    sidewall: Mass  # Боковина (вместе с деталями рамы)
    parallelogram_beam: Mass  # Коромысло
    moving_lengthwise_beam: Mass  # Продольная балка подвижного полотна
    fixed_plate_steel_part: Mass  # Стальная часть неподвижной пластины
    fixed_plate_plastic_part: Mass  # Пластиковая часть неподвижной пластины
    moving_plate_steel_part: Mass  # Стальная часть подвижной пластины
    moving_plate_plastic_part: Mass  # Пластиковая часть подвижной пластины
    full_steel_fixed_plate: Mass  # Полностью стальная неподвижная пластина
    full_steel_moving_plate: Mass  # Полностью стальная подвижная пластина
    bottom_plate_limiter: Mass  # Нижний дистанционер (накладка)
    main_plate_limiter: Mass  # Основной дистанционер (полоса)
    side_cover: Mass  # Боковая крышка
    back_bottom_cover: Mass  # Склиз нижний (закрытое исполнение)
    hose: Mass  # Рукав подачи воздуха (резина)
    rubber_screen: Mass  # Защитный экран (резина + прижимные планки)


class StepScreen:
    """Ступенчатая решетка конструкции HUBER."""

    @property
    def full_mass(self) -> Mass:
        """Масса решетки."""
        return self._full_mass

    @property
    def moving_mass(self) -> Mass:
        """Масса подвижной части (пластины, шатуны и прочее)."""
        return self._moving_mass

    @property
    def drive_unit(self) -> Optional[DriveUnit]:
        """Привод (для стандартных типоразмеров)."""
        return self._drive_unit

    @property
    def inner_screen_width(self) -> Distance:
        """Ширина просвета решетки."""
        return self._inner_screen_width

    @property
    def description(self) -> str:
        """Обозначение решетки."""
        return self._description

    @property
    def gap(self) -> Distance:
        """Прозор стальных пластин."""
        return self._input_data.main_steel_gap

    @property
    def outer_screen_width(self) -> Distance:
        """Наружная ширина решетки."""
        return self._outer_screen_width

    @property
    def discharge_width(self) -> Distance:
        """Ширина сброса."""
        return self._discharge_width

    @property
    def discharge_height(self) -> Distance:
        """Высота сброса над каналом."""
        return self._discharge_height

    @property
    def discharge_full_height(self) -> Distance:
        """Высота сброса от дна канала."""
        return self._discharge_full_height

    @property
    def fixed_steel_s(self) -> Distance:
        """Толщина неподвижных стальных пластин."""
        return self._input_data.fixed_steel_s

    @property
    def moving_steel_s(self) -> Distance:
        """Толщина подвижных стальных пластин."""
        return self._input_data.moving_steel_s

    @property
    def start_fixed(self) -> Distance:
        """Расстояние от центра крайнего паза крайней неподвижной пластины до боковины."""
        return self._start_fixed

    @property
    def start_moving(self) -> Distance:
        """Расстояние от центра крайнего паза крайней подвижной пластины до боковины."""
        return self._start_moving

    @property
    def plates_step(self) -> Distance:
        """Шаг пластин одного полотна."""
        return self._plates_step

    @property
    def fixed_plates_number(self) -> int:
        """Количество неподвижных пластин."""
        return self._fixed_plates_number

    @property
    def moving_plates_number(self) -> int:
        """Количество подвижных пластин."""
        return self._moving_plates_number

    @property
    def side_steel_gap(self) -> Distance:
        """Зазор между боковиной и крайней стальной пластиной."""
        return self._side_steel_gap

    @property
    def have_plastic_part(self) -> bool:
        """Наличие пластикового части полотна."""
        return self._input_data.have_plastic_part

    @property
    def sum_plastic_s(self) -> Tuple[Distance, Distance]:
        """Сумма толщин пластиковых пластин."""
        return self._sum_plastic_s

    @property
    def screen_height(self) -> Distance:
        """Высота решетки."""
        return self._screen_height

    @property
    def horiz_length(self) -> Distance:
        """Длина в плане."""
        return self._horiz_length

    @property
    def axe_distance_y(self) -> Distance:
        """Высота от дна канала до оси опоры."""
        return self._axe_distance_y

    @property
    def axe_distance_x(self) -> Distance:
        """Расстояние от низа решетки до оси опоры (гориз.)."""
        return self._axe_distance_x

    @property
    def turning_radius(self) -> Distance:
        """Радиус поворота решетки."""
        return self._turning_radius

    @property
    def screen_length(self) -> Distance:
        """Длина решетки."""
        return self._screen_length

    @property
    def min_side_gap(self) -> Distance:
        """Минимальный зазор между боковиной и крайней пластиной."""
        return self._min_side_gap

    @property
    def moving_plastic_s(self) -> Optional[Distance]:
        """Толщина подвижной пластиковой пластины."""
        return self._moving_plastic_s

    @property
    def fixed_plastic_s(self) -> Optional[Distance]:
        """Толщина неподвижной пластиковой пластины."""
        return self._fixed_plastic_s

    @property
    def fixing_beam_number(self) -> int:
        """Количество неподвижных балок."""
        return self._fixing_beam_number

    @property
    def moving_beam_number(self) -> int:
        """Количество подвижных балок."""
        return self._moving_beam_number

    @property
    def min_torque(self) -> Torque:
        """Минимальный крутящий момент."""
        return self._min_torque

    @property
    def equation_file(self) -> str:
        """Файл уравнений."""
        return self._equation_file

    def __init__(self, input_data: InputData):
        """Конструктор и одновременно расчет решетки."""
        self._input_data = input_data

        self._discharge_full_height = self._calc_discharge_full_height()
        self._discharge_height = self._calc_discharge_height()
        if self._discharge_height < MIN_DISCHARGE_HEIGHT:
            raise InputDataError('Слишком глубокий канал.')

        self._outer_screen_width = self._calc_outer_screen_width()
        self._inner_screen_width = self._calc_inner_screen_width()
        self._plates_step = self._calc_plates_step()
        self._fixed_plates_number = self._calc_fixed_plates_number()
        self._moving_plates_number = self._calc_moving_plates_number()
        self._side_steel_gap = self._calc_side_steel_gap()
        self._start_fixed = self._calc_start_fixed()
        self._start_moving = self._calc_start_moving()
        self._sum_plastic_s = self._calc_sum_plastic_s()
        if self._input_data.have_plastic_part:
            self._moving_plastic_s, self._fixed_plastic_s = self._calc_plastic_s()
            self._approximate_plastic_s = self._calc_approximate_plastic_s()
            self._side_plastic_gap = self._calc_side_plastic_gap()
        else:
            self._moving_plastic_s = None
            self._fixed_plastic_s = None
        self._min_side_gap = self._calc_min_side_gap()

        self._screen_height = self._calc_screen_height()
        self._horiz_length = self._calc_horiz_length()
        self._axe_distance_y = self._calc_axe_distance_y()
        self._axe_distance_x = self._calc_axe_distance_x()
        self._turning_radius = self._calc_turning_radius()
        self._screen_length = self._calc_screen_length()
        self._discharge_width = self._calc_discharge_width()

        self._between_extreme_fixed_beams = self._calc_between_extreme_fixed_beams()
        self._between_extreme_moving_beams = self._calc_between_extreme_moving_beams()
        self._full_teeth_number = self._calc_full_teeth_number()
        self._steel_fixed_teeth_number = self._calc_steel_fixed_teeth_number()
        self._plastic_fixed_teeth_number = self._calc_plastic_fixed_teeth_number()
        self._steel_moving_teeth_number = self._calc_steel_moving_teeth_number()
        self._plastic_moving_teeth_number = self._calc_plastic_moving_teeth_number()
        self._limiters_number = self._calc_limiters_number()
        self._limiter_s = self._calc_limiter_s()
        self._fixing_beam_number = self._calc_fixing_beam_number()
        self._moving_beam_number = self._calc_moving_beam_number()
        self._mass = self._calc_mass()
        self._moving_mass = self._calc_moving_mass()
        self._min_torque = self._calc_min_torque()
        self._drive_unit = self._calc_drive_unit()
        self._full_mass = self._calc_full_mass()

        self._description = self._create_description()
        self._equation_file = self._create_equation_file()

    def _create_description(self) -> str:
        """Создание обозначения решетки (XXYY)."""
        return '{:02d}{:02d}'.format(self._input_data.screen_ws, self._input_data.screen_hs)

    def _calc_outer_screen_width(self) -> Distance:
        """Расчет наружной ширины решетки по типоразмеру ширины."""
        return Distance(self._input_data.screen_ws * 0.1 + 0.05)

    def _calc_inner_screen_width(self) -> Distance:
        """Расчет внутренней ширины (просвета) решетки по типоразмеру ширины."""
        return Distance(self._input_data.screen_ws * 0.1 - 0.07)

    def _calc_plates_step(self) -> Distance:
        """Расчет шага пластин одного полотна."""
        return Distance(self._input_data.fixed_steel_s + self._input_data.moving_steel_s
                        + 2 * self._input_data.main_steel_gap)

    def _calc_fixed_plates_number(self) -> int:
        """Расчет количества неподвижных пластин."""
        return int((self._inner_screen_width - self._input_data.moving_steel_s)
                   / self._plates_step)

    def _calc_moving_plates_number(self) -> int:
        """Расчет количества подвижных пластин."""
        return self._fixed_plates_number + 1

    def _calc_side_steel_gap(self) -> Distance:
        """Расчет зазора между боковиной и крайней стальной пластиной."""
        return Distance((self._inner_screen_width - self._input_data.moving_steel_s
                         - self._plates_step * self._fixed_plates_number) / 2)

    def _calc_start_fixed(self) -> Distance:
        """Расчет расстояния от центра крайнего паза крайней неподвижной пластины до боковины."""
        return Distance(self._side_steel_gap + self._input_data.moving_steel_s
                        + self._input_data.main_steel_gap + self._input_data.fixed_steel_s / 2)

    def _calc_start_moving(self) -> Distance:
        """Расчет расстояния от центра крайнего паза крайней подвижной пластины до боковины."""
        return Distance(self._side_steel_gap + self._input_data.moving_steel_s / 2)

    def _calc_approximate_plastic_s(self) -> Distance:
        """Расчет примерной толщины пластиковых пластин (вне стандартного ряда)."""
        return Distance((self._sum_plastic_s[0] + self._sum_plastic_s[1]) / 2)

    def _calc_sum_plastic_s(self) -> Tuple[Distance, Distance]:
        """Расчет суммы толщин пластиковых пластин."""
        return (Distance(round(self._plates_step - 2 * PLASTIC_GAP[0], 6)),
                Distance(round(self._plates_step - 2 * PLASTIC_GAP[1], 6)))

    def _calc_discharge_full_height(self) -> Distance:
        """Расчет высоты сброса до дна канала."""
        return Distance(START_DISCHARGE_FULL_HEIGHT +
                        DIFF_TEETH_SERIES[self._input_data.screen_hs] * TEETH_STEP_Y)

    def _calc_discharge_height(self) -> Distance:
        """Расчет высоты сброса до поверхности канала."""
        return Distance(self._discharge_full_height - self._input_data.channel_height)

    def _calc_screen_height(self) -> Distance:
        """Расчет высоты решетки."""
        return Distance(self._discharge_full_height + BETW_DISCHARGE_AND_TOP)

    def _calc_axe_distance_y(self) -> Distance:
        """Расчет высоты от дна канала до оси опоры."""
        return Distance(START_AXE_HEIGHT +
                        DIFF_TEETH_SERIES[self._input_data.screen_hs] * TEETH_STEP_Y)

    def _calc_horiz_length(self) -> Distance:
        """Расчет длины решетки в плане."""
        return Distance(START_HORIZ_LENGTH +
                        DIFF_TEETH_SERIES[self._input_data.screen_hs] * TEETH_STEP_X)

    def _calc_axe_distance_x(self) -> Distance:
        """Расчет расстояния от низа решетки до оси опоры (гориз.), размер F."""
        return Distance(self._horiz_length - BETW_DISCHARGE_AND_AXE_X)

    def _calc_turning_radius(self) -> Distance:
        """Расчет радиуса поворота решетки."""
        return Distance((self._axe_distance_x**2 + self._axe_distance_y**2)**0.5)

    def _calc_screen_length(self) -> Distance:
        """Расчет длины решетки."""
        return Distance(START_SCREEN_LENGTH +
                        DIFF_TEETH_SERIES[self._input_data.screen_hs] * TEETH_STEP)

    def _calc_plastic_s(self) -> Tuple[Optional[Distance], Optional[Distance]]:
        """Расчет толщин пластиковых пластин."""
        for i in THICKNESS_PLASTIC:
            if min(self._sum_plastic_s) <= i <= max(self._sum_plastic_s):
                return THICKNESS_PLASTIC[i]
        return None, None

    def _calc_side_plastic_gap(self) -> Optional[Distance]:
        """Расчет зазора между боковиной и крайней пластиковой пластиной."""
        if self._moving_plastic_s is not None:
            return Distance(round(self._start_moving - self._moving_plastic_s / 2, 6))
        return None

    def _calc_min_side_gap(self) -> Distance:
        """Расчет минимального зазора между боковиной и крайней пластиной."""
        if self._input_data.have_plastic_part and self._side_plastic_gap is not None:
            return self._side_plastic_gap
        return self._side_steel_gap

    def _calc_discharge_width(self) -> Distance:
        """Расчет ширины сброса решетки."""
        return Distance(0.1 * self._input_data.screen_ws - 0.062)

    def _calc_min_torque(self) -> Torque:
        """Расчет крутящего момента привода.

        До ноября 2020, задача Песина: (M + 200 кг) * 1.5
        Сейчас: M * 2.3
        """
        unaccounted_load = 2.3  # Коэффициент неучтенных нагрузок.
        return Torque(self._moving_mass * unaccounted_load * GRAV_ACC * LEVER_ARM)

    def _calc_drive_unit(self) -> Optional[DriveUnit]:
        """Подбор привода решетки."""

        drive_units: Tuple[DriveUnit, ...]
        if self._input_data.screen_ws <= 5:
            drive_units = DRIVE_UNITS_05XX
        else:
            drive_units = DRIVE_UNITS

        for i in drive_units:
            if i.output_torque >= self._min_torque:
                return i
        return None

    def _calc_moving_mass(self) -> Mass:
        """Расчет массы подвижной части."""
        oddments_weight = Mass(5.78)  # Остатки подвижного полотна
        mass_wo_plates = Mass(oddments_weight
                              + self._mass['fixing_strip'] * 4
                              + self._mass['pitman_arm'] * 2
                              + self._mass['moving_plates_beam'] * self._moving_beam_number
                              + self._mass['moving_plates_clip'] * self._moving_beam_number
                              + self._mass['moving_lengthwise_beam'] * 2
                              + self._mass['parallelogram_beam'] * 2
                              + self._mass['connecting_rod'] * 8)
        if self._input_data.have_plastic_part:
            return Mass(mass_wo_plates
                        + self._mass['moving_plate_steel_part'] * self._moving_plates_number
                        + self._mass['moving_plate_plastic_part'] * self._moving_plates_number)
        return Mass(mass_wo_plates
                    + self._mass['full_steel_moving_plate'] * self._moving_plates_number)

    def _calc_full_mass(self) -> Mass:
        """Расчет массы решетки."""
        oddments_weight = Mass(2.73)  # Остатки общей сборки
        if self._input_data.have_plastic_part:
            fixed_plates_mass = Mass(
                self._mass['fixed_plate_steel_part'] * self._fixed_plates_number
                + self._mass['fixed_plate_plastic_part'] * self._fixed_plates_number)
        else:
            fixed_plates_mass = Mass(
                self._mass['full_steel_fixed_plate'] * self._fixed_plates_number)
        full_mass = Mass(self._moving_mass + fixed_plates_mass + oddments_weight
                         + self._mass['push_button_post']
                         + self._mass['support'] * 2
                         + self._mass['pin_sensor']
                         + self._mass['anchors']
                         + self._mass['drive_support']
                         + self._mass['chute']
                         + self._mass['air_supply']
                         + self._mass['stirring_up'] * 2
                         + self._mass['front_cover_00']
                         + self._mass['front_cover_01']
                         + self._mass['top_cover']
                         + self._mass['back_cover']
                         + self._mass['top_cover_fixing_beam']
                         + self._mass['front_cover_00_fixing_beam']
                         + self._mass['front_cover_01_fixing_beam']
                         + self._mass['side_cover'] * 2
                         + self._mass['back_bottom_cover']
                         + self._mass['terminal_box']
                         + self._mass['crank'] * 2
                         + self._mass['bottom_flap']
                         + self._mass['botton_rake']
                         + self._mass['fixing_plates_clip'] * self._fixing_beam_number
                         + self._mass['fixing_plates_beam'] * self._fixing_beam_number
                         + self._mass['bottom_frame_beam']
                         + self._mass['middle_frame_beam']
                         + self._mass['top_frame_beam']
                         + self._mass['sidewall'] * 2
                         + self._mass['bottom_plate_limiter'] * self._fixed_plates_number * 2
                         + self._mass['main_plate_limiter'] * self._fixed_plates_number * 2
                         * self._limiters_number
                         + self._mass['hose'] * 2
                         + self._mass['rubber_screen'] * 2)
        if self._drive_unit is not None:
            full_mass = Mass(full_mass + self._drive_unit.mass)
        return full_mass

    def _calc_between_extreme_fixed_beams(self) -> Distance:
        """Расчет расстояния между крайними балками неподвижного полотна."""
        return Distance(BETW_EXTREME_FIXED_BEAMS
                        + TEETH_STEP * DIFF_TEETH_SERIES[self._input_data.screen_hs])

    def _calc_between_extreme_moving_beams(self) -> Distance:
        """Расчет расстояния между крайними балками подвижного полотна."""
        return Distance(BETW_EXTREME_MOVING_BEAMS
                        + TEETH_STEP * DIFF_TEETH_SERIES[self._input_data.screen_hs])

    def _calc_fixing_beam_number(self) -> int:
        """Расчет количества неподвижных поперечных балок."""
        beam_step = 0.8  # Примерный шаг между балками
        if self._input_data.have_plastic_part:
            return round(self._between_extreme_fixed_beams / 2 / beam_step) + 3
        return round(self._between_extreme_fixed_beams / beam_step) + 1

    def _calc_moving_beam_number(self) -> int:
        """Расчет количества подвижных поперечных балок."""
        if self._input_data.have_plastic_part:
            return 4
        return 2

    def _calc_mass_support(self) -> Mass:
        """Расчет массы опоры решетки."""
        return Mass(16.961 * self._discharge_height + 7.396)

    def _calc_mass_pin_sensor(self) -> Mass:
        """Расчет массы датчика штыревого."""
        return Mass(0.3 * self._input_data.channel_height + 0.805)

    def _calc_mass_drive_support(self) -> Mass:
        """Расчет массы узла привода (без самого привода)."""
        return Mass(3.63429 * self._input_data.screen_ws + 56.3043)

    def _calc_mass_chute(self) -> Mass:
        """Расчет массы кожуха сброса."""
        return Mass(1.02857 * self._input_data.screen_ws + 1.67857)

    def _calc_mass_air_supply(self) -> Mass:
        """Расчет массы узла подачи воздуха."""
        return Mass(0.0471429 * self._input_data.screen_ws + 2.37714)

    def _calc_mass_stirring_up(self) -> Mass:
        """Расчет массы узла взмучивания."""
        return Mass(0.115714 * self._input_data.screen_ws + 0.155714)

    def _calc_mass_front_cover_00(self) -> Mass:
        """Расчет массы передней крышки (нижней)."""
        return Mass(0.72 * self._input_data.screen_ws - 1.54)

    def _calc_mass_front_cover_01(self) -> Mass:
        """Расчет массы передней крышки (верхней)."""
        return Mass(1.12 * self._input_data.screen_ws + 0.78)

    def _calc_mass_top_cover(self) -> Mass:
        """Расчет массы верхней крышки."""
        return Mass(0.572857 * self._input_data.screen_ws + 0.802857)

    def _calc_mass_back_cover(self) -> Mass:
        """Расчет массы задней крышки."""
        return Mass(0.618571 * self._input_data.screen_ws + 0.788571)

    def _calc_mass_top_cover_fixing_beam(self) -> Mass:
        """Расчет массы нижней балки крепления верхней крышки."""
        return Mass(0.167143 * self._input_data.screen_ws + 0.167143)

    def _calc_mass_front_cover_00_fixing_beam(self) -> Mass:
        """Расчет массы нижней балки крепления передней крышки (нижней)."""
        return Mass(0.191429 * self._input_data.screen_ws + 0.211429)

    def _calc_mass_front_cover_01_fixing_beam(self) -> Mass:
        """Расчет массы нижней балки крепления передней крышки (верхней)."""
        return Mass(0.265714 * self._input_data.screen_ws + 0.155714)

    def _calc_mass_bottom_flap(self) -> Mass:
        """Расчет массы нижней заслонки."""
        return Mass(0.105714 * self._input_data.screen_ws - 0.0842857)

    def _calc_mass_fixing_plates_clip(self) -> Mass:
        """Расчет массы прижима неподвижных ламелей."""
        return Mass(0.428571 * self._input_data.screen_ws - 0.371429)

    def _calc_mass_moving_plates_clip(self) -> Mass:
        """Расчет массы прижима подвижных ламелей."""
        return Mass(0.435714 * self._input_data.screen_ws - 0.334286)

    def _calc_mass_botton_rake(self) -> Mass:
        """Расчет массы гребенки для крепления неподвижных пластин."""
        return Mass(0.175714 * self._input_data.screen_ws - 0.164286)

    def _calc_mass_bottom_frame_beam(self) -> Mass:
        """Расчет массы нижней балки рамы (опора на дно канала) + муфта и ребра."""
        coupling_mass = Mass(0.22)
        bottom_frame_beam_mass = Mass(0.405714 * self._input_data.screen_ws - 0.284286)
        return Mass(bottom_frame_beam_mass + coupling_mass)

    def _calc_mass_middle_frame_beam(self) -> Mass:
        """Расчет массы средней балки рамы (перемычка)."""
        return Mass(0.534286 * self._input_data.screen_ws - 0.365714)

    def _calc_mass_top_frame_beam(self) -> Mass:
        """Расчет массы верхней балки рамы (крепление клеммной коробки)."""
        return Mass(0.662857 * self._input_data.screen_ws + 0.0728571)

    def _calc_mass_fixing_plates_beam(self) -> Mass:
        """Расчет массы балки неподвижных пластин (приварная)."""
        return Mass(0.644286 * self._input_data.screen_ws - 0.505714)

    def _calc_mass_moving_plates_beam(self) -> Mass:
        """Расчет массы балки подвижных пластин."""
        return Mass(0.648571 * self._input_data.screen_ws + 3.34857)

    def _calc_mass_sidewall(self) -> Mass:
        """Расчет массы боковины (вместе с деталями рамы)."""
        return Mass(2.56889 * self._input_data.screen_hs + 37.32)

    def _calc_mass_parallelogram_beam(self) -> Mass:
        """Расчет массы коромысла."""
        return Mass(0.785556 * self._input_data.screen_hs + 6.39)

    def _calc_mass_moving_lengthwise_beam(self) -> Mass:
        """Расчет массы продольной балки подвижного полотна."""
        return Mass(1.15667 * self._input_data.screen_hs + 4.45)

    def _calc_mass_fixed_plate_steel_part(self) -> Mass:
        """Расчет массы стальной части неподвижной пластины."""
        return Mass(75 * self._input_data.fixed_steel_s * self._steel_fixed_teeth_number
                    + 215 * self._input_data.fixed_steel_s)

    def _calc_mass_fixed_plate_plastic_part(self) -> Mass:
        """Расчет массы пластиковой части неподвижной пластины."""
        fixed_plastic_s = self._fixed_plastic_s or self._approximate_plastic_s
        return Mass(8.88889 * fixed_plastic_s * self._plastic_fixed_teeth_number
                    + 14.4444 * fixed_plastic_s)

    def _calc_mass_moving_plate_steel_part(self) -> Mass:
        """Расчет массы стальной части подвижной пластины."""
        return Mass(73.3333 * self._input_data.moving_steel_s * self._steel_moving_teeth_number
                    + 230 * self._input_data.fixed_steel_s)

    def _calc_mass_full_steel_fixed_plate(self) -> Mass:
        """Расчет массы полностью стальной неподвижной пластины."""
        return Mass(73.3333 * self._input_data.fixed_steel_s * self._full_teeth_number
                    + 653.333 * self._input_data.fixed_steel_s)

    def _calc_mass_full_steel_moving_plate(self) -> Mass:
        """Расчет массы полностью стальной подвижной пластины."""
        return Mass(73.3333 * self._input_data.moving_steel_s * self._full_teeth_number
                    + 613.333 * self._input_data.moving_steel_s)

    def _calc_mass_moving_plate_plastic_part(self) -> Mass:
        """Расчет массы пластиковой части подвижной пластины."""
        moving_plastic_s = self._moving_plastic_s or self._approximate_plastic_s
        return Mass(6.66667 * moving_plastic_s * self._plastic_moving_teeth_number
                    + 40 * moving_plastic_s)

    def _calc_limiter_s(self) -> Distance:
        """Расчет толщины дистанционеров."""
        return from_mm(Distance(int(to_mm(self._input_data.main_steel_gap))))

    def _calc_mass_bottom_plate_limiter(self) -> Mass:
        """Расчет массы нижнего дистанционера (накладка)."""
        return Mass(110 * self._limiter_s - 0.01)

    def _calc_mass_side_cover(self) -> Mass:
        """Расчет массы боковой крышки."""
        return Mass(8.67532 * self._discharge_height + 12.498)

    def _calc_mass_main_plate_limiter(self) -> Mass:
        """Расчет массы основного дистанционера (полоса)."""
        return Mass(15 * self._limiter_s + 0.005)

    def _calc_mass_hose(self) -> Mass:
        """Расчет массы рукава подачи воздуха."""
        return Mass(0.06 * self._input_data.screen_hs + 0.27)

    def _calc_mass_rubber_screen(self) -> Mass:
        """Расчет массы зашитного экрана (резина + прижимные планки)."""
        return Mass(2.94 * self._input_data.channel_height - 0.361)

    def _calc_mass_back_bottom_cover(self) -> Mass:
        """Расчет массы нижнего склиза (закрытое исполнение)."""
        return Mass(1.53726 * self._input_data.screen_ws * self._discharge_height
                    + 0.0213454 * self._input_data.screen_ws
                    + 4.82597 * self._discharge_height - 2.0444)

    def _calc_full_teeth_number(self) -> int:
        """Подбор количества впадин зубьев на пластинах."""
        return TEETH_XX21 + DIFF_TEETH_SERIES[self._input_data.screen_hs]

    def _calc_steel_fixed_teeth_number(self) -> int:
        """Расчет количества впадин зубьев на стальных неподвижных пластинах."""
        return round(0.014 * to_mm(self._input_data.channel_height) - 5.1)

    def _calc_plastic_fixed_teeth_number(self) -> int:
        """Расчет количества впадин зубьев на пластиковых неподвижных пластинах."""
        return self._full_teeth_number - self._steel_fixed_teeth_number

    def _calc_steel_moving_teeth_number(self) -> int:
        """Расчет количества впадин зубьев на стальных подвижных пластинах."""
        return self._steel_fixed_teeth_number + 2

    def _calc_plastic_moving_teeth_number(self) -> int:
        """Расчет количества впадин зубьев на пластиковых подвижных пластинах."""
        return self._full_teeth_number - self._steel_moving_teeth_number

    def _calc_limiters_number(self) -> int:
        """Расчет количества дистанционеров на неподвижных пластинах (с одной стороны)."""
        if self._input_data.have_plastic_part:
            steel_teeth_number = self._steel_fixed_teeth_number
        else:
            steel_teeth_number = self._full_teeth_number
        return int(0.333333 * steel_teeth_number - 0.333333)

    def _calc_mass(self) -> StepScreenMass:
        """Расчет массы решетки."""
        weights: StepScreenMass = {
            'push_button_post': Mass(3.9),
            'support': self._calc_mass_support(),
            'pin_sensor': self._calc_mass_pin_sensor(),
            'anchors': Mass(2.54),
            'drive_support': self._calc_mass_drive_support(),
            'chute': self._calc_mass_chute(),
            'air_supply': self._calc_mass_air_supply(),
            'stirring_up': self._calc_mass_stirring_up(),
            'pitman_arm': Mass(24.7),
            'front_cover_00': self._calc_mass_front_cover_00(),
            'front_cover_01': self._calc_mass_front_cover_01(),
            'top_cover': self._calc_mass_top_cover(),
            'back_cover': self._calc_mass_back_cover(),
            'top_cover_fixing_beam': self._calc_mass_top_cover_fixing_beam(),
            'front_cover_00_fixing_beam': self._calc_mass_front_cover_00_fixing_beam(),
            'front_cover_01_fixing_beam': self._calc_mass_front_cover_01_fixing_beam(),
            'fixing_strip': Mass(0.35),
            'terminal_box': Mass(5.95),
            'connecting_rod': Mass(2.5),
            'crank': Mass(4.82),
            'bottom_flap': self._calc_mass_bottom_flap(),
            'fixing_plates_clip': self._calc_mass_fixing_plates_clip(),
            'moving_plates_clip': self._calc_mass_moving_plates_clip(),
            'botton_rake': self._calc_mass_botton_rake(),
            'bottom_frame_beam': self._calc_mass_bottom_frame_beam(),
            'middle_frame_beam': self._calc_mass_middle_frame_beam(),
            'top_frame_beam': self._calc_mass_top_frame_beam(),
            'fixing_plates_beam': self._calc_mass_fixing_plates_beam(),
            'moving_plates_beam': self._calc_mass_moving_plates_beam(),
            'sidewall': self._calc_mass_sidewall(),
            'parallelogram_beam': self._calc_mass_parallelogram_beam(),
            'moving_lengthwise_beam': self._calc_mass_moving_lengthwise_beam(),
            'bottom_plate_limiter': self._calc_mass_bottom_plate_limiter(),
            'main_plate_limiter': self._calc_mass_main_plate_limiter(),
            'side_cover': self._calc_mass_side_cover(),
            'back_bottom_cover': self._calc_mass_back_bottom_cover(),
            'hose': self._calc_mass_hose(),
            'rubber_screen': self._calc_mass_rubber_screen(),
            'fixed_plate_steel_part': Mass(0),
            'moving_plate_steel_part': Mass(0),
            'fixed_plate_plastic_part': Mass(0),
            'moving_plate_plastic_part': Mass(0),
            'full_steel_fixed_plate': Mass(0),
            'full_steel_moving_plate': Mass(0),
            }
        if self._input_data.have_plastic_part:
            weights['fixed_plate_steel_part'] = self._calc_mass_fixed_plate_steel_part()
            weights['fixed_plate_plastic_part'] = self._calc_mass_fixed_plate_plastic_part()
            weights['moving_plate_steel_part'] = self._calc_mass_moving_plate_steel_part()
            weights['moving_plate_plastic_part'] = self._calc_mass_moving_plate_plastic_part()
        else:
            weights['full_steel_fixed_plate'] = self._calc_mass_full_steel_fixed_plate()
            weights['full_steel_moving_plate'] = self._calc_mass_full_steel_moving_plate()
        return weights

    def _create_equation_file(self) -> str:
        # Болты крепления пластин: примерное расстояние от боковины до крайнего болта
        _pmb_approx_start = Distance(0.04)
        # Болты крепления пластин: максимальный шаг болтов
        _pmb_max_step = Distance(0.284)
        # Болты крепления пластин: округление шага болтов
        _pmb_round_base = Distance(0.01)
        # Болты крепления пластин: примерное расстояние между крайними болтами
        _pmb_approx_work_width = Distance(self._inner_screen_width - 2 * _pmb_approx_start)
        # Болты крепления пластин: дробное количестов шагов между болтами
        _pmb_float_number = _pmb_approx_work_width / _pmb_max_step
        # Болты крепления пластин: количестов шагов между болтами, округленное в меньшую сторону
        _pmb_int_number = int(_pmb_float_number)
        # Болты крепления пластин: количество болтов
        if _pmb_float_number > _pmb_int_number:
            pmb_number = _pmb_int_number + 2
        else:
            pmb_number = _pmb_int_number + 1
        # Болты крепления пластин: шаг между болтами
        pmb_step = Distance(round(_pmb_approx_work_width / (pmb_number - 1) / _pmb_round_base)
                            * _pmb_round_base)
        # Болты крепления пластин: расстояние от боковины до крайнего болта
        pmb_start = Distance((self._inner_screen_width - pmb_step * (pmb_number - 1)) / 2)

        # Болты сброса: максимальный шаг между болтами
        _dpb_max_step = Distance(0.25)
        # Болты сброса: примерное расстояние между крайними болтами
        _dpb_max_size = Distance(self._inner_screen_width - 0.045)
        # Болты сброса: количество болтов
        dpb_count = ceil(_dpb_max_size / _dpb_max_step) + 1
        # Болты сброса: шаг между болтами
        dpb_step = Distance(round(_dpb_max_size / (dpb_count - 1), 3))
        # Болты сброса: расстояние между крайними болтами
        dpb_max_size = Distance((dpb_count - 1) * dpb_step)
        # Крышка сброса: расстояние между крайними болтами
        _dpc_max_size = Distance(self._inner_screen_width - 0.103)
        # Крышка сброса: количество болтов (в длину)
        dpc_count = ceil(_dpc_max_size / 0.55) + 1
        # Крышка сброса: шаг между болтами (в длину)
        dpc_step = Distance(_dpc_max_size / (dpc_count - 1))

        result = [f'''\
"inner_width" = {to_mm(self._inner_screen_width):g}mm  'Внутренняя ширина решетки
"thickness_fixed" = {to_mm(self._input_data.fixed_steel_s):g}mm  'Толщина стальной неподвижной пластины
"thickness_moving" = {to_mm(self._input_data.moving_steel_s):g}mm  'Толщина стальной подвижной пластины
"main_gap" = {to_mm(self._input_data.main_steel_gap):g}mm  'Прозор между пластинами
"teeth_number" = {self._full_teeth_number}  'Количество зубьев пластин (для массива)''']

        if self._fixed_plastic_s is not None:
            result.append(f'''\
"plastic_fixed" = {to_mm(self._fixed_plastic_s):g}mm  'Толщина пластиковой неподвижной пластины''')

        if self._moving_plastic_s is not None:
            result.append(f'''\
"plastic_moving" = {to_mm(self._moving_plastic_s):g}mm  'Толщина пластиковой подвижной пластины''')

        result.append(f'''\
"step" = {to_mm(self._plates_step):g}mm  'Шаг между пластинами одного полотна
"number_fixed" = {self._fixed_plates_number}  'Кол-во неподвижных пластин
"number_moving" = {self._moving_plates_number}  'Кол-во подвижных пластин
"side_gap" = {to_mm(self._side_steel_gap):g}mm  'Зазор между боковиной и крайней пластиной
"start_fixed" = {to_mm(self._start_fixed):g}mm  'Расстояние от боковины до середины неподвижной пластины
"start_moving" = {to_mm(self._start_moving):g}mm  'Расстояние от боковины до середины подвижной пластины
"gap_limiter_thickness" = {to_mm(self._limiter_s):g}mm  'Толщина дистанционера пластин
"pmb_number" = {pmb_number}  'Болты крепления пластин: количество болтов
"pmb_step" = {to_mm(pmb_step):g}mm  'Болты крепления пластин: шаг между болтами
"pmb_start" = {to_mm(pmb_start):g}mm  'Болты крепления пластин: расстояние от боковины до крайнего болта
"dpb_max_size" = {to_mm(dpb_max_size):g}mm  'Болты сброса: расстояние между крайними болтами
"dpb_count" = {dpb_count}  'Болты сброса: количество болтов
"dpb_step" = {to_mm(dpb_step):g}mm  'Болты сброса: шаг между болтами
"dpc_step" = {to_mm(dpc_step):g}mm  'Крышка сброса: шаг между болтами (в длину)
"dpc_count" = {dpc_count}  'Крышка сброса: количество болтов (в длину)''')
        return '\n'.join(result)
