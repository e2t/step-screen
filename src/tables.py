"""Создание сводных таблиц параметров ступенчатой решетки."""
import locale
from datetime import date
from docx import Document
from docx.shared import Cm
from docx.enum.section import WD_ORIENT
from stepscreen import (
    StepScreen, SCREEN_WIDTH_SERIES, SCREEN_HEIGHT_SERIES, InputData, START_DISCHARGE_FULL_HEIGHT,
    DIFF_TEETH_SERIES, TEETH_STEP_Y, THICKNESS_STEEL, STEEL_GAPS)
from dry.allgui import fstr, to_kw, to_mm
locale.setlocale(locale.LC_NUMERIC, '')


DISCHARGE_FULL_HEIGHT = {hs: START_DISCHARGE_FULL_HEIGHT + DIFF_TEETH_SERIES[hs] * TEETH_STEP_Y
                         for hs in SCREEN_HEIGHT_SERIES}


def _create_tables():
    document = Document()
    section = document.sections[-1]
    section.orientation = WD_ORIENT.LANDSCAPE
    section.page_width = Cm(42)
    section.page_height = Cm(29.7)

    max_gap = STEEL_GAPS[-1]
    min_gap = STEEL_GAPS[0]
    fixed_steel_s0, moving_steel_s0 = THICKNESS_STEEL[0]
    fixed_steel_s1, moving_steel_s1 = THICKNESS_STEEL[-1]
    discharge_height = 1.0

    paragraph = document.add_paragraph()
    paragraph.add_run('Сводная таблица параметров РСК')
    paragraph.style = 'Heading 1'

    document.add_paragraph().add_run(
        'В каждой ячейке указаны масса решетки и мощность привода.\n'
        'Параметры представлены в виде диапазона значений от самого легкого исполнения '
        '({}/{}, прозор {}) до самого тяжелого ({}/{}, прозор {}).\n'
        'Высота сброса принята {} м над каналом, материал пластин — сталь и полипропилен.'.format(
            fstr(to_mm(fixed_steel_s1)), fstr(to_mm(moving_steel_s1)), fstr(to_mm(max_gap)),
            fstr(to_mm(fixed_steel_s0)), fstr(to_mm(moving_steel_s0)), fstr(to_mm(min_gap)),
            fstr(discharge_height)))

    table = document.add_table(
        rows=len(SCREEN_WIDTH_SERIES) + 1, cols=len(SCREEN_HEIGHT_SERIES) + 1)
    for i, ws in enumerate(SCREEN_WIDTH_SERIES, start=1):
        table.cell(i, 0).text = '{}xx'.format(fstr(ws, '%02d'))
    for i, hs in enumerate(SCREEN_HEIGHT_SERIES, start=1):
        table.cell(0, i).text = 'xx{}'.format(fstr(hs, '%02d'))
    for row, ws in enumerate(SCREEN_WIDTH_SERIES, start=1):
        for col, hs in enumerate(SCREEN_HEIGHT_SERIES, start=1):
            screen = (
                StepScreen(InputData(
                    screen_ws=ws, screen_hs=hs, main_steel_gap=max_gap,
                    fixed_steel_s=fixed_steel_s1, moving_steel_s=moving_steel_s1,
                    channel_height=DISCHARGE_FULL_HEIGHT[hs] - discharge_height,
                    have_plastic_part=True)),
                StepScreen(InputData(
                    screen_ws=ws, screen_hs=hs, main_steel_gap=min_gap,
                    fixed_steel_s=fixed_steel_s0, moving_steel_s=moving_steel_s0,
                    channel_height=DISCHARGE_FULL_HEIGHT[hs] - discharge_height,
                    have_plastic_part=True)),)
            text = '{}÷{} кг\n{}÷{} кВт'.format(
                fstr(screen[0].full_mass, '%.0f'),
                fstr(screen[1].full_mass, '%.0f'),
                fstr(to_kw(screen[0].drive_unit.power)) if screen[0].drive_unit is not None
                else '..',
                fstr(to_kw(screen[1].drive_unit.power)) if screen[1].drive_unit is not None
                else '..',
                )
            table.cell(row, col).text = text
    table.style = 'Light Grid Accent 1'
    document.save('Сводная таблица параметров РСК ({}).docx'.format(date.today()))


if __name__ == '__main__':
    _create_tables()
