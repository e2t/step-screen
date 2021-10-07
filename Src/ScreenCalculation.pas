unit ScreenCalculation;

{$MODE OBJFPC}
{$LONGSTRINGS ON}
{$ASSERTIONS ON}
{$RANGECHECKS ON}
{$BOOLEVAL OFF}

interface

uses
  Nullable;

type
  //Набор пластин: 0 - подвижные (тоньше), 1 - неподвижные (толще)
  TPlatesSet = record
    Moving, Fixed: Double;
  end;

  TInputData = record
    //Типоразмер решетки по ширине.
    ScreenWS: Integer;
    //Типоразмер решетки по высоте.
    ScreenHS: Integer;
    //Прозор стальных пластин, м.
    MainSteelGapMm: Double;
    //Толщины стальных пластин, м.
    SteelS: TPlatesSet;
    //Глубина канала, м.
    ChannelHeightMm: Double;
    //True - с пластиковым полотном, False - только стальные пластины.
    HavePlasticPart: Boolean;
  end;

  TDriveUnit = record
    Name: string;
    Mass: Double;
    Power: Double;
    Torque: Double;
    Speed: Double;
  end;

  TNullableDrive = specialize TNullable<TDriveUnit>;

  //Массы отдельных узлов решетки.
  TStepScreenMass = record
    //Кнопочный пост КПС 820.000
    PushButtonPost: Double;
    //Опора решетки на поверхность канала
    Support: Double;
    //Датчик штыревой
    PinSensor: Double;
    //10 анкерных болтов в МЧ
    Anchors: Double;
    //Узел привода (без самого привода)
    DriveSupport: Double;
    //Кожух сброса
    Chute: Double;
    //Узел подачи воздуха
    AirSupply: Double;
    //Узел взмучивания
    StirringUp: Double;
    //Шатун
    PitmanArm: Double;
    //Передняя крышка (нижняя)
    FrontCover00: Double;
    //Передняя крышка (верхняя)
    FrontCover01: Double;
    //Верхняя крышка
    TopCover: Double;
    //Задняя крышка
    BackCover: Double;
    //Нижняя балка крепления верхней крышки
    TopCoverFixingBeam: Double;
    //Нижняя балка крепления передней крышки (нижней)
    FrontCover00FixingBeam: Double;
    //Нижняя балка крепления передней крышки (верхней)
    FrontCover01FixingBeam: Double;
    //Планка крепежная
    FixingStrip: Double;
    //Клеммная коробка
    TerminalBox: Double;
    //Подвеска (шатун)
    ConnectingRod: Double;
    //Кривошип
    Crank: Double;
    //Нижняя заслонка
    BottomFlap: Double;
    //Прижим неподвижных ламелей
    FixingPlatesClip: Double;
    //Прижим подвижных ламелей
    MovingPlatesClip: Double;
    //Гребенка для крепления неподвижных пластин
    BottonRake: Double;
    //Нижняя балка рамы (опора на дно канала) + муфта и ребра
    BottomFrameBeam: Double;
    //Средняя балка рамы (перемычка)
    MiddleFrameBeam: Double;
    //Верхняя балка рамы (крепление клеммной коробки)
    TopFrameBeam: Double;
    //Поперечная балка крепления неподвижных пластин (приварная)
    FixingPlatesBeam: Double;
    //Поперечная балка крепления подвижных пластин
    MovingPlatesBeam: Double;
    //Боковина (вместе с деталями рамы)
    Sidewall: Double;
    //Коромысло
    ParallelogramBeam: Double;
    //Продольная балка подвижного полотна
    MovingLengthwiseBeam: Double;
    //Стальная часть неподвижной пластины
    FixedPlateSteelPart: TNullableReal;
    //Пластиковая часть неподвижной пластины
    FixedPlatePlasticPart: TNullableReal;
    //Стальная часть подвижной пластины
    MovingPlateSteelPart: TNullableReal;
    //Пластиковая часть подвижной пластины
    MovingPlatePlasticPart: TNullableReal;
    //Полностью стальная неподвижная пластина
    FullSteelFixedPlate: TNullableReal;
    //Полностью стальная подвижная пластина
    FullSteelMovingPlate: TNullableReal;
    //Нижний дистанционер (накладка)
    BottomPlateLimiter: Double;
    //Основной дистанционер (полоса)
    MainPlateLimiter: Double;
    //Боковая крышка
    SideCover: Double;
    //Склиз нижний (закрытое исполнение)
    BackBottomCover: Double;
    //Рукав подачи воздуха (резина)
    Hose: Double;
    //Защитный экран (резина + прижимные планки)
    RubberScreen: Double;
  end;

  //Диапазон вещественных значений: 0 - Min, 1 - Max
  TDiapason = array [0..1] of Double;

  TStepScreen = record
    ScreenWs, ScreenHs: Integer;

    MovingBeamNumber, MovingPlatesNumber, SteelFixedTeethNumber,
    SteelMovingTeethNumber, PlasticFixedTeethNumber, PlasticMovingTeethNumber,
    FullTeethNumber, FixedPlatesNumber, LimitersNumber, FixingBeamNumber,
    DiffTeeth: Integer;

    DischargeHeight, ChannelHeight, LimiterS, FixedSteelS, MovingSteelS,
    ApproximatePlasticS, InnerScreenWidth, MainSteelGap, PlatesStep,
    SideSteelGap, StartFixed, StartMoving, DischargeFullHeight,
    OuterScreenWidth, MinSideGap, ScreenHeight, HorizLength,
    AxeDistanceY, AxeDistanceX, TurningRadius, ScreenLength, DischargeWidth,
    BetweenExtremeFixedBeams, BetweenExtremeMovingBeams, Weight, MovingWeight,
    MinTorque: Double;

    FixedPlasticS, MovingPlasticS, SidePlasticGap: TNullableReal;
    HavePlasticPart: Boolean;
    DriveUnit: TNullableDrive;
    Weights: TStepScreenMass;
    Description, EquationFile: string;
    SumPlasticS: TDiapason;
  end;

  TPlasticSet = record
    Summa: Double;
    Sheets: TPlatesSet;
  end;

  THeightSerie = record
    Serie: Integer;
    DiffTeeth: Integer;
  end;

const
  ScreenWidthSeries = [5..22];
  ScreenHeightSeries: array of THeightSerie = (
    (Serie: 6; DiffTeeth: -19),
    (Serie: 9; DiffTeeth: -15),
    (Serie: 12; DiffTeeth: -11),
    (Serie: 15; DiffTeeth: -7),
    (Serie: 18; DiffTeeth: -4),
    (Serie: 21; DiffTeeth: 0),
    (Serie: 24; DiffTeeth: 4),
    (Serie: 27; DiffTeeth: 8),
    (Serie: 30; DiffTeeth: 11),
    (Serie: 33; DiffTeeth: 15));

  //Толщина стальных пластин
  ThicknessSteel: array of TPlatesSet = (
    (Moving: 0.002; Fixed: 0.003),
    (Moving: 0.003; Fixed: 0.003),
    (Moving: 0.002; Fixed: 0.002));

  //Покупные пластиковые листы из ряда: 4, 5, 6, 8, 10, 12 мм.
  ThicknessPlastic: array of TPlasticSet = (
    (Summa: 0.008; Sheets: (Moving: 0.004; Fixed: 0.004)),
    (Summa: 0.010; Sheets: (Moving: 0.005; Fixed: 0.005)),
    (Summa: 0.012; Sheets: (Moving: 0.006; Fixed: 0.006)),
    (Summa: 0.014; Sheets: (Moving: 0.006; Fixed: 0.008)),
    (Summa: 0.016; Sheets: (Moving: 0.008; Fixed: 0.008)),
    (Summa: 0.018; Sheets: (Moving: 0.008; Fixed: 0.01)));

  //Прозоры стальных пластин.
  SteelGaps: array of Double = (0.0034, 0.0054, 0.0064);

  TeethXX21 = 41;

  //Плечо кривошипа.
  LeverArm = 0.055;

  //Шаг зубьев пластин.
  TeethStep = 0.105;

  //Расстояние от сброса до верхней точки решетки.
  BetwDischargeAndTop = 0.64668;

  //Расстояние от края сброса до оси опоры (гориз.).
  BetwDischargeAndAxeX = 0.31494;

  //Расстояние между крайними неподвижными балками.
  BetwExtremeFixedBeams = 3.795;

  //Расстояние между крайними подвижными балками.
  BetwExtremeMovingBeams = 3.24;

  //Высота сброса, H1.
  StartDischargeFullHeight = 3.05;

  //Длина в плане, D.
  StartHorizLength = 3.09774;

  //Длина решетки, L.
  StartScreenLength = 4.73198;

  //Расстояние от дна канала до оси опоры.
  StartAxeHeight = 3.13;

  //Минимальная высота сброса над каналом.
  MinDischargeHeight = 0.66;

  //Допустимый зазор между пластиковыми пластинами.
  PlasticGap: TDiapason = (0.0004, 0.001);

function CalcManualScreen(out Scr: TStepScreen; const InputData: TInputData): string;

implementation

uses
  Classes, Math, Measurements, SysUtils, MathUtils, StrConvert;

var
  TiltAngle, TeethStepY, TeethStepX: Double;
  DriveUnits05XX: array [0..1] of TDriveUnit;
  DriveUnits: array [0..3] of TDriveUnit;

//Создание обозначения решетки (XXYY).
function CreateDescription(const ScreenWS, ScreenHS: Integer): string;
begin
  Result := Format('%.2d%.2d', [ScreenWS, ScreenHS]);
end;

//Расчет наружной ширины решетки по типоразмеру ширины.
function CalcOuterScreenWidth(const ScreenWS: Integer): Double;
begin
  Result := ScreenWS * 0.1 + 0.05;
end;

//Расчет внутренней ширины (просвета) решетки по типоразмеру ширины.
function CalcInnerScreenWidth(const ScreenWS: Integer): Double;
begin
  Result := ScreenWS * 0.1 - 0.07;
end;

//Расчет шага пластин одного полотна.
function CalcPlatesStep(const FixedSteelS, MovingSteelS, MainSteelGap: Double): Double;
begin
  Result := FixedSteelS + MovingSteelS + 2 * MainSteelGap;
end;

//Расчет количества неподвижных пластин.
function CalcFixedPlatesNumber(const InnerScreenWidth, MovingSteelS,
  PlatesStep: Double): Integer;
begin
  Result := Trunc((InnerScreenWidth - MovingSteelS) / PlatesStep);
end;

//Расчет количества подвижных пластин.
function CalcMovingPlatesNumber(const FixedPlatesNumber: Integer): Integer;
begin
  Result := FixedPlatesNumber + 1;
end;

//Расчет зазора между боковиной и крайней стальной пластиной.
function CalcSideSteelGap(const InnerScreenWidth, MovingSteelS, PlatesStep: Double;
  const FixedPlatesNumber: Integer): Double;
begin
  Result := (InnerScreenWidth - MovingSteelS - PlatesStep * FixedPlatesNumber) / 2;
end;

//Расчет расстояния от центра крайнего паза крайней неподвижной пластины до боковины.
function CalcStartFixed(const SideSteelGap, MovingSteelS, MainSteelGap,
  FixedSteelS: Double): Double;
begin
  Result := SideSteelGap + MovingSteelS + MainSteelGap + FixedSteelS / 2;
end;

//Расчет расстояния от центра крайнего паза крайней подвижной пластины до боковины.
function CalcStartMoving(const SideSteelGap, MovingSteelS: Double): Double;
begin
  Result := SideSteelGap + MovingSteelS / 2;
end;

//Расчет примерной толщины пластиковых пластин (вне стандартного ряда).
function CalcApproximatePlasticS(const SumPlasticS: TDiapason): Double;
begin
  Result := (SumPlasticS[0] + SumPlasticS[1]) / 2;
end;

//Расчет суммы толщин пластиковых пластин.
function CalcSumPlasticS(const PlatesStep: Double): TDiapason;
begin
  Result[0] := PlatesStep - 2 * PlasticGap[1];
  Result[1] := PlatesStep - 2 * PlasticGap[0];
end;

//Расчет высоты сброса до дна канала.
function CalcDischargeFullHeight(const DiffTeeth: Integer): Double;
begin
  Result := StartDischargeFullHeight + DiffTeeth * TeethStepY;
end;

//Расчет высоты сброса до поверхности канала.
function CalcDischargeHeight(const DischargeFullHeight, ChannelHeight: Double): Double;
begin
  Result := DischargeFullHeight - ChannelHeight;
end;

//Расчет высоты решетки.
function CalcScreenHeight(const DischargeFullHeight: Double): Double;
begin
  Result := DischargeFullHeight + BetwDischargeAndTop;
end;

//Расчет высоты от дна канала до оси опоры.
function CalcAxeDistanceY(const DiffTeeth: Integer): Double;
begin
  Result := StartAxeHeight + DiffTeeth * TeethStepY;
end;

//Расчет длины решетки в плане.
function CalcHorizLength(const DiffTeeth: Integer): Double;
begin
  Result := StartHorizLength + DiffTeeth * TeethStepX;
end;

//Расчет расстояния от низа решетки до оси опоры (гориз.), размер F.
function CalcAxeDistanceX(const HorizLength: Double): Double;
begin
  Result := HorizLength - BetwDischargeAndAxeX;
end;

//Расчет радиуса поворота решетки.
function CalcTurningRadius(const AxeDistanceX, AxeDistanceY: Double): Double;
begin
  Result := (AxeDistanceX ** 2 + AxeDistanceY ** 2) ** 0.5;
end;

//Расчет длины решетки.
function CalcScreenLength(const DiffTeeth: Integer): Double;
begin
  Result := StartScreenLength + DiffTeeth * TeethStep;
end;

//Расчет толщин пластиковых пластин.
function CalcPlasticS(const SumPlasticS: TDiapason): TPlatesSet;
var
  I: Integer;
  IsFound: Boolean;
begin
  Result := Default(TPlatesSet);
  IsFound := False;
  I := 0;
  while (I <= High(ThicknessPlastic)) and (not IsFound) do
  begin
    if (SumPlasticS[0] <= ThicknessPlastic[I].Summa) and
      (ThicknessPlastic[I].Summa <= SumPlasticS[1]) then
    begin
      Result := ThicknessPlastic[I].Sheets;
      IsFound := True;
    end;
    Inc(I);
  end;
end;

//Расчет зазора между боковиной и крайней пластиковой пластиной.
function CalcSidePlasticGap(const MovingPlasticS: TNullableReal;
  const StartMoving: Double): TNullableReal;
begin
  if MovingPlasticS.HasValue then
    Result.Value := StartMoving - MovingPlasticS.Value / 2;
end;

//Расчет минимального зазора между боковиной и крайней пластиной.
function CalcMinSideGap(const HavePlasticPart: Boolean;
  const SidePlasticGap: TNullableReal; const SideSteelGap: Double): Double;
begin
  if HavePlasticPart and SidePlasticGap.HasValue then
    Result := SidePlasticGap.Value
  else
    Result := SideSteelGap;
end;

//Расчет ширины сброса решетки.
function CalcDischargeWidth(const ScreenWs: Integer): Double;
begin
  Result := 0.1 * ScreenWs - 0.062;
end;

//Расчет крутящего момента привода.
function CalcMinTorque(const MovingMass: Double): Double;
const
  //Коэффициент неучтенных нагрузок.
  UnaccountedLoad = 2.3;
begin
  { До ноября 2020, задача Песина: (M + 200 кг) * 1.5
    Сейчас: M * 2.3 }
  Result := MovingMass * UnaccountedLoad * GravAcc * LeverArm;
end;

//Подбор привода решетки.
function CalcDriveUnit(const ScreenWs: Integer; const MinTorque: Double): TNullableDrive;
var
  ADriveUnits: array of TDriveUnit;
  I: Integer;
begin
  Result := Default(TNullableDrive);
  if ScreenWs <= 5 then
    ADriveUnits := DriveUnits05XX
  else
    ADriveUnits := DriveUnits;
  I := 0;
  while (I <= High(ADriveUnits)) and not Result.HasValue do
  begin
    if ADriveUnits[I].Torque >= MinTorque then
      Result.Value := ADriveUnits[I];
    Inc(I);
  end;
end;

//Расчет расстояния между крайними балками неподвижного полотна.
function CalcBetweenExtremeFixedBeams(const DiffTeeth: Integer): Double;
begin
  Result := BetwExtremeFixedBeams + TeethStep * DiffTeeth;
end;

//Расчет расстояния между крайними балками подвижного полотна.
function CalcBetweenExtremeMovingBeams(const DiffTeeth: Integer): Double;
begin
  Result := BetwExtremeMovingBeams + TeethStep * DiffTeeth;
end;

//Расчет количества неподвижных поперечных балок.
function CalcFixingBeamNumber(const HavePlasticPart: Boolean;
  const BetweenExtremeFixedBeams: Double): Integer;
const
  //Примерный шаг между балками
  BeamStep = 0.8;
begin
  if HavePlasticPart then
    Result := Round(BetweenExtremeFixedBeams / 2 / BeamStep) + 3;
  Result := Round(BetweenExtremeFixedBeams / BeamStep) + 1;
end;

//Расчет количества подвижных поперечных балок.
function CalcMovingBeamNumber(const HavePlasticPart: Boolean): Integer;
begin
  if HavePlasticPart then
    Result := 4
  else
    Result := 2;
end;

//Расчет массы опоры решетки.
function CalcMassSupport(const DischargeHeight: Double): Double;
begin
  Result := 16.961 * DischargeHeight + 7.396;
end;

//Расчет массы датчика штыревого.
function CalcMassPinSensor(const ChannelHeight: Double): Double;
begin
  Result := 0.3 * ChannelHeight + 0.805;
end;

//Расчет массы узла привода (без самого привода).
function CalcMassDriveSupport(const ScreenWs: Integer): Double;
begin
  Result := 3.63429 * ScreenWs + 56.3043;
end;

//Расчет массы кожуха сброса.
function CalcMassChute(const ScreenWs: Integer): Double;
begin
  Result := 1.02857 * ScreenWs + 1.67857;
end;

//Расчет массы узла подачи воздуха.
function CalcMassAirSupply(const ScreenWs: Integer): Double;
begin
  Result := 0.0471429 * ScreenWs + 2.37714;
end;

//Расчет массы узла взмучивания.
function CalcMassStirringUp(const ScreenWs: Integer): Double;
begin
  Result := 0.115714 * ScreenWs + 0.155714;
end;

//Расчет массы передней крышки (нижней).
function CalcMassFrontCover00(const ScreenWs: Integer): Double;
begin
  Result := 0.72 * ScreenWs - 1.54;
end;

//Расчет массы передней крышки (верхней).
function CalcMassFrontCover01(const ScreenWs: Integer): Double;
begin
  Result := 1.12 * ScreenWs + 0.78;
end;

//Расчет массы верхней крышки.
function CalcMassTopCover(const ScreenWs: Integer): Double;
begin
  Result := 0.572857 * ScreenWs + 0.802857;
end;

//Расчет массы задней крышки.
function CalcMassBackCover(const ScreenWs: Integer): Double;
begin
  Result := 0.618571 * ScreenWs + 0.788571;
end;

//Расчет массы нижней балки крепления верхней крышки.
function CalcMassTopCoverFixingBeam(const ScreenWs: Integer): Double;
begin
  Result := 0.167143 * ScreenWs + 0.167143;
end;

//Расчет массы нижней балки крепления передней крышки (нижней).
function CalcMassFrontCover00FixingBeam(const ScreenWs: Integer): Double;
begin
  Result := 0.191429 * ScreenWs + 0.211429;
end;

//Расчет массы нижней балки крепления передней крышки (верхней).
function CalcMassFrontCover01FixingBeam(const ScreenWs: Integer): Double;
begin
  Result := 0.265714 * ScreenWs + 0.155714;
end;

//Расчет массы нижней заслонки.
function CalcMassBottomFlap(const ScreenWs: Integer): Double;
begin
  Result := 0.105714 * ScreenWs - 0.0842857;
end;

//Расчет массы прижима неподвижных ламелей.
function CalcMassFixingPlatesClip(const ScreenWs: Integer): Double;
begin
  Result := 0.428571 * ScreenWs - 0.371429;
end;

//Расчет массы прижима подвижных ламелей.
function CalcMassMovingPlatesClip(const ScreenWs: Integer): Double;
begin
  Result := 0.435714 * ScreenWs - 0.334286;
end;

//Расчет массы гребенки для крепления неподвижных пластин.
function CalcMassBottonRake(const ScreenWs: Integer): Double;
begin
  Result := 0.175714 * ScreenWs - 0.164286;
end;

//Расчет массы нижней балки рамы (опора на дно канала) + муфта и ребра.
function CalcMassBottomFrameBeam(const ScreenWs: Integer): Double;
const
  CouplingMass = 0.22;
var
  BottomFrameBeamMass: Double;
begin
  BottomFrameBeamMass := 0.405714 * ScreenWs - 0.284286;
  Result := BottomFrameBeamMass + CouplingMass;
end;

//Расчет массы средней балки рамы (перемычка).
function CalcMassMiddleFrameBeam(const ScreenWs: Integer): Double;
begin
  Result := 0.534286 * ScreenWs - 0.365714;
end;

//Расчет массы верхней балки рамы (крепление клеммной коробки).
function CalcMassTopFrameBeam(const ScreenWs: Integer): Double;
begin
  Result := 0.662857 * ScreenWs + 0.0728571;
end;

//Расчет массы балки неподвижных пластин (приварная).
function CalcMassFixingPlatesBeam(const ScreenWs: Integer): Double;
begin
  Result := 0.644286 * ScreenWs - 0.505714;
end;

//Расчет массы балки подвижных пластин.
function CalcMassMovingPlatesBeam(const ScreenWs: Integer): Double;
begin
  Result := 0.648571 * ScreenWs + 3.34857;
end;

//Расчет массы боковины (вместе с деталями рамы).
function CalcMassSidewall(const ScreenHs: Integer): Double;
begin
  Result := 2.56889 * ScreenHs + 37.32;
end;

//Расчет массы коромысла.
function CalcMassParallelogramBeam(const ScreenHs: Integer): Double;
begin
  Result := 0.785556 * ScreenHs + 6.39;
end;

//Расчет массы продольной балки подвижного полотна.
function CalcMassMovingLengthwiseBeam(const ScreenHs: Integer): Double;
begin
  Result := 1.15667 * ScreenHs + 4.45;
end;

//Расчет массы стальной части неподвижной пластины.
function CalcMassFixedPlateSteelPart(const FixedSteelS: Double;
  const SteelFixedTeethNumber: Integer): Double;
begin
  Result := 75 * FixedSteelS * SteelFixedTeethNumber + 215 * FixedSteelS;
end;

//Расчет массы пластиковой части неподвижной пластины.
function CalcMassFixedPlatePlasticPart(const FixedPlasticS: TNullableReal;
  const ApproximatePlasticS: Double; const PlasticFixedTeethNumber: Integer): Double;
var
  AFixedPlasticS: Double;
begin
  if FixedPlasticS.HasValue then
    AFixedPlasticS := FixedPlasticS.Value
  else
    AFixedPlasticS := ApproximatePlasticS;
  Result := 8.88889 * AFixedPlasticS * PlasticFixedTeethNumber +
    14.4444 * AFixedPlasticS;
end;

//Расчет массы стальной части подвижной пластины.
function CalcMassMovingPlateSteelPart(const MovingSteelS: Double;
  const SteelMovingTeethNumber: Integer): Double;
begin
  Result := 73.3333 * MovingSteelS * SteelMovingTeethNumber + 230 * MovingSteelS;
end;

//Расчет массы полностью стальной неподвижной пластины.
function CalcMassFullSteelFixedPlate(const FixedSteelS: Double;
  const FullTeethNumber: Integer): Double;
begin
  Result := 73.3333 * FixedSteelS * FullTeethNumber + 653.333 * FixedSteelS;
end;

//Расчет массы полностью стальной подвижной пластины.
function CalcMassFullSteelMovingPlate(const MovingSteelS: Double;
  const FullTeethNumber: Integer): Double;
begin
  Result := 73.3333 * MovingSteelS * FullTeethNumber + 613.333 * MovingSteelS;
end;

//Расчет массы пластиковой части подвижной пластины.
function CalcMassMovingPlatePlasticPart(const MovingPlasticS: TNullableReal;
  const ApproximatePlasticS: Double; const PlasticMovingTeethNumber: Integer): Double;
var
  AMovingPlasticS: Double;
begin
  if MovingPlasticS.HasValue then
    AMovingPlasticS := MovingPlasticS.Value
  else
    AMovingPlasticS := ApproximatePlasticS;
  Result := 6.66667 * AMovingPlasticS * PlasticMovingTeethNumber +
    40 * AMovingPlasticS;
end;

//Расчет толщины дистанционеров.
function CalcLimiterS(const MainSteelGap: Double): Double;
begin
  Result := Mm(Trunc(ToMm(MainSteelGap)));
end;

//Расчет массы нижнего дистанционера (накладка).
function CalcMassBottomPlateLimiter(const LimiterS: Double): Double;
begin
  Result := 110 * LimiterS - 0.01;
end;

//Расчет массы боковой крышки.
function CalcMassSideCover(const DischargeHeight: Double): Double;
begin
  Result := 8.67532 * DischargeHeight + 12.498;
end;

//Расчет массы основного дистанционера (полоса).
function CalcMassMainPlateLimiter(const LimiterS: Double): Double;
begin
  Result := 15 * LimiterS + 0.005;
end;

//Расчет массы рукава подачи воздуха.
function CalcMassHose(const ScreenHs: Integer): Double;
begin
  Result := 0.06 * ScreenHs + 0.27;
end;

//Расчет массы зашитного экрана (резина + прижимные планки).
function CalcMassRubberScreen(const ChannelHeight: Double): Double;
begin
  Result := 2.94 * ChannelHeight - 0.361;
end;

//Расчет массы нижнего склиза (закрытое исполнение).
function CalcMassBackBottomCover(const ScreenWs: Integer;
  const DischargeHeight: Double): Double;
begin
  Result := 1.53726 * ScreenWs * DischargeHeight + 0.0213454 *
    ScreenWs + 4.82597 * DischargeHeight - 2.0444;
end;

//Подбор количества впадин зубьев на пластинах.
function CalcFullTeethNumber(const DiffTeeth: Integer): Integer;
begin
  Result := TeethXX21 + DiffTeeth;
end;

//Расчет количества впадин зубьев на стальных неподвижных
function CalcSteelFixedTeethNumber(const ChannelHeight: Double): Integer;
begin
  Result := Round(0.014 * ToMm(ChannelHeight) - 5.1);
end;

//Расчет количества впадин зубьев на пластиковых неподвижных пластинах.
function CalcPlasticFixedTeethNumber(
  const FullTeethNumber, SteelFixedTeethNumber: Integer): Integer;
begin
  Result := FullTeethNumber - SteelFixedTeethNumber;
end;

//Расчет количества впадин зубьев на стальных подвижных пластинах.
function CalcSteelMovingTeethNumber(const SteelFixedTeethNumber: Integer): Integer;
begin
  Result := SteelFixedTeethNumber + 2;
end;

//Расчет количества впадин зубьев на пластиковых подвижных пластинах.
function CalcPlasticMovingTeethNumber(
  const FullTeethNumber, SteelMovingTeethNumber: Integer): Integer;
begin
  Result := FullTeethNumber - SteelMovingTeethNumber;
end;

//Расчет количества дистанционеров на неподвижных пластинах (с одной стороны).
function CalcLimitersNumber(const HavePlasticPart: Boolean;
  const FullTeethNumber, SteelFixedTeethNumber: Integer): Integer;
var
  SteelTeethNumber: Integer;
begin
  if HavePlasticPart then
    SteelTeethNumber := SteelFixedTeethNumber
  else
    SteelTeethNumber := FullTeethNumber;
  Result := Trunc(0.333333 * SteelTeethNumber - 0.333333);
end;

//Расчет массы подвижной части.
function CalcMovingMass(const Weights: TStepScreenMass;
  const MovingBeamNumber, MovingPlatesNumber: Integer;
  const HavePlasticPart: Boolean): Double;
const
  //Остатки подвижного полотна
  OddmentsWeight = 5.78;
var
  MassWoPlates: Double;
begin
  MassWoPlates := OddmentsWeight
    + Weights.FixingStrip * 4
    + Weights.PitmanArm * 2
    + Weights.MovingPlatesBeam * MovingBeamNumber
    + Weights.MovingPlatesClip * MovingBeamNumber
    + Weights.MovingLengthwiseBeam * 2
    + Weights.ParallelogramBeam * 2
    + Weights.ConnectingRod * 8;
  if HavePlasticPart then
    Result := MassWoPlates
      + Weights.MovingPlateSteelPart.Value * MovingPlatesNumber
      + Weights.MovingPlatePlasticPart.Value * MovingPlatesNumber
  else
    Result := MassWoPlates
      + Weights.FullSteelMovingPlate.Value * MovingPlatesNumber;
end;

//Расчет массы решетки.
function CalcFullMass(const Weights: TStepScreenMass;
  const FixingBeamNumber, FixedPlatesNumber, LimitersNumber: Integer;
  const HavePlasticPart: Boolean; const MovingMass: Double;
  const DriveUnit: TNullableDrive): Double;
const
  // Остатки общей сборки
  OddmentsWeight = 2.73;
var
  FixedPlatesMass: Double;
begin
  if HavePlasticPart then
    FixedPlatesMass := FixedPlatesNumber * (Weights.FixedPlateSteelPart.Value +
      Weights.FixedPlatePlasticPart.Value)
  else
    FixedPlatesMass := FixedPlatesNumber * Weights.FullSteelFixedPlate.Value;
  Result := MovingMass + FixedPlatesMass + OddmentsWeight
    + Weights.PushButtonPost
    + Weights.Support * 2
    + Weights.PinSensor
    + Weights.Anchors
    + Weights.DriveSupport
    + Weights.Chute
    + Weights.AirSupply
    + Weights.StirringUp * 2
    + Weights.FrontCover00
    + Weights.FrontCover01
    + Weights.TopCover
    + Weights.BackCover
    + Weights.TopCoverFixingBeam
    + Weights.FrontCover00FixingBeam
    + Weights.FrontCover01FixingBeam
    + Weights.SideCover * 2
    + Weights.BackBottomCover
    + Weights.TerminalBox
    + Weights.Crank * 2
    + Weights.BottomFlap
    + Weights.BottonRake
    + Weights.FixingPlatesClip * FixingBeamNumber
    + Weights.FixingPlatesBeam * FixingBeamNumber
    + Weights.BottomFrameBeam
    + Weights.MiddleFrameBeam
    + Weights.TopFrameBeam
    + Weights.Sidewall * 2
    + Weights.BottomPlateLimiter * FixedPlatesNumber * 2
    + Weights.MainPlateLimiter * FixedPlatesNumber * 2 * LimitersNumber
    + Weights.Hose * 2
    + Weights.RubberScreen * 2;
  if DriveUnit.HasValue then
    Result := Result + DriveUnit.Value.Mass;
end;

//Расчет массы решетки.
function CalcMass(const Scr: TStepScreen): TStepScreenMass;
begin
  Result := Default(TStepScreenMass);

  Result.PushButtonPost := 3.9;
  Result.Support := CalcMassSupport(Scr.DischargeHeight);
  Result.PinSensor := CalcMassPinSensor(Scr.ChannelHeight);
  Result.Anchors := 2.54;
  Result.DriveSupport := CalcMassDriveSupport(Scr.ScreenWs);
  Result.Chute := CalcMassChute(Scr.ScreenWs);
  Result.AirSupply := CalcMassAirSupply(Scr.ScreenWs);
  Result.StirringUp := CalcMassStirringUp(Scr.ScreenWs);
  Result.PitmanArm := 24.7;
  Result.FrontCover00 := CalcMassFrontCover00(Scr.ScreenWs);
  Result.FrontCover01 := CalcMassFrontCover01(Scr.ScreenWs);
  Result.TopCover := CalcMassTopCover(Scr.ScreenWs);
  Result.BackCover := CalcMassBackCover(Scr.ScreenWs);
  Result.TopCoverFixingBeam := CalcMassTopCoverFixingBeam(Scr.ScreenWs);
  Result.FrontCover00FixingBeam := CalcMassFrontCover00FixingBeam(Scr.ScreenWs);
  Result.FrontCover01FixingBeam := CalcMassFrontCover01FixingBeam(Scr.ScreenWs);
  Result.FixingStrip := 0.35;
  Result.TerminalBox := 5.95;
  Result.ConnectingRod := 2.5;
  Result.Crank := 4.82;
  Result.BottomFlap := CalcMassBottomFlap(Scr.ScreenWs);
  Result.FixingPlatesClip := CalcMassFixingPlatesClip(Scr.ScreenWs);
  Result.MovingPlatesClip := CalcMassMovingPlatesClip(Scr.ScreenWs);
  Result.BottonRake := CalcMassBottonRake(Scr.ScreenWs);
  Result.BottomFrameBeam := CalcMassBottomFrameBeam(Scr.ScreenWs);
  Result.MiddleFrameBeam := CalcMassMiddleFrameBeam(Scr.ScreenWs);
  Result.TopFrameBeam := CalcMassTopFrameBeam(Scr.ScreenWs);
  Result.FixingPlatesBeam := CalcMassFixingPlatesBeam(Scr.ScreenWs);
  Result.MovingPlatesBeam := CalcMassMovingPlatesBeam(Scr.ScreenWs);
  Result.Sidewall := CalcMassSidewall(Scr.ScreenHs);
  Result.ParallelogramBeam := CalcMassParallelogramBeam(Scr.ScreenHs);
  Result.MovingLengthwiseBeam := CalcMassMovingLengthwiseBeam(Scr.ScreenHs);
  Result.BottomPlateLimiter := CalcMassBottomPlateLimiter(Scr.LimiterS);
  Result.MainPlateLimiter := CalcMassMainPlateLimiter(Scr.LimiterS);
  Result.SideCover := CalcMassSideCover(Scr.DischargeHeight);
  Result.BackBottomCover := CalcMassBackBottomCover(Scr.ScreenWs, Scr.DischargeHeight);
  Result.Hose := CalcMassHose(Scr.ScreenHs);
  Result.RubberScreen := CalcMassRubberScreen(Scr.ChannelHeight);

  if Scr.HavePlasticPart then
  begin
    Result.FixedPlateSteelPart.Value :=
      CalcMassFixedPlateSteelPart(Scr.FixedSteelS, Scr.SteelFixedTeethNumber);
    Result.FixedPlatePlasticPart.Value :=
      CalcMassFixedPlatePlasticPart(Scr.FixedPlasticS, Scr.ApproximatePlasticS,
      Scr.PlasticFixedTeethNumber);
    Result.MovingPlateSteelPart.Value :=
      CalcMassMovingPlateSteelPart(Scr.MovingSteelS, Scr.SteelMovingTeethNumber);
    Result.MovingPlatePlasticPart.Value :=
      CalcMassMovingPlatePlasticPart(Scr.MovingPlasticS, Scr.ApproximatePlasticS,
      Scr.PlasticMovingTeethNumber);
  end
  else
  begin
    Result.FullSteelFixedPlate.Value :=
      CalcMassFullSteelFixedPlate(Scr.FixedSteelS, Scr.FullTeethNumber);
    Result.FullSteelMovingPlate.Value :=
      CalcMassFullSteelMovingPlate(Scr.MovingSteelS, Scr.FullTeethNumber);
  end;
end;

function CreateEquationFile(const Scr: TStepScreen): string;
const
  //Болты крепления пластин: примерное расстояние от боковины до крайнего болта
  PmbApproxStart = 0.04;
  //Болты крепления пластин: максимальный шаг болтов
  PmbMaxStep = 0.284;
  //Болты крепления пластин: округление шага болтов
  PmbRoundBase = 0.01;
  //Болты сброса: максимальный шаг между болтами
  DpbMaxStep = 0.25;
var
  List: TStringList;
  PmbApproxWorkWidth, PmbFloatNumber, PmbStep, PmbStart,
  DpbStep, DpbMaxSize, DpcMaxSize, DpcStep: Double;

  PmbIntNumber, PmbNumber, DpbCount, DpcCount: Integer;
begin
  List := TStringList.Create;
  //Болты крепления пластин: примерное расстояние между крайними болтами
  PmbApproxWorkWidth := Scr.InnerScreenWidth - 2 * PmbApproxStart;
  //Болты крепления пластин: дробное количестов шагов между болтами
  PmbFloatNumber := PmbApproxWorkWidth / PmbMaxStep;
  //Болты крепления пластин: количестов шагов между болтами, округленное в меньшую сторону
  PmbIntNumber := Trunc(PmbFloatNumber);
  //Болты крепления пластин: количество болтов
  if PmbFloatNumber > PmbIntNumber then
    PmbNumber := PmbIntNumber + 2
  else
    PmbNumber := PmbIntNumber + 1;
  //Болты крепления пластин: шаг между болтами
  PmbStep := RoundMultiple(PmbApproxWorkWidth / (PmbNumber - 1), PmbRoundBase);
  //Болты крепления пластин: расстояние от боковины до крайнего болта
  PmbStart := (Scr.InnerScreenWidth - PmbStep * (PmbNumber - 1)) / 2;
  //Болты сброса: примерное расстояние между крайними болтами
  DpbMaxSize := Scr.InnerScreenWidth - 0.045;
  //Болты сброса: количество болтов
  DpbCount := Ceil(DpbMaxSize / DpbMaxStep) + 1;
  //Болты сброса: шаг между болтами
  DpbStep := RoundTo(DpbMaxSize / (DpbCount - 1), -3);
  //Болты сброса: расстояние между крайними болтами
  DpbMaxSize := (DpbCount - 1) * DpbStep;
  //Крышка сброса: расстояние между крайними болтами
  DpcMaxSize := Scr.InnerScreenWidth - 0.103;
  //Крышка сброса: количество болтов (в длину)
  DpcCount := Ceil(DpcMaxSize / 0.55) + 1;
  //Крышка сброса: шаг между болтами (в длину)
  DpcStep := DpcMaxSize / (DpcCount - 1);

  List.AddStrings([Format(
    '"inner_width" = %Smm  ''Внутренняя ширина решетки',
    [FormatFloat('0.###', ToMm(Scr.InnerScreenWidth), TrueDefaultFormatSettings)]),

    Format('"thickness_fixed" = %Smm  ''Толщина стальной неподвижной пластины',
    [FormatFloat('0.###', ToMm(Scr.FixedSteelS), TrueDefaultFormatSettings)]),

    Format('"thickness_moving" = %Smm  ''Толщина стальной подвижной пластины',
    [FormatFloat('0.###', ToMm(Scr.MovingSteelS), TrueDefaultFormatSettings)]),

    Format('"main_gap" = %Smm  ''Прозор между пластинами',
    [FormatFloat('0.###', ToMm(Scr.MainSteelGap), TrueDefaultFormatSettings)]),

    Format('"teeth_number" = %D  ''Количество зубьев пластин (для массива)',
    [Scr.FullTeethNumber])]);

  if Scr.FixedPlasticS.HasValue then
    List.Add(Format(
      '"plastic_fixed" = %Smm  ''Толщина пластиковой неподвижной пластины',
      [FormatFloat('0.###', ToMm(Scr.FixedPlasticS.Value), TrueDefaultFormatSettings)]));

  if Scr.MovingPlasticS.HasValue then
    List.Add(Format(
      '"plastic_moving" = %Smm  ''Толщина пластиковой подвижной пластины',
      [FormatFloat('0.###', ToMm(Scr.MovingPlasticS.Value), TrueDefaultFormatSettings)]));

  List.AddStrings([
    Format('"step" = %Smm  ''Шаг между пластинами одного полотна',
    [FormatFloat('0.###', ToMm(Scr.PlatesStep), TrueDefaultFormatSettings)]),

    Format('"number_fixed" = %D  ''Кол-во неподвижных пластин',
    [Scr.FixedPlatesNumber]),

    Format('"number_moving" = %D  ''Кол-во подвижных пластин',
    [Scr.MovingPlatesNumber]),

    Format('"side_gap" = %Smm  ''Зазор между боковиной и крайней пластиной',
    [FormatFloat('0.###', ToMm(Scr.SideSteelGap), TrueDefaultFormatSettings)]),

    Format('"start_fixed" = %Smm  ''Расстояние от боковины до середины неподвижной пластины',
    [FormatFloat('0.###', ToMm(Scr.StartFixed), TrueDefaultFormatSettings)]),

    Format('"start_moving" = %Smm  ''Расстояние от боковины до середины подвижной пластины',
    [FormatFloat('0.###', ToMm(Scr.StartMoving), TrueDefaultFormatSettings)]),

    Format('"gap_limiter_thickness" = %Smm  ''Толщина дистанционера пластин',
    [FormatFloat('0.###', ToMm(Scr.LimiterS), TrueDefaultFormatSettings)]),

    Format('"pmb_number" = %D  ''Болты крепления пластин: количество болтов',
    [PmbNumber]),

    Format('"pmb_step" = %Smm  ''Болты крепления пластин: шаг между болтами',
    [FormatFloat('0.###', ToMm(PmbStep), TrueDefaultFormatSettings)]),

    Format('"pmb_start" = %Smm  ''Болты крепления пластин: расстояние от боковины до крайнего болта',
    [FormatFloat('0.###', ToMm(PmbStart), TrueDefaultFormatSettings)]),

    Format('"dpb_max_size" = %Smm  ''Болты сброса: расстояние между крайними болтами',
    [FormatFloat('0.###', ToMm(DpbMaxSize), TrueDefaultFormatSettings)]),

    Format('"dpb_count" = %D  ''Болты сброса: количество болтов',
    [DpbCount]),

    Format('"dpb_step" = %Smm  ''Болты сброса: шаг между болтами',
    [FormatFloat('0.###', ToMm(DpbStep), TrueDefaultFormatSettings)]),

    Format('"dpc_step" = %Smm  ''Крышка сброса: шаг между болтами (в длину)',
    [FormatFloat('0.###', ToMm(DpcStep), TrueDefaultFormatSettings)]),

    Format('"dpc_count" = %D  ''Крышка сброса: количество болтов (в длину)',
    [DpcCount])]);

  Result := TrimRight(List.Text);
  List.Free;
end;

function CalcDiffTetth(const ScreenHs: Integer): Integer;
var
  I: Integer;
  IsFound: Boolean;
begin
  I := 0;
  IsFound := False;
  while (I <= High(ScreenHeightSeries)) and (not IsFound) do
  begin
    if ScreenHeightSeries[I].Serie = ScreenHs then
    begin
      IsFound := True;
      Result := ScreenHeightSeries[I].DiffTeeth;
    end;
    Inc(I);
  end;
  Assert(IsFound);
end;

//Конструктор и одновременно расчет решетки.
function CalcManualScreen(out Scr: TStepScreen; const InputData: TInputData): string;
var
  PlasticPlates: TPlatesSet;
begin
  Scr := Default(TStepScreen);
  Result := '';

  Scr.ScreenWS := InputData.ScreenWS;
  Scr.ScreenHS := InputData.ScreenHS;
  Scr.MainSteelGap := Mm(InputData.MainSteelGapMm);
  Scr.MovingSteelS := InputData.SteelS.Moving;
  Scr.FixedSteelS := InputData.SteelS.Fixed;
  Scr.ChannelHeight := Mm(InputData.ChannelHeightMm);
  Scr.HavePlasticPart := InputData.HavePlasticPart;

  Scr.DiffTeeth := CalcDiffTetth(Scr.ScreenHs);
  Scr.DischargeFullHeight := CalcDischargeFullHeight(Scr.DiffTeeth);
  Scr.DischargeHeight := CalcDischargeHeight(Scr.DischargeFullHeight, Scr.ChannelHeight);
  if Scr.DischargeHeight < MinDischargeHeight then
    Exit('Слишком глубокий канал.');

  Scr.OuterScreenWidth := CalcOuterScreenWidth(Scr.ScreenWs);
  Scr.InnerScreenWidth := CalcInnerScreenWidth(Scr.ScreenWs);
  Scr.PlatesStep := CalcPlatesStep(Scr.FixedSteelS, Scr.MovingSteelS, Scr.MainSteelGap);
  Scr.FixedPlatesNumber := CalcFixedPlatesNumber(Scr.InnerScreenWidth,
    Scr.MovingSteelS, Scr.PlatesStep);
  Scr.MovingPlatesNumber := CalcMovingPlatesNumber(Scr.FixedPlatesNumber);
  Scr.SideSteelGap := CalcSideSteelGap(Scr.InnerScreenWidth, Scr.MovingSteelS,
    Scr.PlatesStep, Scr.FixedPlatesNumber);
  Scr.StartFixed := CalcStartFixed(Scr.SideSteelGap, Scr.MovingSteelS,
    Scr.MainSteelGap, Scr.FixedSteelS);
  Scr.StartMoving := CalcStartMoving(Scr.SideSteelGap, Scr.MovingSteelS);
  Scr.SumPlasticS := CalcSumPlasticS(Scr.PlatesStep);
  if Scr.HavePlasticPart then
  begin
    PlasticPlates := CalcPlasticS(Scr.SumPlasticS);
    Scr.MovingPlasticS.Value := PlasticPlates.Moving;
    Scr.FixedPlasticS.Value := PlasticPlates.Fixed;
    Scr.ApproximatePlasticS := CalcApproximatePlasticS(Scr.SumPlasticS);
    Scr.SidePlasticGap := CalcSidePlasticGap(Scr.MovingPlasticS, Scr.StartMoving);
  end;
  Scr.MinSideGap := CalcMinSideGap(Scr.HavePlasticPart, Scr.SidePlasticGap,
    Scr.SideSteelGap);

  Scr.ScreenHeight := CalcScreenHeight(Scr.DischargeFullHeight);
  Scr.HorizLength := CalcHorizLength(Scr.DiffTeeth);
  Scr.AxeDistanceY := CalcAxeDistanceY(Scr.DiffTeeth);
  Scr.AxeDistanceX := CalcAxeDistanceX(Scr.HorizLength);
  Scr.TurningRadius := CalcTurningRadius(Scr.AxeDistanceX, Scr.AxeDistanceY);
  Scr.ScreenLength := CalcScreenLength(Scr.DiffTeeth);
  Scr.DischargeWidth := CalcDischargeWidth(Scr.ScreenWs);

  Scr.BetweenExtremeFixedBeams := CalcBetweenExtremeFixedBeams(Scr.DiffTeeth);
  Scr.BetweenExtremeMovingBeams := CalcBetweenExtremeMovingBeams(Scr.DiffTeeth);
  Scr.FullTeethNumber := CalcFullTeethNumber(Scr.DiffTeeth);
  Scr.SteelFixedTeethNumber := CalcSteelFixedTeethNumber(Scr.ChannelHeight);
  Scr.PlasticFixedTeethNumber :=
    CalcPlasticFixedTeethNumber(Scr.FullTeethNumber, Scr.SteelFixedTeethNumber);
  Scr.SteelMovingTeethNumber := CalcSteelMovingTeethNumber(Scr.SteelFixedTeethNumber);
  Scr.PlasticMovingTeethNumber :=
    CalcPlasticMovingTeethNumber(Scr.FullTeethNumber, Scr.SteelMovingTeethNumber);
  Scr.LimitersNumber := CalcLimitersNumber(Scr.HavePlasticPart,
    Scr.FullTeethNumber, Scr.SteelFixedTeethNumber);
  Scr.LimiterS := CalcLimiterS(Scr.MainSteelGap);
  Scr.FixingBeamNumber := CalcFixingBeamNumber(Scr.HavePlasticPart,
    Scr.BetweenExtremeFixedBeams);
  Scr.MovingBeamNumber := CalcMovingBeamNumber(Scr.HavePlasticPart);
  Scr.Weights := CalcMass(Scr);
  Scr.MovingWeight := CalcMovingMass(Scr.Weights, Scr.MovingBeamNumber,
    Scr.MovingPlatesNumber, Scr.HavePlasticPart);
  Scr.MinTorque := CalcMinTorque(Scr.MovingWeight);
  Scr.DriveUnit := CalcDriveUnit(Scr.ScreenWs, Scr.MinTorque);
  Scr.Weight := CalcFullMass(Scr.Weights, Scr.FixingBeamNumber,
    Scr.FixedPlatesNumber, Scr.LimitersNumber, Scr.HavePlasticPart,
    Scr.MovingWeight, Scr.DriveUnit);

  Scr.Description := CreateDescription(Scr.ScreenWs, Scr.ScreenHs);
  Scr.EquationFile := CreateEquationFile(Scr);
end;

initialization
  //Угол наклона решетки.
  TiltAngle := DegToRad(50);

  //Шаг зубьев по вертикали.
  TeethStepY := TeethStep * Sin(TiltAngle);

  //Шаг зубьев по горизонтали.
  TeethStepX := TeethStep * Cos(TiltAngle);

  with DriveUnits05XX[0] do
  begin
    Name := 'SK9022.1-80LP';
    Mass := Kg(49);
    Power := Watt(750);
    Torque := Nm(586);
    Speed := Rpm(12);
  end;

  with DriveUnits05XX[1] do
  begin
    Name := 'SK9022.1-90SP';
    Mass := Kg(54);
    Power := Watt(1100);
    Torque := Nm(850);
    Speed := Rpm(12);
  end;

  with DriveUnits[0] do
  begin
    Name := 'SK9032.1-80LP';
    Mass := Kg(69);
    Power := Watt(750);
    Torque := Nm(562);
    Speed := Rpm(13);
  end;

  with DriveUnits[1] do
  begin
    Name := 'SK9032.1-90SP';
    Mass := Kg(73);
    Power := Watt(1100);
    Torque := Nm(815);
    Speed := Rpm(13);
  end;

  with DriveUnits[2] do
  begin
    Name := 'SK9032.1-90LP';
    Mass := Kg(75);
    Power := Watt(1500);
    Torque := Nm(1123);
    Speed := Rpm(13);
  end;

  with DriveUnits[3] do
  begin
    Name := 'SK9032.1-100LP';
    Mass := Kg(86);
    Power := Watt(2200);
    Torque := Nm(1591);
    Speed := Rpm(13);
  end;

end.
