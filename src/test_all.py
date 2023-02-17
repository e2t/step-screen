from calc import (ALL_NOMINAL_GAPS, HSDATA, PLATES_AND_SPACERS, WSDATA,
                  InputData, StepScreen, NOMINAL_GAPS_AND_PLASTIC_SPACERS)
from constants import PLASTIC


def main() -> None:
    for hs in HSDATA:
        for ws in WSDATA:
            for gap in ALL_NOMINAL_GAPS:
                for ps in PLATES_AND_SPACERS:
                    if gap not in NOMINAL_GAPS_AND_PLASTIC_SPACERS and \
                            ps.spacer == PLASTIC:
                        continue
                    for so in (False, True):
                        inp = InputData(ws=ws, hs=hs, gap=gap, depth=hs * 0.1,
                                        plate_spacer=ps, steel_only=so)
                        # print(inp)
                        StepScreen(inp, None)
    print('Done!')


if __name__ == '__main__':
    main()
