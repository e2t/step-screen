from prettytable import PrettyTable
import main


def generic_table_powers() -> None:
    table = PrettyTable()
    table.field_names = [''] + [f'xx{i}' for i in main.HEIGHTS]
    for width_size, oriental_ext_width in main.ORIENTAL_WIDTHS.items():
        row = [f'{width_size}xx']
        for height_size in main.HEIGHTS:
            ejection_height = main.HEIGHTS[height_size]
            power_drive = main.select_max_power(
                oriental_ext_width, ejection_height)
            row.append(str(power_drive))
        table.add_row(row)
    print('Мощности приводов ступенчатых решеток, кВт')
    print(table)


if __name__ == '__main__':
    generic_table_powers()
