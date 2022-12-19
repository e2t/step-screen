import math


def mm(value: float) -> float:
    return value / 1e3


def to_mm(m: float) -> float:
    return m * 1e3


def gram(value: float) -> float:
    return value / 1e3


def to_gram(kilogram: float) -> float:
    return kilogram * 1e3


def meter(value: float) -> float:
    return value


def kw(value: float) -> float:
    return value * 1e3


def to_kw(watt: float) -> float:
    return watt / 1e3


def nm(value: float) -> float:
    return value


def rpm(value: float) -> float:
    return value / 60


def to_rpm(rps: float) -> float:
    return rps * 60


def kg(value: float) -> float:
    return value


def degree(value: float) -> float:
    return math.radians(value)


def to_degree(rad: float) -> float:
    return math.degrees(rad)


def liter_per_sec(value: float) -> float:
    return value / 1e3
