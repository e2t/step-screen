from dataclasses import dataclass
from math import ceil, cos, floor, sin

from dry.basecalc import BaseCalc, CalcError
from dry.comparablefloat import ComparableFloat as Cf
from dry.l10n import AddMsgL10n
from dry.mathutils import GRAV_ACC
from dry.measurements import (degree, gram, kg, kw, meter, mm, nm, rpm, to_kw,
                              to_mm, to_rpm)

from captions import ErrorMsg, Output
from constants import PLASTIC, STEEL


@dataclass(frozen=True)
class HsData:
    diff_teeth: int


@dataclass(frozen=True)
class PlateAndSpacer:
    fixed: float
    moving: float
    spacer: str


@dataclass(frozen=True)
class Spacer:
    material: str
    weight: float
    designation: str
    s: float


@dataclass(frozen=True)
class Drive:
    designation: str
    weight: float
    power: float
    torque: float
    speed: float


@dataclass(frozen=True)
class InputData:
    ws: int
    hs: int
    gap: float
    depth: float
    plate_spacer: PlateAndSpacer
    steel_only: bool


@dataclass(slots=True, init=False)
class Plate:
    s: float
    teeth: int


WSDATA = range(5, 23)

HSDATA = {
    6: HsData(diff_teeth=-19),
    9: HsData(diff_teeth=-15),
    12: HsData(diff_teeth=-11),
    15: HsData(diff_teeth=-7),
    18: HsData(diff_teeth=-4),
    21: HsData(diff_teeth=0),
    24: HsData(diff_teeth=4),
    27: HsData(diff_teeth=8),
    30: HsData(diff_teeth=11),
    # 33: HsData(diff_teeth=15)
}

NOMINAL_GAPS_AND_PLASTIC_SPACERS = {
    mm(3): Spacer(material=PLASTIC,
                  weight=gram(2.56),
                  s=mm(2.7),
                  designation='RSK130921.001-01'),
    mm(6): Spacer(material=PLASTIC,
                  weight=gram(4.66),
                  s=mm(5.7),
                  designation='RSK130921.001')}

ALL_NOMINAL_GAPS = list(NOMINAL_GAPS_AND_PLASTIC_SPACERS) + [mm(5)]
ALL_NOMINAL_GAPS.sort()

PLATES_AND_SPACERS = (
    PlateAndSpacer(fixed=mm(2), moving=mm(3), spacer=PLASTIC),
    PlateAndSpacer(fixed=mm(2), moving=mm(2), spacer=PLASTIC),
    PlateAndSpacer(fixed=mm(3), moving=mm(3), spacer=STEEL),
    PlateAndSpacer(fixed=mm(3), moving=mm(2), spacer=STEEL),
    PlateAndSpacer(fixed=mm(2), moving=mm(2), spacer=STEEL)
)

# fixed=0, moving=1
DOUBLE_PLASTIC_PLATES = {
    mm(9): (mm(5), mm(4)),
    mm(10): (mm(5), mm(5)),
    mm(11): (mm(6), mm(5)),
    mm(12): (mm(6), mm(6)),
    mm(13): (mm(8), mm(5)),
    mm(14): (mm(8), mm(6)),
    mm(15): (mm(8), mm(6)),
    mm(16): (mm(8), mm(8)),
    mm(17): (mm(8), mm(8)),
    mm(18): (mm(10), mm(8))
}

SINGLE_PLASTIC_PLATES = {
    mm(7): mm(6),
    mm(8): mm(8),
    mm(9): mm(9),
    mm(12): mm(12),
    mm(13): mm(12),
    mm(14): mm(14),
    mm(15): mm(14)
}


TEETH_XX21 = 41

# Плечо кривошипа.
LEVER_ARM = mm(55)

# Шаг зубьев пластин.
TEETH_STEP = mm(105)

# Расстояние от сброса до верхней точки решетки.
BETW_DISCHARGE_AND_TOP = mm(646.68)

# Расстояние от края сброса до оси опоры (гориз.).
BETW_DISCHARGE_AND_AXE_X = mm(314.94)

# Расстояние между крайними неподвижными балками.
BETW_EXTREME_FIXED_BEAMS = meter(3.795)

# Расстояние между крайними подвижными балками.
BETW_EXTREME_MOVING_BEAMS = meter(3.24)

# Высота сброса, H1.
START_FULL_DROP_HEIGHT = meter(3.05)

# Длина в плане, D.
START_HORIZ_LENGTH = meter(3.09774)

# Длина решетки, L.
START_SCREEN_LENGTH = meter(4.73198)

# Расстояние от дна канала до оси опоры.
START_AXE_HEIGHT = meter(3.13)

# Минимальная высота сброса над каналом.
# 2023-02-17: Reduced. It used to be 660 mm.
# 2023-03-15: Enlarged. It used to be 300 mm.
MIN_DISCHARGE_HEIGHT = mm(630)

# Минимальный зазор между дистанционером и стальной пластиной.
STEEL_GAP_MIN = mm(0.36)

# Допустимый зазор между пластиковыми пластинами.
PLASTIC_GAP_MIN = STEEL_GAP_MIN

PLASTIC_GAP_MAX = mm(1.5)

# Высота пластин подвижных и неподвижных.
PLATE_HEIGHT = mm(234)

# Ширина пластиковых листов
PLASTIC_SHEET_WIDTH = meter(1.5)

# Длина пластиковых листов
PLASTIC_SHEET_LENGTH = meter(3)

PLATES_IN_SHEET = floor(PLASTIC_SHEET_WIDTH / PLATE_HEIGHT)

GAP_ACCURACY = mm(0.05)

# Угол наклона решетки.
TILT_ANGLE = degree(50)

# Шаг зубьев по вертикали.
TEETH_STEP_Y = TEETH_STEP * sin(TILT_ANGLE)

# Шаг зубьев по горизонтали.
TEETH_STEP_X = TEETH_STEP * cos(TILT_ANGLE)

# Примерный шаг между балками
FIXED_BEAM_STEP = mm(800)
MOVING_BEAM_STEP = mm(650)

DRIVE_UNITS_05XX = (Drive(designation='SK9022.1-80LP',
                          weight=kg(49),
                          power=kw(0.75),
                          torque=nm(586),
                          speed=rpm(12)),
                    Drive(designation='SK9022.1-90SP',
                          weight=kg(54),
                          power=kw(1.1),
                          torque=nm(850),
                          speed=rpm(12)))

DRIVE_UNITS = (Drive(designation='SK9032.1-80LP',
                     weight=kg(69),
                     power=kw(0.75),
                     torque=nm(562),
                     speed=rpm(13)),
               Drive(designation='SK9032.1-90SP',
                     weight=kg(73),
                     power=kw(1.1),
                     torque=nm(815),
                     speed=rpm(13)),
               Drive(designation='SK9032.1-90LP',
                     weight=kg(75),
                     power=kw(1.5),
                     torque=nm(1123),
                     speed=rpm(13)),
               Drive(designation='SK9032.1-100LP',
                     weight=kg(86),
                     power=kw(2.2),
                     torque=nm(1591),
                     speed=rpm(13)))


class StepScreen(BaseCalc):
    def __init__(self, inpdata: InputData, adderror: AddMsgL10n) -> None:
        super().__init__(adderror)

        if Cf(inpdata.depth) <= Cf(0):
            self.raise_error(ErrorMsg.DEPTH)

        self.ws = inpdata.ws
        self.hs = inpdata.hs
        self.nominal_gap = inpdata.gap
        self.depth = inpdata.depth

        self.outer_width = self.ws * 0.1 + 0.05
        self.inner_width = self.ws * 0.1 - 0.07

        if inpdata.plate_spacer.spacer == PLASTIC:
            self.optimal_gap = inpdata.gap
            try:
                self.spacer = \
                    NOMINAL_GAPS_AND_PLASTIC_SPACERS[self.nominal_gap]
            except KeyError:
                gaps = [f'{to_mm(i):n}'
                        for i in NOMINAL_GAPS_AND_PLASTIC_SPACERS]
                self.raise_error(ErrorMsg.NONSTD_GAP, ', '.join(gaps))
        else:
            self.optimal_gap = inpdata.gap + STEEL_GAP_MIN
            self.spacer = create_steel_spacer(self.nominal_gap)

        self.diff_teeth = HSDATA[self.hs].diff_teeth
        self.all_teeth = TEETH_XX21 + self.diff_teeth

        self.steel_fixed = Plate()
        self.steel_fixed.s = inpdata.plate_spacer.fixed
        self.steel_moving = Plate()
        self.steel_moving.s = inpdata.plate_spacer.moving
        self.optimal_step = \
            2 * self.optimal_gap + self.steel_fixed.s + self.steel_moving.s
        if inpdata.steel_only:
            self.steel_fixed.teeth = self.all_teeth
            self.steel_moving.teeth = self.all_teeth
            self.plastic_fixed = None
            self.plastic_moving = None
            self.moving_count, self.step = self.calc_moving_count_and_step(
                self.steel_fixed.s)
        else:
            self.steel_fixed.teeth = max(11,
                                         round(12.53 * self.depth - 3.1415))
            self.plastic_fixed = Plate()
            self.plastic_fixed.teeth = self.all_teeth - self.steel_fixed.teeth
            if self.hs < 9:
                self.steel_moving.teeth = self.all_teeth
                self.plastic_fixed.s = self.calc_single_plastic()
                self.plastic_moving = None
                self.moving_count, self.step = self.calc_moving_count_and_step(
                    self.steel_fixed.s)
            else:
                self.steel_moving.teeth = self.steel_fixed.teeth + 2
                self.plastic_moving = Plate()
                self.plastic_moving.teeth = \
                    self.all_teeth - self.steel_moving.teeth
                self.plastic_fixed.s, self.plastic_moving.s = \
                    self.calc_double_plastic()
                self.moving_count, self.step = self.calc_moving_count_and_step(
                    self.plastic_fixed.s)
        self.fixed_count = self.moving_count - 1
        self.gap = \
            (self.step - self.steel_fixed.s - self.steel_moving.s) / 2
        self.bottom_spacer_s = mm(floor(to_mm(self.gap - STEEL_GAP_MIN)))
        self.bottom_spacer_count = self.fixed_count * 2

        self.full_dropheight = START_FULL_DROP_HEIGHT + \
            self.diff_teeth * TEETH_STEP_Y
        self.dropheight = self.full_dropheight - self.depth
        if Cf(self.dropheight) < Cf(MIN_DISCHARGE_HEIGHT):
            max_depth = self.full_dropheight - MIN_DISCHARGE_HEIGHT
            self.raise_error(ErrorMsg.TOODEEP, floor(to_mm(max_depth)))

        self.side_steel_gap = self.calc_side_gap(self.steel_moving.s)
        self.fixed_start = self.side_steel_gap + self.steel_moving.s \
            + self.gap + self.steel_fixed.s / 2
        self.moving_start = self.side_steel_gap + self.steel_moving.s / 2
        if self.plastic_moving:
            side_plastic_gap = self.calc_side_gap(self.plastic_moving.s)
            self.min_side_gap = min(side_plastic_gap, self.side_steel_gap)
        else:
            self.min_side_gap = self.side_steel_gap
        self.spacer_count = \
            ((self.steel_fixed.teeth - 1) // 3) * 2 * self.fixed_count

        self.height = self.full_dropheight + BETW_DISCHARGE_AND_TOP
        self.horiz_lenght = START_HORIZ_LENGTH + self.diff_teeth * TEETH_STEP_X
        self.axe_y = START_AXE_HEIGHT + self.diff_teeth * TEETH_STEP_Y
        self.axe_x = self.horiz_lenght - BETW_DISCHARGE_AND_AXE_X
        self.raidus = float((self.axe_x**2 + self.axe_y**2)**0.5)
        self.length = START_SCREEN_LENGTH + self.diff_teeth * TEETH_STEP
        self.dropwidth = 0.1 * self.ws - 0.062
        self.betw_extremebeams_fixed = \
            BETW_EXTREME_FIXED_BEAMS + TEETH_STEP * self.diff_teeth
        self.betw_extremebeams_moving = \
            BETW_EXTREME_MOVING_BEAMS + TEETH_STEP * self.diff_teeth
        if self.plastic_fixed:
            self.beamcount_fixed = round(
                self.betw_extremebeams_fixed / FIXED_BEAM_STEP / 2) + 3
        else:
            self.beamcount_fixed = round(
                self.betw_extremebeams_fixed / FIXED_BEAM_STEP) + 1
        if self.plastic_moving:
            self.beamcount_moving = round(
                self.betw_extremebeams_moving / MOVING_BEAM_STEP / 2) + 3
        else:
            self.beamcount_moving = round(
                self.betw_extremebeams_moving / MOVING_BEAM_STEP) + 1

        self.plastic_sheet: dict[float, int] = {}
        if self.plastic_fixed:
            self.plastic_sheet[self.plastic_fixed.s] = \
                self.plastic_sheet.get(self.plastic_fixed.s, 0) \
                + self.calc_plastic_sheet(self.fixed_count)
        if self.plastic_moving:
            self.plastic_sheet[self.plastic_moving.s] = \
                self.plastic_sheet.get(self.plastic_moving.s, 0) \
                + self.calc_plastic_sheet(self.moving_count)

        self.weight = WeightSet(self)
        self.mintorque = self.calc_mintorque()
        self.drive = self.calc_drive()
        self.weight.calc_full(self)

    def calc_single_plastic(self) -> float:
        space = mm(floor(to_mm(
            self.optimal_step - self.steel_moving.s - 2 * PLASTIC_GAP_MIN)))
        plastic = SINGLE_PLASTIC_PLATES[space]
        xgap = (self.optimal_step - plastic - self.steel_moving.s) / 2
        assert Cf(xgap) <= Cf(PLASTIC_GAP_MAX)
        return plastic

    def calc_double_plastic(self) -> tuple[float, float]:
        space = mm(floor(to_mm(self.optimal_step - 2 * PLASTIC_GAP_MIN)))
        plastics = DOUBLE_PLASTIC_PLATES[space]
        xgap = (self.optimal_step - plastics[0] - plastics[1]) / 2
        assert Cf(xgap) <= Cf(PLASTIC_GAP_MAX)
        return plastics

    def calc_moving_count_and_step(self,
                                   fixed_s: float) -> tuple[int, float]:
        movcount = floor((self.inner_width + fixed_s) / self.optimal_step)
        step = (self.inner_width + fixed_s) / movcount
        return movcount, step

    def calc_side_gap(self, moving_s: float) -> float:
        return \
            (self.inner_width - moving_s - self.step * self.fixed_count) / 2

    def calc_plastic_sheet(self, plate_count: int) -> int:
        return ceil(plate_count / PLATES_IN_SHEET)

    def calc_mintorque(self) -> float:
        """До ноября 2020, задача Песина: (M + 200 кг) * 1.5
        Сейчас: M * 2.3"""
        unaccounted_load = 2.3  # Коэффициент неучтенных нагрузок
        return \
            self.weight.moving * unaccounted_load * GRAV_ACC * LEVER_ARM

    def calc_drive(self) -> Drive | None:
        drives = DRIVE_UNITS_05XX if self.ws <= 5 else DRIVE_UNITS
        for i in drives:
            if Cf(i.torque) >= Cf(self.mintorque):
                return i
        return None


def run_calc(inpdata: InputData, adderror: AddMsgL10n,
             addline: AddMsgL10n) -> None:
    try:
        scr = StepScreen(inpdata, adderror)
    except CalcError:
        return
    create_result(scr, addline)


def create_steel_spacer(gap: float) -> Spacer:
    weight = gram(13583.3333 * gap + 0.01)
    return Spacer(material=STEEL, weight=weight, s=gap, designation='')


def create_result(scr: StepScreen, addline: AddMsgL10n) -> None:
    addline(Output.RSK_GAP_DEPTH, scr.ws, scr.hs,
            round(to_mm(scr.gap), 2),
            to_mm(scr.steel_fixed.s),
            to_mm(scr.steel_moving.s),
            to_mm(scr.depth))
    if scr.drive:
        addline(Output.WEIGHT, round(scr.weight.full))
        addline(Output.DRIVE, scr.drive.designation,
                to_kw(scr.drive.power),
                to_rpm(scr.drive.speed),
                scr.drive.torque)
    else:
        addline(Output.DRIVELESS_WEIGHT, round(scr.weight.full))
        addline(Output.DRIVE_UNDEF)
    addline('')
    addline(Output.EXT_WIDTH, round(to_mm(scr.outer_width)))
    addline(Output.INT_WIDTH, round(to_mm(scr.inner_width)))
    addline(Output.DROP_WIDTH, round(to_mm(scr.dropwidth)))
    addline(Output.FULL_DROP_HEIGHT, round(to_mm(scr.full_dropheight)))
    addline(Output.DROP_HEIGHT, round(to_mm(scr.dropheight)))
    addline(Output.SCR_HEIGHT, round(to_mm(scr.height)))
    addline(Output.SCR_LENGTH, round(to_mm(scr.length)))
    addline(Output.HORIZ_LENGTH, round(to_mm(scr.horiz_lenght)))
    addline(Output.AXE_X, round(to_mm(scr.axe_x)))
    addline(Output.RADIUS, round(to_mm(scr.raidus)))
    addline('')
    addline(Output.FOR_DESIGNER)
    addline('')
    addline(Output.MIN_SIDE_GAP, round(to_mm(scr.min_side_gap), 2))
    if scr.spacer.designation:
        addline(Output.PLASTIC_SPACERS, scr.spacer_count,
                scr.spacer.designation)
    else:
        addline(Output.STEEL_SPACERS, scr.spacer_count)
    addline(Output.MOVING_COUNT, scr.moving_count)
    addline(Output.STEEL_S, to_mm(scr.steel_moving.s))
    if scr.plastic_moving:
        addline(Output.PLASTIC_S, to_mm(scr.plastic_moving.s))
    addline(Output.FIXED_COUNT, scr.fixed_count)
    addline(Output.STEEL_S, to_mm(scr.steel_fixed.s))
    if scr.plastic_fixed:
        addline(Output.PLASTIC_S, to_mm(scr.plastic_fixed.s))
    for s, count in scr.plastic_sheet.items():
        addline(Output.PLASTIC_SHEET, to_mm(s), count,
                PLASTIC_SHEET_WIDTH, PLASTIC_SHEET_LENGTH)
    addline(Output.MOVING_WEIGHT, round(scr.weight.moving))
    addline(Output.PLASTIC_WEIGHT, round(scr.weight.plastic))
    addline(Output.MIN_TORQUE, round(scr.mintorque))
    addline('')
    addline(Output.EQUATION_FILE)
    addline('')
    create_equations(scr, addline)


def create_equations(scr: StepScreen, addline: AddMsgL10n) -> None:
    # Болты крепления пластин: примерное расстояние от боковины до крайнего
    # болта
    pmb_approx_start = mm(40)
    # Болты крепления пластин: максимальный шаг болтов
    pmb_max_step = mm(284)
    # Болты сброса: максимальный шаг между болтами
    dpb_max_step = mm(250)
    # Болты крепления пластин: примерное расстояние между крайними болтами
    pmb_approx_work_width = scr.inner_width - 2 * pmb_approx_start
    # Болты крепления пластин: дробное количестов шагов между болтами
    pmb_float_number = pmb_approx_work_width / pmb_max_step
    # Болты крепления пластин: количестов шагов между болтами, округленное
    # в меньшую сторону
    pmb_int_number = floor(pmb_float_number)
    # Болты крепления пластин: количество болтов
    if Cf(pmb_float_number) > Cf(pmb_int_number):
        pmb_number = pmb_int_number + 2
    else:
        pmb_number = pmb_int_number + 1
    # Болты крепления пластин: шаг между болтами
    pmb_step = round(pmb_approx_work_width / (pmb_number - 1), 2)
    # Болты крепления пластин: расстояние от боковины до крайнего болта
    pmb_start = (scr.inner_width - pmb_step * (pmb_number - 1)) / 2

    # Болты сброса: примерное расстояние между крайними болтами
    dpb_max_size = scr.inner_width - mm(45)
    # Болты сброса: количество болтов
    dpb_count = ceil(dpb_max_size / dpb_max_step) + 1
    # Болты сброса: шаг между болтами
    dpb_step = round(dpb_max_size / (dpb_count - 1), 3)
    # Болты сброса: расстояние между крайними болтами
    dpb_max_size = (dpb_count - 1) * dpb_step

    # Крышка сброса: расстояние между крайними болтами
    dpc_max_size = scr.inner_width - mm(103)
    # Крышка сброса: количество болтов (в длину)
    dpc_count = ceil(dpc_max_size / 0.55) + 1
    # Крышка сброса: шаг между болтами (в длину)
    dpc_step = dpc_max_size / (dpc_count - 1)

    # Окно сброса: ширина перемычки между окнами на бункере сброса
    dpw_bridge = mm(100)
    # Окно сброса: количество окон
    dpw_count = 1 if scr.ws <= 12 else 2
    # Окно сброса: ширина окна
    dpw_width = (scr.inner_width - 2 * mm(55) - dpw_bridge * (dpw_count - 1)) \
        / dpw_count
    # Окно сброса: шаг окон
    dpw_step = dpw_width + dpw_bridge

    addline('"inner_width" = {:g}mm  '
            "''Внутрішня ширина решітки",
            to_mm(scr.inner_width))

    addline('"thickness_fixed" = {:g}mm  '
            "''Товщина сталевої нерухомої пластини",
            to_mm(scr.steel_fixed.s))

    addline('"thickness_moving" = {:g}mm  '
            "''Товщина сталевої рухомої пластини",
            to_mm(scr.steel_moving.s))

    addline('"main_gap" = {:.3f}mm  '
            "''Прозор між пластинами",
            to_mm(scr.gap))

    addline('"teeth_number" = {}  '
            "''Кількість зубів пластин (для масиву)",
            scr.all_teeth)

    if scr.plastic_fixed:
        addline('"plastic_fixed" = {:g}mm  '
                "''Товщина пластикової нерухомої пластини",
                to_mm(scr.plastic_fixed.s))

    if scr.plastic_moving:
        addline('"plastic_moving" = {:g}mm  '
                "''Товщина пластикової рухомої пластини",
                to_mm(scr.plastic_moving.s))

    addline('"step" = {:.3f}mm  '
            "''Крок між пластинами одного полотна",
            to_mm(scr.step))

    addline('"number_fixed" = {}  '
            "''Кількість нерухомих пластин",
            scr.fixed_count)

    addline('"number_moving" = {}  '
            "''Кількість рухомих пластин",
            scr.moving_count)

    addline('"side_gap" = {:.3f}mm  '
            "''Зазор між боковиною та крайньою пластиною",
            to_mm(scr.side_steel_gap))

    addline('"start_fixed" = {:.3f}mm  '
            "''Відстань від боковини до середини нерухомої пластини",
            to_mm(scr.fixed_start))

    addline('"start_moving" = {:.3f}mm  '
            "''Відстань від боковини до середини рухомої пластини",
            to_mm(scr.moving_start))

    if not scr.spacer.designation:
        addline('"gap_limiter_thickness" = {:g}mm  '
                "''Товщина дистанційника пластин",
                to_mm(scr.spacer.s))

    addline('"bottom_spacer_thickness" = {:g}mm  '
            "''Товщина нижнього дистанційника",
            to_mm(scr.bottom_spacer_s))

    addline('"pmb_number" = {}  '
            "''Болти кріплення пластин: кількість болтів",
            pmb_number)

    addline('"pmb_step" = {:g}mm  '
            "''Болти кріплення пластин: крок між болтами",
            to_mm(pmb_step))

    addline('"pmb_start" = {:g}mm  '
            "''Болти кріплення пластин: "
            'відстань від боковини до крайнього болта',
            to_mm(pmb_start))

    addline('"dpb_max_size" = {:g}mm  '
            "''Болти скидання: відстань між крайніми болтами",
            to_mm(dpb_max_size))

    addline('"dpb_count" = {}  '
            "''Болти скидання: кількість болтів",
            dpb_count)

    addline('"dpb_step" = {:g}mm  '
            "''Болти скидання: крок між болтами",
            to_mm(dpb_step))

    addline('"dpc_step" = {:g}mm  '
            "''Кришка скидання: крок між болтами (завдовжки)",
            to_mm(dpc_step))

    addline('"dpc_count" = {}  '
            "''Кришка скидання: кількість болтів (завдовжки)",
            dpc_count)

    addline('"dpw_width" = {:g}mm  '
            "''Вікно скидання: ширина вікна",
            to_mm(dpw_width))

    addline('"dpw_step" = {:g}mm  '
            "''Вікно скидання: крок вікон",
            to_mm(dpw_step))

    addline('"dpw_count" = {}  '
            "''Вікно скидання: кількість вікон",
            dpw_count)


class WeightSet:
    def __init__(self, scr: StepScreen):
        self.button_post = kg(3.9)
        self.support = 16.961 * scr.dropheight + 7.396
        self.pinsensor = 0.3 * scr.depth + 0.805
        self.anchors = kg(2.54)
        self.drive_support = 3.63429 * scr.ws + 56.3043
        self.chute = 1.02857 * scr.ws + 1.67857
        self.airsupply = 0.0471429 * scr.ws + 2.37714
        self.stirring_up = 0.115714 * scr.ws + 0.155714
        self.pitman_arm = kg(24.7)
        self.front_cover00 = 0.72 * scr.ws - 1.54
        self.front_cover01 = 1.12 * scr.ws + 0.78
        self.topcover = 0.572857 * scr.ws + 0.802857
        self.backcover = 0.618571 * scr.ws + 0.788571
        self.topcover_fixedbeam = 0.167143 * scr.ws \
            + 0.167143
        self.front_cover00_fixedbeam = 0.191429 * scr.ws \
            + 0.211429
        self.front_cover01_fixedbeam = 0.265714 * scr.ws \
            + 0.155714
        self.fixing_strip = kg(0.35)
        self.terminalbox = kg(5.95)
        self.connectingrod = kg(2.5)
        self.crank = kg(4.82)
        self.bottomflap = 0.105714 * scr.ws - 0.0842857
        self.plateclip_fixed = 0.428571 * scr.ws \
            - 0.371429
        self.plateclip_moving = 0.435714 * scr.ws \
            - 0.334286
        self.bottonrake = 0.175714 * scr.ws - 0.164286
        self.bottom_framebeam = 0.405714 * scr.ws \
            - 0.064286
        self.middle_framebeam = 0.534286 * scr.ws \
            - 0.365714
        self.top_framebeam = 0.662857 * scr.ws \
            + 0.0728571
        self.platebeam_fixed = 0.644286 * scr.ws \
            - 0.505714
        self.platebeam_moving = 0.648571 * scr.ws \
            + 3.34857
        self.sidewall = 2.56889 * scr.hs + 37.32
        self.parallelogram_beam = 0.785556 * scr.hs \
            + 6.39
        self.moving_lengthwise_beam = 1.15667 * scr.hs \
            + 4.45
        self.sidecover = 8.67532 * scr.dropheight \
            + 12.498
        self.bottom_spacer = 110 * scr.bottom_spacer_s \
            - 0.01
        self.backbottomcover = 1.53726 * scr.ws * scr.dropheight \
            + 0.0213454 * scr.ws \
            + 4.82597 * scr.dropheight - 2.0444
        self.hose = 0.06 * scr.hs + 0.27
        self.rubberscreen = 2.94 * scr.depth - 0.361

        self.plastic_fixed: float | None
        if scr.plastic_fixed:
            self.steel_fixed = 75 * scr.steel_fixed.s \
                * scr.steel_fixed.teeth + 215 * scr.steel_fixed.s
            self.plastic_fixed = 8.88889 * scr.plastic_fixed.s \
                * scr.plastic_fixed.teeth \
                + 14.4444 * scr.plastic_fixed.s
            fixpl = self.steel_fixed + self.plastic_fixed
        else:
            self.steel_fixed = 73.3333 * scr.steel_fixed.s \
                * scr.steel_fixed.teeth \
                + 653.333 * scr.steel_fixed.s
            self.plastic_fixed = None
            fixpl = self.steel_fixed
        self.fixed_plates = scr.fixed_count * fixpl + scr.spacer_count \
            * scr.spacer.weight + self.bottom_spacer * scr.bottom_spacer_count

        self.plastic_moving: float | None
        if scr.plastic_moving:
            self.steel_moving = 73.3333 * scr.steel_moving.s \
                * scr.steel_moving.teeth + 230 * scr.steel_moving.s
            self.plastic_moving = 6.66667 * scr.plastic_moving.s \
                * scr.plastic_moving.teeth + 40 * scr.plastic_moving.s
            movpl = self.steel_moving + self.plastic_moving
        else:
            self.steel_moving = 73.3333 * scr.steel_moving.s \
                * scr.steel_moving.teeth \
                + 613.333 * scr.steel_moving.s
            self.plastic_moving = None
            movpl = self.steel_moving
        self.moving_plates = scr.moving_count * movpl

        self.plastic = .0
        if self.plastic_fixed:
            self.plastic += self.plastic_fixed * scr.fixed_count
        if self.plastic_moving:
            self.plastic += self.plastic_moving * scr.moving_count

        self.moving = self.moving_plates + kg(5.78) \
            + self.fixing_strip * 4 \
            + self.pitman_arm * 2 \
            + self.platebeam_moving * scr.beamcount_moving \
            + self.plateclip_moving * scr.beamcount_moving \
            + self.moving_lengthwise_beam * 2 \
            + self.parallelogram_beam * 2 \
            + self.connectingrod * 8

        # After calc_full()
        self.full: float
        self.plateless: float

    def calc_full(self, scr: StepScreen) -> None:
        self.full = self.moving + self.fixed_plates + kg(2.73) \
            + self.button_post \
            + self.support * 2 \
            + self.pinsensor \
            + self.anchors \
            + self.drive_support \
            + self.chute \
            + self.airsupply \
            + self.stirring_up * 2 \
            + self.front_cover00 \
            + self.front_cover01 \
            + self.topcover \
            + self.backcover \
            + self.topcover_fixedbeam \
            + self.front_cover00_fixedbeam \
            + self.front_cover01_fixedbeam \
            + self.sidecover * 2 \
            + self.backbottomcover \
            + self.terminalbox \
            + self.crank * 2 \
            + self.bottomflap \
            + self.bottonrake \
            + self.plateclip_fixed * scr.beamcount_fixed \
            + self.platebeam_fixed * scr.beamcount_fixed \
            + self.bottom_framebeam \
            + self.middle_framebeam \
            + self.top_framebeam \
            + self.sidewall * 2 \
            + self.hose * 2 \
            + self.rubberscreen * 2
        if scr.drive:
            self.full += scr.drive.weight
        self.plateless = self.full - self.fixed_plates - self.moving_plates
