from math import ceil, floor

from dry.numcompar import STD_ACCURACY, is_equal

GRAV_ACC = 9.80665  # Metre/sec2


def rounddown(value: float, acc: float = STD_ACCURACY) -> int:
    nearest = round(value)
    return nearest if is_equal(nearest, value, acc) else floor(value)


def roundup(value: float, acc: float = STD_ACCURACY) -> int:
    nearest = round(value)
    return nearest if is_equal(nearest, value, acc) else ceil(value)
