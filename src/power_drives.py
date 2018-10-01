from datetime import datetime
from prettytable import PrettyTable
import main


def generic_table_powers() -> None:
    table = PrettyTable()
    table.field_names = [''] + [f'xx{i}' for i in main.HEIGHTS]
    for width_size in main.CHANNEL_WIDTHS:
        row = [f'{width_size}xx']
        for height_size in main.HEIGHTS:
            ejection_height = main.HEIGHTS[height_size]
            # Для решеток с пластиковыми ламелями
            power_drive = main.select_max_power(width_size, ejection_height,
                                                False)
            row.append(str(power_drive))
        table.add_row(row)
    print(f'Мощности приводов ступенчатых решеток, кВт ({datetime.now()})')
    print(table)


if __name__ == '__main__':
    generic_table_powers()
