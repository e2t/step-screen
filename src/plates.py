import math
from typing import NamedTuple


class ParametersPlates(NamedTuple):
    thickness_fix_plastic: float
    thickness_mov_plastic: float
    thickness_fix_steel: float
    thickness_mov_steel: float
    step_plates: float
    number_mov_plates: int
    number_fix_plates: int
    gap_plastic: float
    width: float
    side_gap_plastic: float
    side_gap_steel: float
    thickness_patch: float
    gap_patch: float


# Толщины пластиковых пластин: 0 - подвижные, 1 - неподвижные.
# Ключ = f'{thickness_steel_mov + thickness_steel_fix}{gap_steel}'
THICKNESS_PLASTIC = {
    '43': (4, 4),
    '45': (6, 6),
    '46': (6, 8),
    '53': (5, 5),
    '55': (6, 8),
    '56': (8, 8),
    '63': (5, 5),
    '65': (6, 8),
    '66': (8, 8)
}

# Минимальное расстояние между наружной поверхностью фланца и неподвижной
# пластиковой пластиной.
DISTANCE_TO_FLANGE = 12


# Ближайшее нечетное целое.
def nearest_odd(number: float) -> int:
    result = round(number)
    if result % 2 == 0:
        result += int(math.copysign(1, number - result))
    return result


def calc_parameters_plates(
        thickness_mov_steel: float, thickness_fix_steel: float,
        gap_steel: float, oriental_width: float) -> ParametersPlates:

    # Определяются из файла соответствий.
    # Из опыта: пластиковые подвижные пластины лучше делать тоньше,
    # чем неподвижные, тогда меньше зазоры возле боковины.
    thickness_mov_plastic, thickness_fix_plastic = THICKNESS_PLASTIC[
        f'{thickness_mov_steel + thickness_fix_steel:g}{gap_steel:g}'
    ]

    # Шаг между пластинами на балке.
    step_plates = thickness_mov_steel + thickness_fix_steel + 2 * gap_steel

    # Количество подвижных пластин (только нечетное).
    number_mov_plates = nearest_odd((oriental_width - thickness_fix_plastic -
                                     2 * DISTANCE_TO_FLANGE) / step_plates + 2)

    # Количество неподвижных пластин (только четное).
    number_fix_plates = number_mov_plates - 1

    # Зазор между пластиковыми пластинами.
    gap_plastic = (step_plates - thickness_mov_plastic -
                   thickness_fix_plastic) / 2

    # Внутренняя ширина решетки.
    width = step_plates * (number_mov_plates - 2) + \
        thickness_fix_plastic + 2 * DISTANCE_TO_FLANGE

    # Зазоры между боковиной и крайними пластинами.
    side_gap_plastic = (width - number_mov_plates * thickness_mov_plastic -
                        (number_mov_plates - 1) * thickness_fix_plastic - 2 *
                        (number_mov_plates - 1) * gap_plastic) / 2
    side_gap_steel = (width - number_mov_plates * thickness_mov_steel -
                      (number_mov_plates - 1) * thickness_fix_steel - 2 *
                      (number_mov_plates - 1) * gap_steel) / 2

    # Толщина компенсирующей накладки.
    thickness_patch = math.ceil(side_gap_steel - gap_steel / 2)

    # Зазор между компенсирующей накладкой и крайней пластиковой пластиной
    gap_patch = side_gap_plastic - thickness_patch

    return ParametersPlates(
        thickness_fix_plastic=thickness_fix_plastic,
        thickness_mov_plastic=thickness_mov_plastic,
        thickness_fix_steel=thickness_fix_steel,
        thickness_mov_steel=thickness_mov_steel,
        step_plates=step_plates,
        number_mov_plates=number_mov_plates,
        number_fix_plates=number_fix_plates,
        gap_plastic=gap_plastic,
        width=width,
        side_gap_plastic=side_gap_plastic,
        side_gap_steel=side_gap_steel,
        thickness_patch=thickness_patch,
        gap_patch=gap_patch)
