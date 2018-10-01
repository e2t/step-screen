from typing import List
import main
from screen import StepScreen


INDENT = '    '


RSK = {
    ('05', '06'): (1050, 1050, 1050),
    ('05', '12'): (1050, 1300, 1600),
    ('07', '12'): (1050, 1330, 1600),
    ('08', '12'): (1050, 1330, 1600),
    ('09', '12'): (1050, 1330, 1600),
    ('09', '18'): (1350, 2000, 2250),
    ('14', '21'): (1600, 2300, 2550),
    ('15', '21'): (1600, 2000, 2550),
    ('15', '24'): (1950, 2500, 2850),
}


ONLY_STEEL_STRIPS = True


def compute_all_diff() -> None:
    for name, depth in RSK.items():

        origin_depth = depth[1]

        def compute_diff(new_depth: int) -> None:
            print(f'РСК {name[0]}{name[1]}')
            print(f'{INDENT}{origin_depth} -> {new_depth}')
            for gap in main.STEEL_GAPS:
                print(f'{INDENT * 2}Прозор {gap} мм')
                for s, (moving_plate_thickness,
                        fixed_plate_thickness) in main.THICKNESS_STEEL.items():
                    oriental_ext_width = main.calc_max_width(name[0], False)
                    ejection_height = main.HEIGHTS[name[1]]
                    is_small_screen = main.calc_is_small_size(name[0])

                    origin = main.calc_step_screen(
                        oriental_ext_width=oriental_ext_width,
                        ejection_height=ejection_height,
                        moving_plate_thickness=moving_plate_thickness,
                        fixed_plate_thickness=fixed_plate_thickness,
                        gap=gap,
                        depth_channel=origin_depth,
                        is_small_screen=is_small_screen,
                        only_steel_strips=False)

                    screen = main.calc_step_screen(
                        oriental_ext_width=oriental_ext_width,
                        ejection_height=ejection_height,
                        moving_plate_thickness=moving_plate_thickness,
                        fixed_plate_thickness=fixed_plate_thickness,
                        gap=gap,
                        depth_channel=new_depth,
                        is_small_screen=is_small_screen,
                        only_steel_strips=ONLY_STEEL_STRIPS)

                    print(f'{INDENT * 3}Пластины {s}:')

                    for mm in screen.steel_sheet_weight:
                        diff = screen.steel_sheet_weight[mm] - \
                            origin.steel_sheet_weight[mm]
                        if diff:
                            print(f'{INDENT * 4}сталь {mm:.0f} мм: {diff:+.0f} кг')

                    if ONLY_STEEL_STRIPS:
                        print(f'{INDENT * 4}без пластика')
                    else:
                        for mm in screen.plastic_sheet_weight:
                            diff = screen.plastic_sheet_weight[mm] - \
                                origin.plastic_sheet_weight[mm]
                            if diff:
                                print(f'{INDENT * 4}пластик {mm:.0f} мм: {diff:+.0f} кг')

                    print()

        for new_depth in depth:
            compute_diff(new_depth)


if __name__ == '__main__':
    compute_all_diff()
