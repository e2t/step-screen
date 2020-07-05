"""Графическая оболочка программы."""
import locale
from tkinter import (Tk, W, E, N, S, NORMAL, DISABLED, END, Event, BooleanVar)
from tkinter.ttk import (Frame, Label, Entry, Button, Combobox, Checkbutton)
from tkinter.scrolledtext import ScrolledText
from stepscreen import (StepScreen, SCREEN_WIDTH_SERIES, SCREEN_HEIGHT_SERIES, InputData,
                        THICKNESS_STEEL, STEEL_GAPS)
from dry.allgui import MyFrame, fstr, to_mm, to_kw
from dry.allcalc import InputDataError
locale.setlocale(locale.LC_NUMERIC, '')


class MainForm(MyFrame):
    """Главная форма."""

    THICKNESS_CHOICES = ['{} / {}'.format(fstr(to_mm(i[0])),
                                          fstr(to_mm(i[1]))) for i in THICKNESS_STEEL]
    GAP_CHOICES = [fstr(to_mm(i)) for i in STEEL_GAPS]
    SCREEN_WIDTH_CHOICES = [fstr(i, '%02d') for i in SCREEN_WIDTH_SERIES]
    SCREEN_HEIGHT_CHOICES = [fstr(i, '%02d') for i in SCREEN_HEIGHT_SERIES]

    def __init__(self, root: Tk) -> None:
        """Конструктор формы."""
        root.title(f'Расчет ступенчатых решеток (v2.0.0)')
        super().__init__(root)

        cmb_w = 5

        subframe = Frame(self)
        subframe.grid(row=0, column=0, sticky=W + N)

        row = 0
        Label(subframe, text='Ширина решетки:').grid(row=row, column=0, sticky=W)
        self._cmb_screen_ws = Combobox(subframe, state='readonly', width=cmb_w,
                                       values=self.SCREEN_WIDTH_CHOICES)
        self._cmb_screen_ws.grid(row=row, column=1)
        self._cmb_screen_ws.current(0)

        row += 1
        Label(subframe, text='Высота решетки:').grid(row=row, column=0, sticky=W)
        self._cmb_screen_hs = Combobox(subframe, state='readonly', width=cmb_w,
                                       values=self.SCREEN_HEIGHT_CHOICES)
        self._cmb_screen_hs.grid(row=row, column=1)
        self._cmb_screen_hs.current(0)

        row += 1
        Label(subframe, text='Прозор:').grid(row=row, column=0, sticky=W)
        self._cmb_gap = Combobox(subframe, width=1, values=self.GAP_CHOICES)
        self._cmb_gap.grid(row=row, column=1, sticky=W + E)
        self._cmb_gap.current(0)
        Label(subframe, text='мм').grid(row=row, column=2, sticky=W)

        row += 1
        Label(subframe, text='Толщина ламелей:').grid(row=row, column=0, sticky=W)
        self._cmb_thickness = Combobox(subframe, state='readonly', width=1,
                                       values=self.THICKNESS_CHOICES)
        self._cmb_thickness.grid(row=row, column=1, sticky=W + E)
        self._cmb_thickness.current(0)
        Label(subframe, text='мм').grid(row=row, column=2, sticky=W)

        row += 1
        Label(subframe, text='Глубина канала:').grid(row=row, column=0,
                                                     sticky=W)
        self._ent_channel_h = Entry(subframe, width=1)
        self._ent_channel_h.grid(row=row, column=1, sticky=W + E)
        Label(subframe, text='мм').grid(row=row, column=2, sticky=W)

        row += 1
        self._var_steel_only = BooleanVar()
        _chk_steel_only = Checkbutton(subframe, text='Только стальные ламели',
                                      var=self._var_steel_only)
        _chk_steel_only.grid(row=row, column=0, sticky=W, columnspan=3)

        self._memo = ScrolledText(self, state=DISABLED, height=15, width=45)
        self._memo.grid(row=0, column=1, sticky=W + E + N + S)

        btn_frame = Frame(self)
        btn_frame.grid(row=1, column=1, sticky=E)

        Button(btn_frame, text='Расчет', command=self._run).grid(row=0, column=0)
        self.bind_all('<Return>', self._on_press_enter)

        self._add_pad_to_all_widgets(self)
        self._focus_first_entry(self)

    # def _copy_output_to_clipboard(self) -> None:
    #     if self._memo.tag_ranges('sel'):
    #         text = self._memo.selection_get()
    #     else:
    #         text = self._memo.get(1.0, END)
    #     self.clipboard_clear()
    #     self.clipboard_append(text)
    #     self._memo.focus_force()

    def _output(self, text: str) -> None:
        self._memo.config(state=NORMAL)
        self._memo.delete(1.0, END)
        self._memo.insert(END, text)
        self._memo.config(state=DISABLED)

    def _print_error(self, text: str) -> None:
        self._output(text)

    def _run(self) -> None:
        screen_ws = SCREEN_WIDTH_SERIES[self._cmb_screen_ws.current()]
        screen_hs = SCREEN_HEIGHT_SERIES[self._cmb_screen_hs.current()]
        moving_steel_s, fixed_steel_s = THICKNESS_STEEL[self._cmb_thickness.current()]
        have_plastic_part = not self._var_steel_only.get()
        try:
            main_steel_gap = self._get_mm_from_entry(self._cmb_gap)
            channel_height = self._get_mm_from_entry(self._ent_channel_h)
        except ValueError:
            return
        input_data = InputData(screen_ws=screen_ws, screen_hs=screen_hs,
                               main_steel_gap=main_steel_gap,
                               fixed_steel_s=fixed_steel_s,
                               moving_steel_s=moving_steel_s,
                               channel_height=channel_height,
                               have_plastic_part=have_plastic_part)
        try:
            scr = StepScreen(input_data)
        except InputDataError as excp:
            self._output(str(excp))
            return

        output = [
            'Масса решетки {} кг{}'.format(fstr(scr.full_mass, '%.0f'),
                                           ' (без привода)' if scr.drive_unit is None else ''),
            'Привод {} кВт'.format(fstr(to_kw(scr.drive_unit.power))
                                   if scr.drive_unit is not None else None),
            '',
            'Ширина наружная B = {} мм'.format(fstr(to_mm(scr.outer_screen_width))),
            'Ширина внутренняя A = {} мм'.format(fstr(to_mm(scr.inner_screen_width))),
            'Ширина сброса {} мм'.format(fstr(to_mm(scr.discharge_width))),
            'Высота сброса до дна H1 = {} мм'.format(fstr(to_mm(scr.discharge_full_height),
                                                          '%.0f')),
            'Высота сброса до пола H4 = {} мм'.format(fstr(to_mm(scr.discharge_height), '%.0f')),
            'Высота решетки H2 = {} мм'.format(fstr(to_mm(scr.screen_height), '%.0f')),
            'Длина решетки L = {} мм'.format(fstr(to_mm(scr.screen_length), '%.0f')),
            'Длина в плане D = {} мм'.format(fstr(to_mm(scr.horiz_length), '%.0f')),
            'Размер до оси F = {} мм'.format(fstr(to_mm(scr.axe_distance_x), '%.0f')),
            'Радиус поворота R = {} мм'.format(fstr(to_mm(scr.turning_radius), '%.0f')),
            '',
            '====== Для конструктора ======',
            '']
        if scr.drive_unit is not None:
            output.append('Привод {} ({} Нм)'.format(
                scr.drive_unit.name, fstr(scr.drive_unit.output_torque)))
        output += (
            'Подвижных пластин {} шт.'.format(scr.moving_plates_number),
            '- сталь {} мм'.format(fstr(to_mm(scr.moving_steel_s))))
        if scr.have_plastic_part:
            output.append(
                '- пластик {} мм'.format(fstr(to_mm(scr.moving_plastic_s))
                                         if scr.moving_plastic_s is not None else None))
        output += (
            '- крайний паз {} мм'.format(fstr(to_mm(scr.start_moving))),
            'Неподвижных пластин {} шт.'.format(scr.fixed_plates_number),
            '- сталь {} мм'.format(fstr(to_mm(scr.fixed_steel_s))))
        if scr.have_plastic_part:
            output.append(
                '- пластик {} мм'.format(fstr(to_mm(scr.fixed_plastic_s))
                                         if scr.fixed_plastic_s is not None else None))
        output += (
            '- крайний паз {} мм'.format(fstr(to_mm(scr.start_fixed))),
            'Шаг пластин по ширине {} мм'.format(fstr(to_mm(scr.plates_step))),
            'Толщина боковой накладки не более {} мм'.format(fstr(to_mm(scr.min_side_gap))),
            '',)
        if scr.have_plastic_part:
            output.append(
                'Сумма толщин пластиковых пластин {}-{} мм'.format(
                    fstr(to_mm(scr.sum_plastic_s[1])),
                    fstr(to_mm(scr.sum_plastic_s[0]))))
        output += (
            'Вес подвижных частей {} кг'.format(fstr(scr.moving_mass, '%.0f')),
            'Крутяший момент {} Нм'.format(fstr(scr.min_torque, '%.0f')))
        self._output('\n'.join(output))

    def _on_press_enter(self, _: Event) -> None:
        self._run()
