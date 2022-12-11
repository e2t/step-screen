from enum import StrEnum, auto, unique
from locale import atof
from tkinter import END, BooleanVar, E, Tk, W
from tkinter.ttk import Checkbutton, Combobox, Entry, Label, Treeview

from dry.calcapp import PAD, CalcApp
from dry.l10n import ENG, LIT, RUS, UKR
from dry.measurements import mm, to_mm

from calc import (HSDATA, NOMINAL_GAPS, PLATES_AND_SPACERS, WSDATA, InputData,
                  run_calc)
from captions import ErrorMsg, UiText


@unique
class Col(StrEnum):
    FIXED = auto()
    MOVING = auto()
    SPACER = auto()


WSCHOICES = {f"{i:02d}": i for i in WSDATA}
HSCHOICES = {f"{i:02d}": i for i in HSDATA}
GAPCHOICES = {f"{to_mm(i):g}": i for i in NOMINAL_GAPS}


class App(CalcApp):
    def __init__(self, root: Tk) -> None:
        super().__init__(root,
                         appname="StepScreen",
                         appvendor="Esmil",
                         appversion="2.5.0",
                         uilangs=(ENG, UKR, LIT),
                         outlangs=(ENG, UKR, RUS))

        self.wslabel = Label(self.widgetframe)
        self.wslabel.grid(row=0, column=0, padx=PAD, pady=PAD, sticky=W)
        self.wsbox = Combobox(self.widgetframe,
                              state="readonly",
                              values=tuple(WSCHOICES))
        self.wsbox.current(0)
        self.wsbox.grid(row=0, column=1, padx=PAD, pady=PAD, sticky=E)

        self.hslabel = Label(self.widgetframe)
        self.hslabel.grid(row=1, column=0, padx=PAD, pady=PAD, sticky=W)
        self.hsbox = Combobox(self.widgetframe,
                              state="readonly",
                              values=tuple(HSCHOICES))
        self.hsbox.current(0)
        self.hsbox.grid(row=1, column=1, padx=PAD, pady=PAD, sticky=E)

        self.gaplabel = Label(self.widgetframe)
        self.gaplabel.grid(row=2, column=0, padx=PAD, pady=PAD, sticky=W)
        self.gapbox = Combobox(self.widgetframe,
                               state="readonly",
                               values=tuple(GAPCHOICES))
        self.gapbox.current(0)
        self.gapbox.grid(row=2, column=1, padx=PAD, pady=PAD, sticky=E)

        self.deplabel = Label(self.widgetframe)
        self.deplabel.grid(row=3, column=0, padx=PAD, pady=PAD, sticky=W)
        self.depbox = Entry(self.widgetframe)
        self.depbox.grid(row=3, column=1, padx=PAD, pady=PAD, sticky=W + E)

        self.platelabel = Label(self.widgetframe)
        self.platelabel.grid(row=4,
                             column=0,
                             padx=PAD,
                             pady=PAD,
                             sticky=W,
                             columnspan=2)

        self.table = Treeview(self.widgetframe,
                              show="headings",
                              selectmode="browse",
                              height=len(PLATES_AND_SPACERS),
                              columns=(Col.FIXED, Col.MOVING, Col.SPACER))
        self.table.column(Col.FIXED, width=1)
        self.table.column(Col.MOVING, width=1)
        self.table.column(Col.SPACER, width=1)
        self.table.grid(row=5, column=0, columnspan=2, padx=PAD, sticky=W + E)
        self.tablerows = {}
        for _i, value in enumerate(PLATES_AND_SPACERS):
            item = self.table.insert("", END)
            self.tablerows[item] = value
        self.table.selection_set(next(iter(self.tablerows)))

        self.steelonlyvar = BooleanVar()
        self.steelonlybox = Checkbutton(self.widgetframe,
                                        variable=self.steelonlyvar)
        self.steelonlybox.grid(row=6,
                               column=0,
                               padx=PAD,
                               pady=PAD,
                               sticky=W,
                               columnspan=2)

    def translate_ui(self) -> None:
        super().translate_ui()
        self.wslabel["text"] = UiText.WS[self.uilang]
        self.hslabel["text"] = UiText.HS[self.uilang]
        self.gaplabel["text"] = UiText.GAP[self.uilang]
        self.deplabel["text"] = UiText.DEP[self.uilang]
        self.table.heading(Col.FIXED, text=UiText.FIXED[self.uilang])
        self.table.heading(Col.MOVING, text=UiText.MOVING[self.uilang])
        self.table.heading(Col.SPACER, text=UiText.LIMITERS[self.uilang])
        for key, value in self.tablerows.items():
            self.table.item(key,
                            values=[
                                f"{to_mm(value.fixed):g}",
                                f"{to_mm(value.moving):g}",
                                UiText.SPACERS[value.spacer][self.uilang]
                            ])
        self.platelabel["text"] = UiText.PLATE[self.uilang]
        self.steelonlybox["text"] = UiText.STEELONLY[self.uilang]
        self.root.title(f"{UiText.TITLE[self.uilang]} - {self.apptitle}")

    def get_inputdata(self) -> None:
        wschoise = self.wsbox.get()
        self.inpdata["ws"] = WSCHOICES[wschoise]
        hschoise = self.hsbox.get()
        self.inpdata["hs"] = HSCHOICES[hschoise]
        gapchoice = self.gapbox.get()
        self.inpdata["gap"] = GAPCHOICES[gapchoice]
        depthtext = self.depbox.get()
        try:
            self.inpdata["depth"] = mm(atof(depthtext))
        except ValueError:
            self.adderror(ErrorMsg.DEPTH)
        self.inpdata["plate_spacer"] = \
            self.tablerows[self.table.selection()[0]]
        self.inpdata["steel_only"] = self.steelonlyvar.get()

    def runcalc(self) -> None:
        run_calc(InputData(**self.inpdata), self.adderror, self.addline)
        # self.adderror(ErrorMsg.DEPTH)
        # self.adderror(ErrorMsg.TOODEEP)
