"""Библиотека стандартных графических решений."""
import locale
from typing import Union, Optional, List, Tuple
from tkinter import Text, NORMAL, END, DISABLED
from tkinter.ttk import Widget, Frame, LabelFrame, Entry
from tkinter.scrolledtext import ScrolledText
from abc import abstractmethod
from math import radians
from .allcalc import Distance, VolumeFlowRate, Angle, Power


def convert_str_to_positive_float(text: str) -> float:
    """Преобразование строки в вещественное число больше нуля."""
    value = locale.atof(text)
    if value <= 0:
        raise ValueError
    return value


def fstr(value: Union[int, float], pattern: str = '%g') -> str:
    """Форматирует число в региональном формате."""
    return locale.format_string(pattern, value, True)


def print_in_disabled_text(memo: Union[Text, ScrolledText], text: str) -> None:
    """Заменить текст в отключенном виджете типа Text."""
    memo.config(state=NORMAL)
    memo.delete(1.0, END)
    memo.insert(END, text)
    memo.config(state=DISABLED)


def format_params(lines: List[Tuple[str, str]]) -> str:
    """Форматирует (выравнивает) список параметров и их значения."""
    longest_param = max([i[0] for i in lines], key=len)
    indent = len(longest_param)
    return '\n'.join(['%-*s  %s' % (indent, i[0], i[1]) for i in lines])


class MyFrame(Frame):
    """Форма с зазором между виджетами."""

    # Добавление зазора между виджетами.
    # Вызывать после создания всех виджетов на форме.
    def _add_pad_to_all_widgets(self, widget: Widget) -> None:
        widget.grid(padx=2, pady=2)
        if isinstance(widget, (Frame, LabelFrame)):
            for i in widget.winfo_children():
                self._add_pad_to_all_widgets(i)

    # Передать фокус в первое текстовое поле.
    # Вызывать после создания всех виджетов на форме.
    def _focus_first_entry(self, widget: Widget) -> bool:
        if isinstance(widget, Entry):
            widget.focus_set()
            return True
        if isinstance(widget, (Frame, LabelFrame)):
            for i in widget.winfo_children():
                if self._focus_first_entry(i):
                    return True
        return False

    @abstractmethod
    def _print_error(self, text: str) -> None:
        """Вывести сообщение об ошибке."""

    def _print_error_and_select(self, entry: Entry) -> None:
        self._print_error('Неправильное значение.')
        entry.focus_set()
        entry.select_range(0, 'end')

    def _get_positive_float_from_entry(self, entry: Entry) -> float:
        try:
            value = convert_str_to_positive_float(entry.get())
        except ValueError:
            self._print_error_and_select(entry)
            raise
        return value

    def _get_opt_positive_float_from_entry(
            self, entry: Entry) -> Optional[float]:
        text = entry.get()
        if not text:
            return None
        try:
            value = convert_str_to_positive_float(text)
        except ValueError:
            self._print_error_and_select(entry)
            raise
        return value

    def _get_mm_from_entry(self, entry: Entry) -> Distance:
        value = self._get_positive_float_from_entry(entry)
        return Distance(value / 1e3)  # мм -> м

    def _get_opt_mm_from_entry(self, entry: Entry) -> Optional[Distance]:
        value = self._get_opt_positive_float_from_entry(entry)
        if value is not None:
            return Distance(value / 1e3)  # мм -> м
        return None

    def _get_opt_l_s_from_entry(
            self, entry: Entry) -> Optional[VolumeFlowRate]:
        value = self._get_opt_positive_float_from_entry(entry)
        if value is not None:
            return VolumeFlowRate(value / 1e3)  # л/с -> м3/с
        return None

    def _get_opt_deg_from_entry(self, entry: Entry) -> Optional[Angle]:
        value = self._get_opt_positive_float_from_entry(entry)
        if value is not None:
            return Angle(radians(value))  # градусы -> радианы
        return None


def to_mm(meters: Distance) -> Distance:
    """Преобразование метров в миллиметры."""
    return Distance(meters * 1e3)


def from_mm(mms: Distance) -> Distance:
    """Преобразование миллиметров в метры."""
    return Distance(mms / 1e3)


def to_kw(watt: Power) -> Power:
    """Преобразование ватт в киловатты."""
    return Power(watt / 1e3)
