from dry.l10n import ENG, LIT, RUS, UKR

from constants import PLASTIC, STEEL


class UiText:
    WS = {
        ENG: "Width (series):",
        UKR: "Ширина (серія):",
        RUS: "Ширина (серия):",
        LIT: "Plotis (serija):"
    }

    HS = {
        ENG: "Height (series):",
        UKR: "Висота (серія):",
        RUS: "Высота (серия):",
        LIT: "Aukštis (serija):"
    }

    GAP = {
        ENG: "Nominal gap (mm):",
        UKR: "Номінальний прозор (мм):",
        RUS: "Номинальный прозор (мм):",
        LIT: "Nominalus protarpis (mm):"
    }

    DEP = {
        ENG: "Channel or tank depth (mm):",
        UKR: "Глибина каналу або бака (мм):",
        RUS: "Глубина канала или бака (мм):",
        LIT: "Kanalo arba rezervuaro gylis (mm):"
    }

    FIXED = {
        ENG: "Fixed",
        UKR: "Нерухомі",
        RUS: "Неподвижные",
        LIT: "Nejudanti"
    }

    MOVING = {
        ENG: "Movable",
        UKR: "Рухомі",
        RUS: "Подвижные",
        LIT: "Judanti"
    }

    LIMITERS = {
        ENG: "Spacers",
        UKR: "Дистанційники",
        RUS: "Дистанционеры",
        LIT: "Tarpikliai"
    }

    SPACERS = {
        STEEL: {
            ENG: "steel",
            UKR: "сталеві",
            RUS: "стальные",
            LIT: "plieniniai"
        },

        PLASTIC: {
            ENG: "plastic",
            UKR: "пластикові",
            RUS: "пластиковые",
            LIT: "plastikiniai"
        }
    }

    PLATE = {
        ENG: "Plate thickness (mm) and spacers:",
        UKR: "Товщина пластин (мм) та дистанційники:",
        RUS: "Толщина пластин (мм) и дистанционеры:",
        LIT: "Plokštės storis (mm) ir tarpikliai:"
    }

    STEELONLY = {
        ENG: "Steel plates only",
        UKR: "Тільки сталеві пластини",
        RUS: "Только стальные пластины",
        LIT: "Tik plieniniai tarpikliai"
    }

    TITLE = {
        ENG: "RSK calculation",
        UKR: "Розрахунок РСК",
        RUS: "Расчет РСК",
        LIT: "RSK skaičiavimas"
    }


class ErrorMsg:
    DEPTH = {
        ENG: "Wrong channel depth value!",
        UKR: "Неправильне значення глибини каналу!",
        RUS: "Неправильное значение глубины канала!",
        LIT: "Neteisinga kanalo gylio vertė!"
    }

    TOODEEP = {
        ENG: "The channel is too deep! (max. {:g} mm)",
        UKR: "Занадто глибокий канал! (макс. {:g} мм)",
        RUS: "Слишком глубокий канал! (макс. {:g} мм)",
        LIT: "Kanalas per gilus! (max. {:g} mm)"
    }


def heading(text: str) -> str:
    indent = "======"
    return f"{indent} {text} {indent}"


class Output:
    RSK_GAP_DEPTH = {
        ENG: "RSK {:02d}{:02d}, actual gap {:.2f} ({:g}/{:g}), "
             "depth {:g} mm",
        UKR: "РСК {:02d}{:02d}, фактичний прозор {:.2f} ({:g}/{:g}), "
             "глибина {:g} мм",
        RUS: "РСК {:02d}{:02d}, фактический прозор {:.2f} ({:g}/{:g}), "
             "глубина {:g} мм"
    }

    WEIGHT = {
        ENG: "Screen weight {:.0f} kg",
        UKR: "Маса решітки {:.0f} кг",
        RUS: "Масса решетки {:.0f} кг",
    }

    DRIVELESS_WEIGHT = {
        ENG: "Screen weight {:.0f} kg (without drive)",
        UKR: "Маса решітки {:.0f} кг (без приводу)",
        RUS: "Масса решетки {:.0f} кг (без привода)",
    }

    DRIVE = {
        ENG: "Drive unit «{}»  {:g} kW; {:g} rpm; {:g} Nm",
        UKR: "Привід «{}»  {:g} кВт; {:g} об/хв; {:g} Нм",
        RUS: "Привод «{}»  {:g} кВт; {:g} об/мин; {:g} Нм",
    }

    DRIVE_UNDEF = {
        ENG: "Undefined drive unit",
        UKR: "Нестандартний привід",
        RUS: "Нестандартный привод",
    }

    EXT_WIDTH = {
        ENG: "External width, B = {:.0f} mm",
        UKR: "Ширина зовнішня, B = {:.0f} мм",
        RUS: "Ширина наружная, B = {:.0f} мм",
    }

    INT_WIDTH = {
        ENG: "Internal width, A = {:.0f} mm",
        UKR: "Ширина внутрішня, A = {:.0f} мм",
        RUS: "Ширина внутренняя, A = {:.0f} мм",
    }

    DROP_WIDTH = {
        ENG: "Drop width, G = {:.0f} mm",
        UKR: "Ширина скидання, G = {:.0f} мм",
        RUS: "Ширина сброса, G = {:.0f} мм",
    }

    FULL_DROP_HEIGHT = {
        ENG: "Drop height from the channel bottom, H1 = {:.0f} mm",
        UKR: "Висота скидання від дна, H1 = {:.0f} мм",
        RUS: "Высота сброса от дна, H1 = {:.0f} мм",
    }

    DROP_HEIGHT = {
        ENG: "Drop height from the channel top, H4 = {:.0f} mm",
        UKR: "Висота скидання від підлоги, H4 = {:.0f} мм",
        RUS: "Высота сброса от пола, H4 = {:.0f} мм",
    }

    SCR_HEIGHT = {
        ENG: "Screen height, H2 = {:.0f} mm",
        UKR: "Висота решітки, H2 = {:.0f} мм",
        RUS: "Высота решетки, H2 = {:.0f} мм",
    }

    SCR_LENGTH = {
        ENG: "Screen length, L = {:.0f} mm",
        UKR: "Довжина решітки, L = {:.0f} мм",
        RUS: "Длина решетки, L = {:.0f} мм",
    }

    HORIZ_LENGTH = {
        ENG: "Horizontal length, D = {:.0f} mm",
        UKR: "Довжина у плані, D = {:.0f} мм",
        RUS: "Длина в плане, D = {:.0f} мм",
    }

    AXE_X = {
        ENG: "Distance to axis, F = {:.0f} mm",
        UKR: "Розмір до осі, F = {:.0f} мм",
        RUS: "Размер до оси, F = {:.0f} мм",
    }

    RADIUS = {
        ENG: "Turning radius, R = {:.0f} mm",
        UKR: "Радіус повороту, R = {:.0f} мм",
        RUS: "Радиус поворота, R = {:.0f} мм",
    }

    FOR_DESIGNER = {
        ENG: heading("For designer"),
        UKR: heading("Для конструктора"),
        RUS: heading("Для конструктора"),
    }

    MIN_SIDE_GAP = {
        ENG: "Minimal side gap {:.2f} mm",
        UKR: "Найменший боковий зазор {:.2f} мм",
        RUS: "Минимальный боковой зазор {:.2f} мм",
    }

    PLASTIC_SPACERS = {
        ENG: "Spacers ≈{} pcs. «{}»",
        UKR: "Дистанційників ≈{} шт. «{}»",
        RUS: "Дистанционеров ≈{} шт. «{}»",
    }

    STEEL_SPACERS = {
        ENG: "Spacers ≈{} pcs. (welded)",
        UKR: "Дистанційників ≈{} шт. (приварні)",
        RUS: "Дистанционеров ≈{} шт. (приварные)",
    }

    MOVING_COUNT = {
        ENG: "Moving plates {} pcs.",
        UKR: "Рухомих пластин {} шт.",
        RUS: "Подвижных пластин {} шт.",
    }

    STEEL_S = {
        ENG: "- steel {:g} mm",
        UKR: "- сталь {:g} мм",
        RUS: "- сталь {:g} мм",
    }

    PLASTIC_S = {
        ENG: "- plastic {:g} мм",
        UKR: "- пластик {:g} мм",
        RUS: "- пластик {:g} мм",
    }

    FIXED_COUNT = {
        ENG: "Fixed plates {} pcs.",
        UKR: "Нерухомих пластин {} шт.",
        RUS: "Неподвижных пластин {} шт.",
    }

    PLASTIC_SHEET = {
        ENG: "Polypropylene PP-C {:g} mm - {} sheets {:.1f}x{:.1f}",
        UKR: "Поліпропілен PP-C {:g} мм - {} лист. {:.1f}x{:.1f}",
        RUS: "Полипропилен PP-C {:g} мм - {} лист. {:.1f}x{:.1f}",
    }

    MOVING_WEIGHT = {
        ENG: "Moving part weight {:.0f} kg",
        UKR: "Вага рухомих частин {:.0f} кг",
        RUS: "Вес подвижных частей {:.0f} кг",
    }

    MIN_TORQUE = {
        ENG: "Minimal torque {:.0f} Nm",
        UKR: "Найменший обертаючий момент {:.0f} Нм",
        RUS: "Минимальный крутящий момент {:.0f} Нм",
    }

    EQUATION_FILE = {
        ENG: heading("Equation file"),
        UKR: heading("Файл рівнянь"),
        RUS: heading("Файл уравнений"),
    }
