from dry.l10n import ENG, LIT, RUS, UKR

from constants import PLASTIC, STEEL, Col


class UiText:
    WS = {
        ENG: 'Width (series):',
        UKR: 'Ширина (серія):',
        RUS: 'Ширина (серия):',
        LIT: 'Plotis (serija):'
    }

    HS = {
        ENG: 'Height (series):',
        UKR: 'Висота (серія):',
        RUS: 'Высота (серия):',
        LIT: 'Aukštis (serija):'
    }

    GAP = {
        ENG: 'Nominal gap (mm):',
        UKR: 'Номінальний прозор (мм):',
        RUS: 'Номинальный прозор (мм):',
        LIT: 'Nominalus protarpis (mm):'
    }

    DEP = {
        ENG: 'Channel or tank depth (mm):',
        UKR: 'Глибина каналу або бака (мм):',
        RUS: 'Глубина канала или бака (мм):',
        LIT: 'Kanalo arba rezervuaro gylis (mm):'
    }

    COL = {
        Col.FIXED: {
            ENG: 'Fixed',
            UKR: 'Нерухомі',
            RUS: 'Неподвижные',
            LIT: 'Nejudanti'
        },
        Col.MOVING: {
            ENG: 'Movable',
            UKR: 'Рухомі',
            RUS: 'Подвижные',
            LIT: 'Judanti'
        },
        Col.SPACER: {
            ENG: 'Spacers',
            UKR: 'Дистанційники',
            RUS: 'Дистанционеры',
            LIT: 'Tarpikliai'
        }
    }

    SPACERS = {
        STEEL: {
            ENG: 'steel',
            UKR: 'сталеві',
            RUS: 'стальные',
            LIT: 'plieniniai'
        },

        PLASTIC: {
            ENG: 'plastic',
            UKR: 'пластикові',
            RUS: 'пластиковые',
            LIT: 'plastikiniai'
        }
    }

    PLATE = {
        ENG: 'Plate thickness (mm) and spacers:',
        UKR: 'Товщина пластин (мм) та дистанційники:',
        RUS: 'Толщина пластин (мм) и дистанционеры:',
        LIT: 'Plokštės storis (mm) ir tarpikliai:'
    }

    STEELONLY = {
        ENG: 'Steel plates only',
        UKR: 'Тільки сталеві пластини',
        RUS: 'Только стальные пластины',
        LIT: 'Tik plieniniai tarpikliai'
    }

    TITLE = {
        ENG: 'RSK calculation',
        UKR: 'Розрахунок РСК',
        RUS: 'Расчет РСК',
        LIT: 'RSK skaičiavimas'
    }


class ErrorMsg:
    DEPTH = {
        ENG: 'Wrong channel depth value!',
        UKR: 'Неправильне значення глибини каналу!',
        RUS: 'Неправильное значение глубины канала!',
        LIT: 'Neteisinga kanalo gylio vertė!'
    }

    TOODEEP = {
        ENG: 'The channel is too deep! (max. {:n} mm)',
        UKR: 'Занадто глибокий канал! (макс. {:n} мм)',
        RUS: 'Слишком глубокий канал! (макс. {:n} мм)',
        LIT: 'Kanalas per gilus! (max. {:n} mm)'
    }

    NONSTD_GAP = {
        ENG: 'For plastic spacers, only gaps are possible: {}.',
        UKR: 'Для пластикових дистанційників можливі лише прозори: {}.',
        RUS: 'Для пластиковых дистанционеров возможны только прозоры: {}.',
        LIT: 'Plastikiniams tarpikliams galimi tik tarpai: {}.'
    }


def heading(text: str) -> str:
    indent = '======'
    return f'{indent} {text} {indent}'


class Output:
    RSK_GAP_DEPTH = {
        ENG: 'RSK {:02d}{:02d}, actual gap {:n} ({:n}/{:n}), '
             'depth {:n} mm',
        UKR: 'РСК {:02d}{:02d}, фактичний прозор {:n} ({:n}/{:n}), '
             'глибина {:n} мм',
        RUS: 'РСК {:02d}{:02d}, фактический прозор {:n} ({:n}/{:n}), '
             'глубина {:n} мм'
    }

    WEIGHT = {
        ENG: 'Screen weight {:n} kg',
        UKR: 'Маса решітки {:n} кг',
        RUS: 'Масса решетки {:n} кг',
    }

    DRIVELESS_WEIGHT = {
        ENG: 'Screen weight {:n} kg (without drive)',
        UKR: 'Маса решітки {:n} кг (без приводу)',
        RUS: 'Масса решетки {:n} кг (без привода)',
    }

    DRIVE = {
        ENG: 'NORD geared motor «{}»  {:n} kW; {:n} rpm; {:n} Nm',
        UKR: 'Мотор-редуктор NORD «{}»  {:n} кВт; {:n} об/хв; {:n} Нм',
        RUS: 'Мотор-редуктор NORD «{}»  {:n} кВт; {:n} об/мин; {:n} Нм',
    }

    DRIVE_UNDEF = {
        ENG: 'Undefined drive unit',
        UKR: 'Нестандартний привід',
        RUS: 'Нестандартный привод',
    }

    EXT_WIDTH = {
        ENG: 'External width, B = {:n} mm',
        UKR: 'Ширина зовнішня, B = {:n} мм',
        RUS: 'Ширина наружная, B = {:n} мм',
    }

    INT_WIDTH = {
        ENG: 'Internal width, A = {:n} mm',
        UKR: 'Ширина внутрішня, A = {:n} мм',
        RUS: 'Ширина внутренняя, A = {:n} мм',
    }

    DROP_WIDTH = {
        ENG: 'Drop width, G = {:n} mm',
        UKR: 'Ширина скидання, G = {:n} мм',
        RUS: 'Ширина сброса, G = {:n} мм',
    }

    FULL_DROP_HEIGHT = {
        ENG: 'Drop height from the channel bottom, H1 = {:n} mm',
        UKR: 'Висота скидання від дна, H1 = {:n} мм',
        RUS: 'Высота сброса от дна, H1 = {:n} мм',
    }

    DROP_HEIGHT = {
        ENG: 'Drop height from the channel top, H4 = {:n} mm',
        UKR: 'Висота скидання від підлоги, H4 = {:n} мм',
        RUS: 'Высота сброса от пола, H4 = {:n} мм',
    }

    SCR_HEIGHT = {
        ENG: 'Screen height, H2 = {:n} mm',
        UKR: 'Висота решітки, H2 = {:n} мм',
        RUS: 'Высота решетки, H2 = {:n} мм',
    }

    SCR_LENGTH = {
        ENG: 'Screen length, L = {:n} mm',
        UKR: 'Довжина решітки, L = {:n} мм',
        RUS: 'Длина решетки, L = {:n} мм',
    }

    HORIZ_LENGTH = {
        ENG: 'Horizontal length, D = {:n} mm',
        UKR: 'Довжина у плані, D = {:n} мм',
        RUS: 'Длина в плане, D = {:n} мм',
    }

    AXE_X = {
        ENG: 'Distance to axis, F = {:n} mm',
        UKR: 'Розмір до осі, F = {:n} мм',
        RUS: 'Размер до оси, F = {:n} мм',
    }

    RADIUS = {
        ENG: 'Turning radius, R = {:n} mm',
        UKR: 'Радіус повороту, R = {:n} мм',
        RUS: 'Радиус поворота, R = {:n} мм',
    }

    FOR_DESIGNER = {
        ENG: heading('For designer'),
        UKR: heading('Для конструктора'),
        RUS: heading('Для конструктора'),
    }

    MIN_SIDE_GAP = {
        ENG: 'Minimal side gap {:n} mm',
        UKR: 'Найменший боковий зазор {:n} мм',
        RUS: 'Минимальный боковой зазор {:n} мм',
    }

    PLASTIC_SPACERS = {
        ENG: 'Spacers ≈{} pcs. «{}»',
        UKR: 'Дистанційників ≈{} шт. «{}»',
        RUS: 'Дистанционеров ≈{} шт. «{}»',
    }

    STEEL_SPACERS = {
        ENG: 'Spacers ≈{} pcs. (welded)',
        UKR: 'Дистанційників ≈{} шт. (приварні)',
        RUS: 'Дистанционеров ≈{} шт. (приварные)',
    }

    MOVING_COUNT = {
        ENG: 'Moving plates {} pcs.',
        UKR: 'Рухомих пластин {} шт.',
        RUS: 'Подвижных пластин {} шт.',
    }

    STEEL_S = {
        ENG: '- steel {:n} mm',
        UKR: '- сталь {:n} мм',
        RUS: '- сталь {:n} мм',
    }

    PLASTIC_S = {
        ENG: '- plastic {:n} мм',
        UKR: '- пластик {:n} мм',
        RUS: '- пластик {:n} мм',
    }

    FIXED_COUNT = {
        ENG: 'Fixed plates {} pcs.',
        UKR: 'Нерухомих пластин {} шт.',
        RUS: 'Неподвижных пластин {} шт.',
    }

    PLASTIC_SHEET = {
        ENG: 'Polypropylene PP-C {:n} mm - {} sheets {:n}x{:n} m',
        UKR: 'Поліпропілен PP-C {:n} мм - {} лист. {:n}x{:n} м',
        RUS: 'Полипропилен PP-C {:n} мм - {} лист. {:n}x{:n} м',
    }

    MOVING_WEIGHT = {
        ENG: 'Moving part weight {:n} kg',
        UKR: 'Вага рухомих частин {:n} кг',
        RUS: 'Вес подвижных частей {:n} кг',
    }

    MIN_TORQUE = {
        ENG: 'Minimal torque {:n} Nm',
        UKR: 'Найменший обертаючий момент {:n} Нм',
        RUS: 'Минимальный крутящий момент {:n} Нм',
    }

    EQUATION_FILE = {
        ENG: heading('Equation file'),
        UKR: heading('Файл рівнянь'),
        RUS: heading('Файл уравнений'),
    }

    PLASTIC_WEIGHT = {
        ENG: 'Weight of plastic plates {:n} kg',
        UKR: 'Вага пластикових пластин {:n} кг',
        RUS: 'Вес пластиковых пластин {:n} кг',
    }
