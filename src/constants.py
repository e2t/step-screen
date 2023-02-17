from enum import StrEnum, auto, unique

STEEL = 'steel'
PLASTIC = 'plastic'


@unique
class Col(StrEnum):
    FIXED = auto()
    MOVING = auto()
    SPACER = auto()
