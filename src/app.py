from locale import atof
from tkinter import END, BooleanVar, Tk
from tkinter.ttk import Checkbutton, Combobox, Entry, Label, Treeview

from dry.basegui import PAD
from dry.calcapp import CalcApp
from dry.l10n import ENG, LIT, RUS, UKR
from dry.measurements import mm, to_mm
from dry.tkutils import max_column_width

from calc import (ALL_NOMINAL_GAPS, HSDATA, PLATES_AND_SPACERS, WSDATA,
                  InputData, run_calc)
from captions import ErrorMsg, UiText
from constants import Col

WSCHOICES = {f'{i:02d}': i for i in WSDATA}
HSCHOICES = {f'{i:02d}': i for i in HSDATA}
GAPCHOICES = {f'{to_mm(i):n}': i for i in ALL_NOMINAL_GAPS}


class App(CalcApp):
    def __init__(self, root: Tk) -> None:
        super().__init__(root,
                         appname='StepScreen',
                         appvendor='Esmil',
                         appversion='2023.2',
                         uilangs=(ENG, UKR, LIT),
                         outlangs=(ENG, UKR, RUS),
                         title=UiText.TITLE)
        entrywid = 15

        self.wslabel = Label(self.widgetframe)
        self.wslabel.grid(row=0, column=0, padx=PAD, pady=PAD, sticky='W')
        self.wsbox = Combobox(self.widgetframe, state='readonly',
                              values=tuple(WSCHOICES), width=1)
        self.wsbox.current(0)
        self.wsbox.grid(row=0, column=1, padx=PAD, pady=PAD, sticky='WE')

        self.hslabel = Label(self.widgetframe)
        self.hslabel.grid(row=1, column=0, padx=PAD, pady=PAD, sticky='W')
        self.hsbox = Combobox(self.widgetframe, state='readonly',
                              values=tuple(HSCHOICES), width=1)
        self.hsbox.current(0)
        self.hsbox.grid(row=1, column=1, padx=PAD, pady=PAD, sticky='WE')

        self.gaplabel = Label(self.widgetframe)
        self.gaplabel.grid(row=2, column=0, padx=PAD, pady=PAD, sticky='W')
        self.gapbox = Combobox(self.widgetframe, state='readonly',
                               values=tuple(GAPCHOICES), width=1)
        self.gapbox.current(0)
        self.gapbox.grid(row=2, column=1, padx=PAD, pady=PAD, sticky='WE')

        self.deplabel = Label(self.widgetframe)
        self.deplabel.grid(row=3, column=0, padx=PAD, pady=PAD, sticky='W')
        self.depbox = Entry(self.widgetframe, width=entrywid)
        self.depbox.grid(row=3, column=1, padx=PAD, pady=PAD, sticky='WE')

        self.platelabel = Label(self.widgetframe)
        self.platelabel.grid(row=4,
                             column=0,
                             padx=PAD,
                             pady=PAD,
                             sticky='W',
                             columnspan=2)

        self.table = Treeview(self.widgetframe,
                              show='headings',
                              selectmode='browse',
                              height=len(PLATES_AND_SPACERS),
                              columns=tuple(Col))
        for i in Col:
            width = max_column_width(UiText.COL[i].values(), 1)
            self.table.column(i, width=width)
        self.table.grid(row=5, column=0, columnspan=2, padx=PAD, sticky='WE')
        self.tablerows = {}
        for _i, value in enumerate(PLATES_AND_SPACERS):
            item = self.table.insert('', END)
            self.tablerows[item] = value
        self.table.selection_set(next(iter(self.tablerows)))

        self.steelonlyvar = BooleanVar()
        self.steelonlybox = Checkbutton(self.widgetframe,
                                        variable=self.steelonlyvar)
        self.steelonlybox.grid(row=6,
                               column=0,
                               padx=PAD,
                               pady=PAD,
                               sticky='W',
                               columnspan=2)

    def translate_ui(self) -> None:
        super().translate_ui()
        self.wslabel['text'] = UiText.WS[self.uilang]
        self.hslabel['text'] = UiText.HS[self.uilang]
        self.gaplabel['text'] = UiText.GAP[self.uilang]
        self.deplabel['text'] = UiText.DEP[self.uilang]
        for i in Col:
            self.table.heading(i, text=UiText.COL[i][self.uilang])
        for key, value in self.tablerows.items():
            self.table.item(key,
                            values=[
                                f'{to_mm(value.fixed):n}',
                                f'{to_mm(value.moving):n}',
                                UiText.SPACERS[value.spacer][self.uilang]
                            ])
        self.platelabel['text'] = UiText.PLATE[self.uilang]
        self.steelonlybox['text'] = UiText.STEELONLY[self.uilang]

    def get_inputdata(self) -> None:
        wschoice = self.wsbox.get()
        self.inpdata['ws'] = WSCHOICES[wschoice]
        hschoice = self.hsbox.get()
        self.inpdata['hs'] = HSCHOICES[hschoice]
        gapchoice = self.gapbox.get()
        self.inpdata['gap'] = GAPCHOICES[gapchoice]
        depthtext = self.depbox.get()
        try:
            self.inpdata['depth'] = mm(atof(depthtext))
        except ValueError:
            self.adderror(ErrorMsg.DEPTH)
        self.inpdata['plate_spacer'] = \
            self.tablerows[self.table.selection()[0]]
        self.inpdata['steel_only'] = self.steelonlyvar.get()

    def runcalc(self) -> None:
        run_calc(InputData(**self.inpdata), self.adderror, self.addline)
        # for i in ErrorMsg:
        #     self.adderror(i)
