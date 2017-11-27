import math
from typing import NamedTuple
import plates


class StepScreen(NamedTuple):
    weight: float
    external_width: float
    internal_width: float
    ejection_height: float
    steel_strips_height: float
    parameters_plates: plates.ParametersPlates
    moving_weight: float
    length_plastic: float


FIRST_STAIR = 169.7  # высота донной ступени
STEP_STAIR = 95.8  # шаг зубьев по вертикали
SMALL_THICKNESS_SIDEWALL = 105  # толщины боковины малых решеток
BIG_THICKNESS_SIDEWALL = 118  # толщина боковины больших решеток
WEIGHT_MOTOR = 83
WIDTH_PLASTIC_PLATE = 227


def number_steps(height: float) -> int:
    return math.ceil((height - FIRST_STAIR) / STEP_STAIR)


# Боковина.
def sidewall(ejection_height: float) -> float:
    return 0.052 * ejection_height + 29.271


# Стяжка центральная.
def buckle(internal_width: float) -> float:
    return 0.01 * internal_width + 1.0


# Стяжка задняя.
def back_buckle(internal_width: float) -> float:
    return 0.01 * internal_width + 3.0


# Перегородка нижняя.
def bottom_buckle(internal_width: float) -> float:
    return 0.012 * internal_width + 1.4


# Балка неподвижной решетки.
def fixed_balk(internal_width: float) -> float:
    return 0.012 * internal_width + 2.4


# Привод и вал в сборе.
def shaft_motor(internal_width: float) -> float:
    return 0.012 * internal_width + 8.1 + WEIGHT_MOTOR


# Кронштейн опоры.
def bracket() -> float:
    return 6.0


# Трамплин нижний.
def springboard(internal_width: float) -> float:
    return 0.004 * internal_width - 0.2


# Узел распыления.
def spraying(internal_width: float) -> float:
    return 0.002 * internal_width + 1.4


#
def slide_ways(internal_width: float) -> float:
    return 0.01 * internal_width + 7.0


# Стойка опоры.
def stand(short_ejection_height: float) -> float:
    return 0.018 * short_ejection_height + 27.92


# Балка подвижной решетки.
def moving_balk(internal_width: float) -> float:
    return 0.014 * internal_width + 0.8


# Прижимной клин решеток.
def wedge(internal_width: float) -> float:
    return 0.004 * internal_width + 1.8


# Шатун.
def connecting_wall(ejection_height: float) -> float:
    return 0.035 * ejection_height - 29.154


# Узел качания.
def triangle() -> float:
    return 3.0


# Кривошип большой.
def cranck() -> float:
    return 7.0


# Кривошип малый (плечо).
def shoulder() -> float:
    return 2.0


# Короткая тяга.
def short_rod() -> float:
    return 1.0


# Длинная тяга.
def long_rod(ejection_height: float) -> float:
    return 0.004 * ejection_height - 1.462


# Задняя крышка.
def back_cover(internal_width: float) -> float:
    return 0.006 * internal_width + 7.2


#
def slide_cover(short_ejection_height: float) -> float:
    return 0.016 * short_ejection_height + 9.04


# Нижняя крышка.
def bottom_cover(internal_width: float) -> float:
    return 0.006 * internal_width - 0.8


# Верхняя крышка.
def top_cover(internal_width: float, short_ejection_height: float) -> float:
    return (1.459e-5 * internal_width *
            short_ejection_height + 0.01653 * internal_width -
            0.00434 * short_ejection_height)


# Масса подвижной стальной пластины.
def moving_steel_strip(steps: int, moving_plate_thickness: float) -> float:
    return (0.093 * steps + 0.217) * moving_plate_thickness


# Масса неподвижной стальной платсины.
def fixed_steel_strip(steps: int, fixed_plate_thickness: float) -> float:
    return (0.092 * steps + 0.235) * fixed_plate_thickness


# Масса неподвижной пластиковой пластины.
def fix_plastic_strip(steps: int, thick: float) -> float:
    return (0.01 * steps + 0.033) * thick


# Масса подвижной пластиковой пластины.
def moving_plastic_strip(steps: int, thick: float) -> float:
    return (0.01 * steps + 0.023) * thick


# Масса дистанционной накладки.
def strip_onlay(thick: float) -> float:
    return 0.14 * thick


# Масса неподвижной решетки.
def fixed_grid(number_strips: int, thick_plastic: float,
               steel_steps: int, plastic_steps: int,
               gap: float, fixed_plate_thickness: float,
               internal_width: float) -> float:
    return (number_strips *
            fixed_steel_strip(steel_steps, fixed_plate_thickness) +
            number_strips *
            fix_plastic_strip(plastic_steps, thick_plastic) +
            number_strips * strip_onlay(gap - 1) * 2 +
            (fixed_balk(internal_width) + wedge(internal_width)) * 4)


def calc_thickness_sidewall(is_small_screen: bool) -> float:
    if is_small_screen:
        result = SMALL_THICKNESS_SIDEWALL
    else:
        result = BIG_THICKNESS_SIDEWALL
    return result


def calc_internal_width(external_width: float, is_small_screen: bool) -> float:
    return external_width - 2 * calc_thickness_sidewall(is_small_screen)


def calc_external_width(internal_width: float, is_small_screen: bool) -> float:
    return internal_width + 2 * calc_thickness_sidewall(is_small_screen)


# Масса подвижной решетки.
def moving_grid(number_strips: int, thick_plastic: float,
                steel_steps: int, plastic_steps: int,
                moving_plate_thickness: float,
                internal_width: float) -> float:
    return (number_strips *
            moving_steel_strip(steel_steps, moving_plate_thickness) +
            number_strips *
            moving_plastic_strip(plastic_steps, thick_plastic) +
            (moving_balk(internal_width) + wedge(internal_width)) * 4)


# Корректирующая добавка.
def correct(external_width: float, ejection_height: float) -> float:
    return (9.9097e-6 * external_width * ejection_height +
            0.18252 * external_width - 0.06067 * ejection_height)


# Укрупненный расчет длины пластиковых ламелей.
def calc_length_plastic(short_ejection_height: float,
                        is_small_screen: bool) -> float:
    if is_small_screen:
        length_over_cover = 490
    else:
        length_over_cover = 690
    return (short_ejection_height / math.sin(math.radians(50)) +
            length_over_cover)


def calc_step_screen(
        oriental_ext_width: float, ejection_height: float,
        moving_plate_thickness: float, fixed_plate_thickness: float,
        gap: float, depth_channel: float, is_small_screen: bool) -> StepScreen:
    parameters_plates = plates.calc_parameters_plates(
        thickness_mov_steel=moving_plate_thickness,
        thickness_fix_steel=fixed_plate_thickness,
        gap_steel=gap,
        max_width=calc_internal_width(oriental_ext_width, is_small_screen)
    )
    internal_width = parameters_plates.width
    external_width = calc_external_width(internal_width, is_small_screen)
    short_ejection_height = ejection_height - depth_channel
    steel_steps = number_steps(depth_channel)
    plastic_steps = (number_steps(ejection_height) -
                     steel_steps - 1)  # почему минус один??
    steel_strips_height = steel_steps * STEP_STAIR + FIRST_STAIR
    moving_weight = (2 * connecting_wall(ejection_height) +
                     moving_grid(parameters_plates.number_mov_plates,
                                 parameters_plates.thickness_mov_plastic,
                                 steel_steps,
                                 plastic_steps, moving_plate_thickness,
                                 internal_width))
    weight = (
        moving_weight +
        sidewall(ejection_height) * 2 + buckle(internal_width) +
        back_buckle(internal_width) + bottom_buckle(internal_width) +
        shaft_motor(internal_width) + bracket() * 2 +
        springboard(internal_width) + spraying(internal_width) +
        slide_ways(internal_width) +
        stand(short_ejection_height) * 2 +
        triangle() * 2 + cranck() * 2 +
        shoulder() * 2 + short_rod() * 2 +
        long_rod(ejection_height) * 2 + back_cover(internal_width) +
        slide_cover(short_ejection_height) * 2 + bottom_cover(internal_width) +
        top_cover(internal_width, short_ejection_height) +
        fixed_grid(parameters_plates.number_fix_plates,
                   parameters_plates.thickness_fix_plastic, steel_steps,
                   plastic_steps, gap, fixed_plate_thickness, internal_width) +
        correct(external_width, ejection_height))
    length_plastic = calc_length_plastic(short_ejection_height,
                                         is_small_screen)
    return StepScreen(
        weight=weight,
        external_width=external_width,
        internal_width=internal_width,
        ejection_height=ejection_height,
        steel_strips_height=steel_strips_height,
        parameters_plates=parameters_plates,
        moving_weight=moving_weight,
        length_plastic=length_plastic)
