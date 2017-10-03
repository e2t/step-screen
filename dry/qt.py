from typing import Optional, Tuple, Callable, Union
from PyQt5 import QtWidgets
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QTextCursor
from .core import get_translate, InputException, get_dir_current_file


_ = get_translate(get_dir_current_file(__file__), 'ru', 'common')


AnyNumber = Union[int, float]
Limit = Optional[Tuple[AnyNumber, bool]]  # (limit, maybe_equal)


def get_number(lineedit: QtWidgets.QLineEdit,
               min_limit: Limit, max_limit: Limit,
               out_type: Callable[[str], AnyNumber]=float) -> AnyNumber:
    text = lineedit.text().replace(',', '.')
    try:
        number = out_type(text)
    except ValueError:
        stop_in_lineedit(lineedit, _('Incorrect string format'))
    if min_limit:
        if min_limit[1]:
            if number < min_limit[0]:
                stop_in_lineedit(lineedit, _(
                    'Input a value greater than or equal to {0}').format(
                        min_limit[0]))
        else:
            if number <= min_limit[0]:
                stop_in_lineedit(lineedit, _(
                    'Input a value greater than {0}').format(min_limit[0]))
    if max_limit:
        if max_limit[1]:
            if number > max_limit[0]:
                stop_in_lineedit(lineedit, _(
                    'Input a value less than or equal to {0}').format(
                        max_limit[0]))
        else:
            if number >= max_limit[0]:
                stop_in_lineedit(lineedit, _(
                    'Input a value less than {0}').format(max_limit[0]))
    return number


def stop_in_lineedit(lineedit: QtWidgets.QLineEdit, warning: str) -> None:
    lineedit.setFocus()
    lineedit.selectAll()
    raise InputException(warning)


def msgbox(warning: str) -> None:
    QtWidgets.QMessageBox(
        QtWidgets.QMessageBox.Critical, _('Error'), warning).exec()


class BaseMainWindow(QtWidgets.QDialog):  # type: ignore
    def __init__(self, description: str, version: str) -> None:
        super().__init__(
            None, flags=Qt.WindowMinimizeButtonHint |
            Qt.WindowCloseButtonHint)
        self.setupUi(self)  # from gui.Ui_Dialog
        self.setWindowTitle(f'{description} (v{version})')
        self.init_widgets()
        self.layout().setSizeConstraint(QtWidgets.QLayout.SetFixedSize)
        self.connect_actions()


def move_cursor_to_begin(line_edit: QtWidgets.QLineEdit) -> None:
    cursor = line_edit.textCursor()
    cursor.movePosition(QTextCursor.Start, QTextCursor.MoveAnchor, 1)
    line_edit.setTextCursor(cursor)
