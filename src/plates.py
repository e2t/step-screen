import sys
sys.path.append(f'{sys.path[0]}/..')
import math
from typing import NamedTuple, Tuple, Dict
from Dry.core import nearest_even


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


# Минимальный прозор между пластиковыми ламелями.
MIN_PLASTIC_GAP = 0.5

# Максимальный прозор между пластиковыми ламелями.
MAX_PLATIC_GAP = 1

# Средний прозор между пластиковыми ламелями.
MIDDLE_PLASTIC_GAP = (MIN_PLASTIC_GAP + MAX_PLATIC_GAP) / 2

# Минимальный зазор между компенсирующей накладкой и крайней пластиковой
# ламелью.
MIN_GAP_PATCH_PLASTIC = 0.5

# Толщины пластиковых пластин: 0 - подвижные, 1 - неподвижные.
# Ключ - сумма толщин пластиковых пластин.
# Подвижная <= неподвижная.
UNEQUAL_THICKNESS_PLASTIC: Dict[float, Tuple[float, float]] = {
    14: (6, 8),
    18: (8, 10),
    22: (10, 12)
}

# Минимальное расстояние между наружной поверхностью фланца и крайней
# неподвижной пластиной.
DISTANCE_TO_FLANGE = 12


def calc_parameters_plates(
        thickness_mov_steel: float, thickness_fix_steel: float,
        gap_steel: float, max_width: float) -> ParametersPlates:

    # Шаг между пластинами на балке.
    step_plates = thickness_mov_steel + thickness_fix_steel + 2 * gap_steel

    # Определяются из файла соответствий.
    # Из опыта: пластиковые подвижные пластины лучше делать тоньше,
    # чем неподвижные, тогда меньше зазоры возле боковины.
    thickness_mov_plastic: float
    thickness_fix_plastic: float
    sum_plastic_thicknesses = nearest_even(
        step_plates - MIDDLE_PLASTIC_GAP * 2)
    if sum_plastic_thicknesses in UNEQUAL_THICKNESS_PLASTIC:
        thickness_mov_plastic, thickness_fix_plastic = \
            UNEQUAL_THICKNESS_PLASTIC[sum_plastic_thicknesses]
    else:
        thickness_mov_plastic = thickness_fix_plastic = \
            sum_plastic_thicknesses / 2

    # Количество неподвижных пластин.
    number_fix_plates = math.floor(
        (max_width - thickness_fix_plastic - 2 * DISTANCE_TO_FLANGE) /
        step_plates) + 1

    # Количество подвижных пластин.
    number_mov_plates = number_fix_plates + 1

    # Зазор между пластиковыми пластинами.
    gap_plastic = (step_plates - thickness_mov_plastic -
                   thickness_fix_plastic) / 2

    # Внутренняя ширина решетки.
    # ВНИМАНИЕ: Фактическая ширина решетки не меняется для РСК с только
    # стальными ламелями для обеспечения совместимости, а разница в зазорах
    # между крайними пластинами и накладкой остается в пределах допустимого.
    width = (step_plates * (number_fix_plates - 1) +
             thickness_fix_plastic + 2 * DISTANCE_TO_FLANGE)

    # Зазоры между боковиной и крайними пластинами.
    side_gap_plastic = (width - number_mov_plates * thickness_mov_plastic -
                        (number_mov_plates - 1) * thickness_fix_plastic - 2 *
                        (number_mov_plates - 1) * gap_plastic) / 2
    side_gap_steel = (width - number_mov_plates * thickness_mov_steel -
                      (number_mov_plates - 1) * thickness_fix_steel - 2 *
                      (number_mov_plates - 1) * gap_steel) / 2

    # Толщина компенсирующей накладки.
    thickness_patch = math.floor(side_gap_plastic - 0.5)

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
