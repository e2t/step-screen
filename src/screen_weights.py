from datetime import datetime
from typing import NamedTuple, Tuple
from prettytable import PrettyTable
import main


class ScreenOption(NamedTuple):
    thickness_steel: Tuple[float, float]
    gap: float


def generic_table_weights(is_wide_screen: bool) -> None:
    table = PrettyTable()

    screen_options = {
        f'Прозор {j}, ламели {i[0]}+{i[1]}':
        ScreenOption(thickness_steel=i, gap=j)
        for j in main.STEEL_GAPS for i in main.THICKNESS_STEEL.values()}

    table.field_names = [''] + list(screen_options)

    for width_size in main.CHANNEL_WIDTHS:
        for height_size in main.HEIGHTS:
            row = [f'{width_size}{height_size}']

            for title, screen_option in screen_options.items():
                table.align[title] = 'l'

                moving_plate_thickness, fixed_plate_thickness = \
                    screen_option.thickness_steel

                is_small_screen = main.calc_is_small_size(width_size)
                oriental_ext_width = main.calc_max_width(width_size,
                                                         is_wide_screen)
                ejection_height = main.HEIGHTS[height_size]
                depth_channel = ejection_height - main.DROP_HEIGHT_FROM_CHANNEL

                screen = main.calc_step_screen(
                    oriental_ext_width=oriental_ext_width,
                    ejection_height=ejection_height,
                    moving_plate_thickness=moving_plate_thickness,
                    fixed_plate_thickness=fixed_plate_thickness,
                    gap=screen_option.gap,
                    depth_channel=depth_channel,
                    is_small_screen=is_small_screen)

                cell_text = f'{screen.weight:.0f} кг, из них ламели:\n'
                for mm, kg in screen.steel_sheet_weight.items():
                    cell_text += f'{"сталь":7s} {mm:.0f} мм {kg:.0f} кг\n'
                for mm, kg in screen.plastic_sheet_weight.items():
                    cell_text += f'пластик {mm:.0f} мм {kg:.0f} кг\n'
                row.append(cell_text)
            table.add_row(row)
    print(f'Массы ступенчатых решеток ({datetime.now()})')
    print(f'Высота сброса над каналом {main.DROP_HEIGHT_FROM_CHANNEL} мм.')
    if is_wide_screen:
        print('Максимальная ширина решетки (Европа)')
    else:
        print('Стандартная ширина решетки (СНГ)')
    print(table)
    print('\n\n')


def generic_all_tables() -> None:
    for is_wide_screen in (False, True):
        generic_table_weights(is_wide_screen)


if __name__ == '__main__':
    generic_all_tables()
