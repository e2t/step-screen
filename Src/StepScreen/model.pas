unit Model;

{$mode ObjFPC}{$H+}

interface

uses
  Errors,
  Fgl,
  UModelPresenter;

type
  EInputDataError = class(ELoggedError);

  TWidthSeries = 5..22;
  TPlateAndSpacerRange = 0..4;

  THsData = record
    DiffTeeth: Integer;
  end;

  TMaterial = (Plastic, Steel);

  TSpacer = record
    Material: TMaterial;
    Weight: ValReal;
    Designation: String;
    S: ValReal;
  end;

  TPlateAndSpacer = record
    Fixed: ValReal;
    Moving: ValReal;
    Spacer: TMaterial;
  end;

  TInputData = record
    Ws, Hs: Integer;
    NominalGap, Depth: ValReal;
    PlateAndSpacer: TPlateAndSpacer;
    IsSteelOnly, Is60Hz: Boolean;
  end;

procedure CalcStepScreen(const Inp: TInputData; Prs: IModelPresenter);
procedure CalcAllSizes(APresenter: IModelPresenter);
procedure CalcSizeTable(APresenter: IModelPresenter);

var
  HeightSeries: specialize TFPGMap<Integer, THsData>;
  NominalGapsWithPlasticSpacers: specialize TFPGMap<valreal, TSpacer>;
  NonPlasticGaps: array [0..0] of ValReal;
  PlatesAndSpacers: array [TPlateAndSpacerRange] of TPlateAndSpacer;

implementation

uses
  FloatUtils,
  Math,
  MathUtils,
  MeasurementUtils,
  Nullable,
  Optional,
  SysUtils,
  TextError,
  TextOut;

type
  TDrive = record
    Designation: String;
    Weight, Power, Torque, Speed, Frequency: ValReal;
  end;

  TPlate = record
    S: ValReal;
    Teeth: Integer;
  end;

  TPlatePair = record
    Fixed, Moving: ValReal;
  end;

  TWeightSet = class;

  TStepScreenCalculator = class sealed
  private
    FPresenter: IModelPresenter;
    FSpacer: TSpacer;
    FSteelFixed, FSteelMoving: TPlate;
    FPlasticFixed, FPlasticMoving: specialize TOptional<TPlate>;
    FWeight: TWeightSet;
    FDrive: specialize TOptional<TDrive>;

    FWs, FHs, FAllTeeth, FFixedCount, FMovingCount, FBottomSpacerCount,
    FSpacerCount, FBeamCountFixed, FBeamCountMoving, FPmbNumber, FDpbCount,
    FDpcCount, FDpwCount: Integer;

    FPlasticSheet: specialize TFPGMap<ValReal, Integer>;

    FDepth, FOuterWidth, FInnerWidth, FOptimalStep, FStep, FGap, FBottomSpacerS,
    FFullDropHeight, FDropHeight, FSideSteelGap, FFixedStart, FMovingStart,
    FMinSideGap, FHeight, FHorizLength, FAxeX, FRadius, FLength, FDropWidth,
    FMinTorque, FPmbStep, FPmbStart, FDpbMaxSize, FDpbStep, FDpcStep, FDpwWidth,
    FDpwStep: ValReal;

    procedure CalcMovingCountAndStep(AFixedS: ValReal; out AMovCount: Integer;
      out AStep: ValReal);
    function CalcSinglePlastic: ValReal;
    function CalcDoublePlastic: TPlatePair;
    function CalcSideGap(MovingS: ValReal): ValReal;
    function CalcMinTorque: ValReal;
    procedure CalcDrive(Is60Hz: Boolean);
  public
    constructor Create(const Inp: TInputData; APresenter: IModelPresenter);
    destructor Destroy; override;
  end;

  TWeightSet = class sealed
  private
    FButtonPost, FSupport, FPinSensor, FAnchors, FDriveSupport, FChute,
    FAirSupply, FStirringUp, FFrontCover00, FFrontCover01, FTopCover,
    FBackCover, FTopCoverFixedBeam, FFrontCover00FixedBeam,
    FFrontCover01FixedBeam, FTerminalBox, FCrank, FBottomFlap, FPlateClipFixed,
    FBottomRake, FBottomFrameBeam, FMiddleFrameBeam, FTopFrameBeam,
    FPlateBeamFixed, FSideWall, FSideCover, FBackBottomCover, FHose,
    FRubberScreen, FFixedPlates, FMovingPlates, FPlastic, FMoving, FFull,
    FPlateless: ValReal;

    procedure CalcFull(const AScr: TStepScreenCalculator);
  public
    constructor Create(const AScr: TStepScreenCalculator);
  end;

const
  TeethXX21 = 41;

var
  DoublePlasticPlates: specialize TFPGMap<ValReal, TPlatePair>;
  SinglePlasticPlates: specialize TFPGMap<ValReal, ValReal>;
  DriveUnits50Hz05XX, DriveUnits60Hz05XX: array [0..1] of TDrive;
  DriveUnits50Hz, DriveUnits60Hz: array [0..3] of TDrive;

  LeverArm, TeethStep, BetwDischargeAndTop, BetwDischargeAndAxeX,
  BetwExtremeFixedBeams, BetwExtremeMovingBeams, StartFullDropHeight,
  StartHorizLength, StartScreenLength, StartAxeHeight, MinDischargeHeight,
  SteelGapMin, PlasticGapMin, PlasticGapMax, PlateHeight, PlasticSheetWidth,
  PlasticSheetLength, PlatesPerSheet, TiltAngle, TeethStepY, TeethStepX,
  FixedBeamStep, MovingBeamStep: ValReal;

procedure AddHeightSerie(Hs: Integer; DiffTeeth: Integer);
var
  X: THsData;
begin
  X.DiffTeeth := DiffTeeth;
  HeightSeries.Add(Hs, X);
end;

procedure AddGapAndSpacer(Gap: ValReal; Material: TMaterial; Weight: ValReal;
  Designation: String; Thickness: ValReal);
var
  X: TSpacer;
begin
  X.Material := Material;
  X.Weight := Weight;
  X.Designation := Designation;
  X.S := Thickness;
  NominalGapsWithPlasticSpacers.Add(Gap, X);
end;

procedure AddPlatePair(Summa, Fixed, Moving: ValReal);
var
  X: TPlatePair;
begin
  X.Fixed := Fixed;
  X.Moving := Moving;
  DoublePlasticPlates.Add(Summa, X);
end;

procedure CalcAllSizes(APresenter: IModelPresenter);
const
  FalseTrue: array of Boolean = (False, True);
var
  I: Integer;
  Count: Integer = 0;
  Gaps: array of ValReal = nil;
  Gap: ValReal;
  Scr: TStepScreenCalculator;
  Inp: TInputData;
begin
  SetLength(Gaps, NominalGapsWithPlasticSpacers.Count + Length(NonPlasticGaps));
  for I := 0 to NominalGapsWithPlasticSpacers.Count - 1 do
    Gaps[I] := NominalGapsWithPlasticSpacers.Keys[I];
  for Gap in NonPlasticGaps do begin
    Inc(I);
    Gaps[I] := Gap;
  end;

  for I := 0 to HeightSeries.Count - 1 do begin
    Inp.Hs := HeightSeries.Keys[I];
    Inp.Depth := Inp.Hs * 0.1;
    for Inp.Ws in TWidthSeries do
      for Inp.NominalGap in Gaps do
        for Inp.PlateAndSpacer in PlatesAndSpacers do
          for Inp.IsSteelOnly in FalseTrue do
            for Inp.Is60Hz in FalseTrue do begin
              try
                Scr := TStepScreenCalculator.Create(Inp, APresenter);
                Inc(Count);
              except
                on EInputDataError do ;
              end;
              FreeAndNil(Scr);
            end;
  end;
  APresenter.AddOutput(Format('Processed %d configuration.', [Count]));
end;

procedure CalcSizeTable(APresenter: IModelPresenter);
var
  I: Integer;
  Scr: TStepScreenCalculator;
  Inp: TInputData;
begin
  Inp.NominalGap := NominalGapsWithPlasticSpacers.Keys[0];
  Inp.PlateAndSpacer := PlatesAndSpacers[0];
  Inp.IsSteelOnly := False;
  Inp.Is60Hz := False;

  { XXSerie }
  Inp.Hs := 21;
  Inp.Depth := Inp.Hs * 0.1;
  APresenter.AddOutput('Size'#9'A'#9'B'#9'G');
  for Inp.Ws in TWidthSeries do begin
    try
      Scr := TStepScreenCalculator.Create(Inp, APresenter);
      APresenter.AddOutput(Format('%0.2dYY'#9'%s'#9'%s'#9'%s',
        [Scr.FWs,
        FStr(FromSI('mm', Scr.FInnerWidth)),
        FStr(FromSI('mm', Scr.FOuterWidth)),
        FStr(FromSI('mm', Scr.FDropWidth))]));
    except
      on EInputDataError do ;
    end;
    FreeAndNil(Scr);
  end;

  APresenter.AddOutput('');

  { YYSerie }
  Inp.Ws := 10;
  APresenter.AddOutput('Size'#9'L'#9'R'#9'H2'#9'H1'#9'F'#9'D');
  for I := 0 to HeightSeries.Count - 1 do begin
    Inp.Hs := HeightSeries.Keys[I];
    Inp.Depth := Inp.Hs * 0.1;
    try
      Scr := TStepScreenCalculator.Create(Inp, APresenter);
      APresenter.AddOutput(Format('XX%0.2d'#9'%s'#9'%s'#9'%s'#9'%s'#9'%s'#9'%s',
        [Scr.FHs,
        FStr(FromSI('mm', Scr.FLength), 0),
        FStr(FromSI('mm', Scr.FRadius), 0),
        FStr(FromSI('mm', Scr.FHeight), 0),
        FStr(FromSI('mm', Scr.FFullDropHeight), 0),
        FStr(FromSI('mm', Scr.FAxeX), 0),
        FStr(FromSI('mm', Scr.FHorizLength), 0)]));
    except
      on EInputDataError do ;
    end;
    FreeAndNil(Scr);
  end;
end;

function NewSteelSpacer(Gap: ValReal): TSpacer;
var
  Weight: ValReal;
begin
  Weight := SI(13583.3333 * Gap + 0.01, 'gram');
  Result.Material := Steel;
  Result.Weight := Weight;
  Result.S := Gap;
  Result.Designation := '';
end;

procedure CalcStepScreen(const Inp: TInputData; Prs: IModelPresenter);
var
  Scr: TStepScreenCalculator;
  I: Integer;
begin
  Scr := TStepScreenCalculator.Create(Inp, Prs);
  Prs.AddOutput(TextOutRskGapDepth, [Scr.FWs, Scr.FHs,
    FStr(FromSI('mm', Scr.FGap), -2),
    FStr(FromSI('mm', Scr.FSteelFixed.S)),
    FStr(FromSI('mm', Scr.FSteelMoving.S)),
    FStr(FromSI('mm', Scr.FDepth))]);
  if Scr.FDrive.HasValue then begin
    Prs.AddOutput(TextOutWeight, [FStr(Scr.FWeight.FFull, 0)]);
    Prs.AddOutput(TextOutDrive, [Scr.FDrive.Value.Designation,
      FStr(FromSI('kW', Scr.FDrive.Value.Power)),
      FStr(Scr.FDrive.Value.Frequency),
      FStr(FromSI('rpm', Scr.FDrive.Value.Speed)),
      FStr(Scr.FDrive.Value.Torque)]);
  end
  else begin
    Prs.AddOutput(TextOutDrivelessWeight, [FStr(Scr.FWeight.FFull, 0)]);
    Prs.AddOutput(TextOutUndefDrive, []);
  end;
  Prs.AddOutput('');
  Prs.AddOutput(TextOutExtWidth, [FStr(FromSI('mm', Scr.FOuterWidth), 0)]);
  Prs.AddOutput(TextOutIntWidth, [FStr(FromSI('mm', Scr.FInnerWidth), 0)]);
  Prs.AddOutput(TextOutDropWidth, [FStr(FromSI('mm', Scr.FDropWidth), 0)]);
  Prs.AddOutput(TextOutFullDropHeight, [FStr(FromSI('mm', Scr.FFullDropHeight), 0)]);
  Prs.AddOutput(TextOutDropHeight, [FStr(FromSI('mm', Scr.FDropHeight), 0)]);
  Prs.AddOutput(TextOutScrHeight, [FStr(FromSI('mm', Scr.FHeight), 0)]);
  Prs.AddOutput(TextOutScrLength, [FStr(FromSI('mm', Scr.FLength), 0)]);
  Prs.AddOutput(TextOutHorizLength, [FStr(FromSI('mm', Scr.FHorizLength), 0)]);
  Prs.AddOutput(TextOutAxeX, [FStr(FromSI('mm', Scr.FAxeX), 0)]);
  Prs.AddOutput(TextOutRadius, [FStr(FromSI('mm', Scr.FRadius), 0)]);
  Prs.AddOutput('');
  Prs.AddOutput(TextOutForDesigner, []);
  Prs.AddOutput('');
  Prs.AddOutput(TextOutMinSideGap, [FStr(FromSI('mm', Scr.FMinSideGap), -2)]);
  if Scr.FSpacer.Designation <> '' then
    Prs.AddOutput(TextOutPlasticSpacers, [Scr.FSpacerCount, Scr.FSpacer.Designation])
  else
    Prs.AddOutput(TextOutSteelSpacers, [Scr.FSpacerCount]);
  Prs.AddOutput(TextOutMovingCount, [Scr.FMovingCount]);
  Prs.AddOutput(TextOutSteelS, [FStr(FromSI('mm', Scr.FSteelMoving.S))]);
  if Scr.FPlasticMoving.HasValue then
    Prs.AddOutput(TextOutPlasticS, [FStr(FromSI('mm', Scr.FPlasticMoving.Value.S))]);
  Prs.AddOutput(TextOutFixedCount, [Scr.FFixedCount]);
  Prs.AddOutput(TextOutSteelS, [FStr(FromSI('mm', Scr.FSteelFixed.S))]);
  if Scr.FPlasticFixed.HasValue then
    Prs.AddOutput(TextOutPlasticS, [FStr(FromSI('mm', Scr.FPlasticFixed.Value.S))]);
  for I := 0 to Scr.FPlasticSheet.Count - 1 do
    Prs.AddOutput(TextOutPlasticSheet, [FStr(FromSI('mm', Scr.FPlasticSheet.Keys[I])),
      Scr.FPlasticSheet.Data[I], FStr(PlasticSheetWidth), FStr(PlasticSheetLength)]);
  Prs.AddOutput(TextOutMovingWeight, [FStr(Scr.FWeight.FMoving, 0)]);
  if IsGreater(Scr.FWeight.FPlastic, 0) then
    Prs.AddOutput(TextOutPlasticWeight, [FStr(Scr.FWeight.FPlastic, 0)]);
  Prs.AddOutput(TextOutMinTorque, [FStr(Scr.FMinTorque, 0)]);
  Prs.AddOutput('');
  Prs.AddOutput(TextOutEquationFile, []);
  Prs.AddOutput('');
  Prs.AddOutput(Format(
    '"inner_width" = %gmm  ''''Внутрішня ширина решітки',
    [FromSI('mm', Scr.FInnerWidth)]));
  Prs.AddOutput(Format(
    '"thickness_fixed" = %gmm  ''''Товщина сталевої нерухомої пластини',
    [FromSI('mm', Scr.FSteelFixed.S)]));
  Prs.AddOutput(Format(
    '"thickness_moving" = %gmm  ''''Товщина сталевої рухомої пластини',
    [FromSI('mm', Scr.FSteelMoving.S)]));
  Prs.AddOutput(Format(
    '"main_gap" = %.3fmm  ''''Прозор між пластинами',
    [FromSI('mm', Scr.FGap)]));
  Prs.AddOutput(Format(
    '"teeth_number" = %d  ''''Кількість зубів пластин (для масиву)',
    [Scr.FAllTeeth]));
  if Scr.FPlasticFixed.HasValue then
    Prs.AddOutput(Format(
      '"plastic_fixed" = %gmm  ''''Товщина пластикової нерухомої пластини',
      [FromSI('mm', Scr.FPlasticFixed.Value.S)]));
  if Scr.FPlasticMoving.HasValue then
    Prs.AddOutput(Format(
      '"plastic_moving" = %gmm  ''''Товщина пластикової рухомої пластини',
      [FromSI('mm', Scr.FPlasticMoving.Value.S)]));
  Prs.AddOutput(Format(
    '"step" = %.3fmm  ''''Крок між пластинами одного полотна',
    [FromSI('mm', Scr.FStep)]));
  Prs.AddOutput(Format(
    '"number_fixed" = %d  ''''Кількість нерухомих пластин',
    [Scr.FFixedCount]));
  Prs.AddOutput(Format(
    '"number_moving" = %d  ''''Кількість рухомих пластин',
    [Scr.FMovingCount]));
  Prs.AddOutput(Format(
    '"side_gap" = %.3fmm  ''''Зазор між боковиною та крайньою пластиною',
    [FromSI('mm', Scr.FSideSteelGap)]));
  Prs.AddOutput(Format(
    '"start_fixed" = %.3fmm  ''''Відстань від боковини до середини нерухомої пластини',
    [FromSI('mm', Scr.FFixedStart)]));
  Prs.AddOutput(Format(
    '"start_moving" = %.3fmm  ''''Відстань від боковини до середини рухомої пластини',
    [FromSI('mm', Scr.FMovingStart)]));
  if Scr.FSpacer.Designation = '' then
    Prs.AddOutput(Format(
      '"gap_limiter_thickness" = %gmm  ''''Товщина дистанційника пластин',
      [FromSI('mm', Scr.FSpacer.S)]));
  Prs.AddOutput(Format(
    '"bottom_spacer_thickness" = %gmm  ''''Товщина нижнього дистанційника',
    [FromSI('mm', Scr.FBottomSpacerS)]));
  Prs.AddOutput(Format(
    '"pmb_number" = %d  ''''Болти кріплення пластин: кількість болтів',
    [Scr.FPmbNumber]));
  Prs.AddOutput(Format(
    '"pmb_step" = %gmm  ''''Болти кріплення пластин: крок між болтами',
    [FromSI('mm', Scr.FPmbStep)]));
  Prs.AddOutput(Format(
    '"pmb_start" = %gmm  ''''Болти кріплення пластин: відстань від боковини до крайнього болта',
    [FromSI('mm', Scr.FPmbStart)]));
  Prs.AddOutput(Format(
    '"dpb_max_size" = %gmm  ''''Болти скидання: відстань між крайніми болтами',
    [FromSI('mm', Scr.FDpbMaxSize)]));
  Prs.AddOutput(Format(
    '"dpb_count" = %d  ''''Болти скидання: кількість болтів',
    [Scr.FDpbCount]));
  Prs.AddOutput(Format(
    '"dpb_step" = %gmm  ''''Болти скидання: крок між болтами',
    [FromSI('mm', Scr.FDpbStep)]));
  Prs.AddOutput(Format(
    '"dpc_step" = %smm  ''''Кришка скидання: крок між болтами (завдовжки)',
    [FStr(FromSI('mm', Scr.FDpcStep), -3)]));
  Prs.AddOutput(Format(
    '"dpc_count" = %d  ''''Кришка скидання: кількість болтів (завдовжки)',
    [Scr.FDpcCount]));
  Prs.AddOutput(Format(
    '"dpw_width" = %gmm  ''''Вікно скидання: ширина вікна',
    [FromSI('mm', Scr.FDpwWidth)]));
  Prs.AddOutput(Format(
    '"dpw_step" = %gmm  ''''Вікно скидання: крок вікон',
    [FromSI('mm', Scr.FDpwStep)]));
  Prs.AddOutput(Format(
    '"dpw_count" = %d  ''''Вікно скидання: кількість вікон',
    [Scr.FDpwCount]));
end;

function CalcPlasticSheet(PlateCount: Integer): Integer;
begin
  Result := Ceil(PlateCount / PlatesPerSheet);
end;

{ TStepScreenCalculator }

constructor TStepScreenCalculator.Create(const Inp: TInputData;
  APresenter: IModelPresenter);
var
  OptimalGap, MaxDepth, SidePlasticGap, AxeY, BetwExtremeBeamsFixed,
  BetwExtremeBeamsMoving, PmbApproxStart, PmbMaxStep, DpbMaxStep,
  PmbApproxWorkWidth, PmbFloatNumber, DpcMaxSize, DpwBridge,
  ApproxDpbMaxSize: ValReal;

  Gaps: array of String = nil;
  I, DiffTeeth, PmbIntNumber: Integer;
  DoublePlastic: TPlatePair;
begin
  FPresenter := APresenter;

  if IsLessOrEqual(Inp.Depth, 0) then begin
    FPresenter.LogError(TextErrDepth, []);
    raise ELoggedError.Create('Invalid depth');
  end;

  FWs := Inp.Ws;
  FHs := Inp.Hs;
  FDepth := Inp.Depth;

  FOuterWidth := FWs * 0.1 + 0.05;
  FInnerWidth := FWs * 0.1 - 0.07;

  if Inp.PlateAndSpacer.Spacer = Plastic then begin
    OptimalGap := Inp.NominalGap;
    if NominalGapsWithPlasticSpacers.IndexOf(Inp.NominalGap) = -1 then begin
      SetLength(Gaps, NominalGapsWithPlasticSpacers.Count);
      for I := 0 to NominalGapsWithPlasticSpacers.Count - 1 do
        Gaps[I] := FStr(FromSI('mm', NominalGapsWithPlasticSpacers.Keys[I]));
      FPresenter.LogError(TextErrNonPlasticGap, [String.Join(', ', Gaps)]);
      raise EInputDataError.Create('Invalid gap');
    end;
    FSpacer := NominalGapsWithPlasticSpacers.KeyData[Inp.NominalGap];
  end
  else begin
    OptimalGap := Inp.NominalGap + SteelGapMin;
    FSpacer := NewSteelSpacer(Inp.NominalGap);
  end;

  DiffTeeth := HeightSeries.KeyData[FHs].DiffTeeth;
  FAllTeeth := TeethXX21 + DiffTeeth;

  FSteelFixed.S := Inp.PlateAndSpacer.Fixed;
  FSteelMoving.S := Inp.PlateAndSpacer.Moving;

  FOptimalStep := 2 * OptimalGap + FSteelFixed.S + FSteelMoving.S;
  if Inp.IsSteelOnly then begin
    FSteelFixed.Teeth := FAllTeeth;
    FSteelMoving.Teeth := FAllTeeth;
    FPlasticFixed.HasValue := False;
    FPlasticMoving.HasValue := False;
    CalcMovingCountAndStep(FSteelFixed.S, FMovingCount, FStep);
  end
  else begin
    FSteelFixed.Teeth := Max(11, Round(12.53 * FDepth - 3.1415));
    FPlasticFixed.HasValue := True;
    FPlasticFixed.Value.Teeth := FAllTeeth - FSteelFixed.Teeth;
    if FHs < 9 then begin
      FSteelMoving.Teeth := FAllTeeth;
      FPlasticFixed.Value.S := CalcSinglePlastic;
      FPlasticMoving.HasValue := False;
      CalcMovingCountAndStep(FSteelFixed.S, FMovingCount, FStep);
    end
    else begin
      FSteelMoving.Teeth := FSteelFixed.Teeth + 2;
      FPlasticMoving.HasValue := True;
      FPlasticMoving.Value.Teeth := FAllTeeth - FSteelMoving.Teeth;
      DoublePlastic := CalcDoublePlastic;
      FPlasticFixed.Value.S := DoublePlastic.Fixed;
      FPlasticMoving.Value.S := DoublePlastic.Moving;
      CalcMovingCountAndStep(FPlasticFixed.Value.S, FMovingCount, FStep);
    end;
  end;
  FFixedCount := FMovingCount - 1;
  FGap := (FStep - FSteelFixed.S - FSteelMoving.S) / 2;
  FBottomSpacerS := SI(Floor(FromSI('mm', FGap - SteelGapMin)), 'mm');
  FBottomSpacerCount := FFixedCount * 2;
  FFullDropHeight := StartFullDropHeight + DiffTeeth * TeethStepY;
  FDropHeight := FFullDropHeight - FDepth;
  if IsLess(FDropHeight, MinDischargeHeight) then begin
    MaxDepth := FFullDropHeight - MinDischargeHeight;
    FPresenter.LogError(TextErrTooDeep, [FStr(Floor(FromSI('mm', MaxDepth)))]);
    raise ELoggedError.Create('Too deep channel');
  end;
  FSideSteelGap := CalcSideGap(FSteelMoving.S);
  FFixedStart := FSideSteelGap + FSteelMoving.S + FGap + FSteelFixed.S / 2;
  FMovingStart := FSideSteelGap + FSteelMoving.S / 2;
  if FPlasticMoving.HasValue then begin
    SidePlasticGap := CalcSideGap(FPlasticMoving.Value.S);
    FMinSideGap := Min(SidePlasticGap, FSideSteelGap);
  end
  else
    FMinSideGap := FSideSteelGap;
  FSpacerCount := ((FSteelFixed.Teeth - 1) div 3) * 2 * FFixedCount;
  FHeight := FFullDropHeight + BetwDischargeAndTop;
  FHorizLength := StartHorizLength + DiffTeeth * TeethStepX;
  AxeY := StartAxeHeight + DiffTeeth * TeethStepY;
  FAxeX := FHorizLength - BetwDischargeAndAxeX;
  FRadius := Sqrt(Sqr(FAxeX) + Sqr(AxeY));
  FLength := StartScreenLength + DiffTeeth * TeethStep;
  FDropWidth := 0.1 * FWs - 0.062;
  BetwExtremeBeamsFixed := BetwExtremeFixedBeams + TeethStep * DiffTeeth;
  BetwExtremeBeamsMoving := BetwExtremeMovingBeams + TeethStep * DiffTeeth;
  if FPlasticFixed.HasValue then
    FBeamCountFixed := Round(BetwExtremeBeamsFixed / FixedBeamStep / 2) + 3
  else
    FBeamCountFixed := Round(BetwExtremeBeamsFixed / FixedBeamStep) + 1;
  if FPlasticMoving.HasValue then
    FBeamCountMoving := Round(BetwExtremeBeamsMoving / MovingBeamStep / 2) + 3
  else
    FBeamCountMoving := Round(BetwExtremeBeamsMoving / MovingBeamStep) + 1;

  FPlasticSheet := specialize TFPGMap<valreal, Integer>.Create;
  if FPlasticFixed.HasValue then
    FPlasticSheet.Add(FPlasticFixed.Value.S, CalcPlasticSheet(FFixedCount));
  if FPlasticMoving.HasValue then
    if FPlasticSheet.IndexOf(FPlasticMoving.Value.S) = -1 then
      FPlasticSheet.Add(FPlasticMoving.Value.S, CalcPlasticSheet(FMovingCount))
    else
      FPlasticSheet[FPlasticMoving.Value.S] :=
        FPlasticSheet[FPlasticMoving.Value.S] + CalcPlasticSheet(FMovingCount);
  FPlasticSheet.Sort;

  FWeight := TWeightSet.Create(Self);
  FMinTorque := CalcMinTorque;
  CalcDrive(Inp.Is60Hz);
  FWeight.CalcFull(Self);

  { EQUATIONS }
  { Болты крепления пластин: примерное расстояние от боковины до крайнего болта }
  PmbApproxStart := SI(40, 'mm');
  { Болты крепления пластин: максимальный шаг болтов }
  PmbMaxStep := SI(284, 'mm');
  { Болты сброса: максимальный шаг между болтами }
  DpbMaxStep := SI(250, 'mm');
  { Болты крепления пластин: примерное расстояние между крайними болтами }
  PmbApproxWorkWidth := FInnerWidth - 2 * PmbApproxStart;
  { Болты крепления пластин: дробное количестов шагов между болтами }
  PmbFloatNumber := PmbApproxWorkWidth / PmbMaxStep;
  { Болты крепления пластин: количестов шагов между болтами, округленное
    в меньшую сторону }
  PmbIntNumber := Trunc(PmbFloatNumber);
  { Болты крепления пластин: количество болтов }
  if IsGreater(PmbFloatNumber, PmbIntNumber) then
    FPmbNumber := PmbIntNumber + 2
  else
    FPmbNumber := PmbIntNumber + 1;
  { Болты крепления пластин: шаг между болтами }
  FPmbStep := RoundTo(PmbApproxWorkWidth / (FPmbNumber - 1), -2);
  { Болты крепления пластин: расстояние от боковины до крайнего болта }
  FPmbStart := (FInnerWidth - FPmbStep * (FPmbNumber - 1)) / 2;

  { Болты сброса: примерное расстояние между крайними болтами }
  ApproxDpbMaxSize := FInnerWidth - SI(45, 'mm');
  { Болты сброса: количество болтов }
  FDpbCount := Ceil(ApproxDpbMaxSize / DpbMaxStep) + 1;
  { Болты сброса: шаг между болтами }
  FDpbStep := RoundTo(ApproxDpbMaxSize / (FDpbCount - 1), -3);
  { Болты сброса: расстояние между крайними болтами }
  FDpbMaxSize := (FDpbCount - 1) * FDpbStep;

  { Крышка сброса: расстояние между крайними болтами }
  DpcMaxSize := FInnerWidth - SI(103, 'mm');
  { Крышка сброса: количество болтов (в длину) }
  FDpcCount := Ceil(DpcMaxSize / 0.55) + 1;
  { Крышка сброса: шаг между болтами (в длину) }
  FDpcStep := DpcMaxSize / (FDpcCount - 1);

  { Окно сброса: ширина перемычки между окнами на бункере сброса }
  DpwBridge := SI(100, 'mm');
  { Окно сброса: количество окон }
  if FWs <= 12 then
    FDpwCount := 1
  else
    FDpwCount := 2;
  { Окно сброса: ширина окна }
  FDpwWidth := (FInnerWidth - 2 * SI(55, 'mm') - DpwBridge * (FDpwCount - 1))
    / FDpwCount;
  { Окно сброса: шаг окон }
  FDpwStep := FDpwWidth + DpwBridge;
end;

destructor TStepScreenCalculator.Destroy;
begin
  FreeAndNil(FPlasticSheet);
  FreeAndNil(FWeight);
end;

procedure TStepScreenCalculator.CalcMovingCountAndStep(AFixedS: ValReal;
  out AMovCount: Integer; out AStep: ValReal);
begin
  AMovCount := Floor((FInnerWidth + AFixedS) / FOptimalStep);
  AStep := (FInnerWidth + AFixedS) / AMovCount;
end;

function TStepScreenCalculator.CalcSinglePlastic: ValReal;
var
  OptimalSpace, Space, Gap: ValReal;
begin
  OptimalSpace := FOptimalStep - FSteelMoving.S - 2 * PlasticGapMin;
  Space := SI(Floor(FromSI('mm', OptimalSpace)), 'mm');
  Result := SinglePlasticPlates.KeyData[Space];
  Gap := (FOptimalStep - Result - FSteelMoving.S) / 2;
  Assert(IsLessOrEqual(Gap, PlasticGapMax));
end;

function TStepScreenCalculator.CalcDoublePlastic: TPlatePair;
var
  OptimalSpace, Space, Gap: ValReal;
begin
  OptimalSpace := FOptimalStep - 2 * PlasticGapMin;
  Space := SI(Floor(FromSI('mm', OptimalSpace)), 'mm');
  Result := DoublePlasticPlates.KeyData[Space];
  Gap := (FOptimalStep - Result.Fixed - Result.Moving) / 2;
  Assert(IsLessOrEqual(Gap, PlasticGapMax));
end;

function TStepScreenCalculator.CalcSideGap(MovingS: ValReal): ValReal;
begin
  Result := (FInnerWidth - MovingS - FStep * FFixedCount) / 2;
end;

function TStepScreenCalculator.CalcMinTorque: ValReal;
const
  UnaccountedLoad = 2.3;  { Коэффициент неучтенных нагрузок }
begin
  { До ноября 2020, задача Песина: (M + 200 кг) * 1.5
    Сейчас: M * 2.3 }
  Result := FWeight.FMoving * UnaccountedLoad * GravAcc * LeverArm;
end;

procedure TStepScreenCalculator.CalcDrive(Is60Hz: Boolean);
var
  Drives: array of TDrive;
  I: TDrive;
begin
  if Is60Hz then begin
    if FWs <= 5 then
      Drives := DriveUnits60Hz05XX
    else
      Drives := DriveUnits60Hz;
  end
  else if FWs <= 5 then
    Drives := DriveUnits50Hz05XX
  else
    Drives := DriveUnits50Hz;
  FDrive.HasValue := False;

  for I in Drives do
    if IsGreaterOrEqual(I.Torque, FMinTorque) then begin
      FDrive.Value := I;
      FDrive.HasValue := True;
      break;
    end;
end;

{ TWeightSet }

constructor TWeightSet.Create(const AScr: TStepScreenCalculator);
var
  PlasticFixed, PlasticMoving: specialize TNullable<ValReal>;

  PitmanArm, FixingStrip, ConnectingRod, PlateClipMoving, PlateBeamMoving,
  ParallelogramBeam, MovingLengthWiseBeam, BottomSpacer, SteelFixed, FixPl,
  SteelMoving, MovPl: ValReal;
begin
  FButtonPost := SI(3.9, 'kg');
  FSupport := 16.961 * AScr.FDropHeight + 7.396;
  FPinSensor := 0.3 * AScr.FDepth + 0.805;
  FAnchors := SI(2.54, 'kg');
  FDriveSupport := 3.63429 * AScr.FWs + 56.3043;
  FChute := 1.02857 * AScr.FWs + 1.67857;
  FAirSupply := 0.0471429 * AScr.FWs + 2.37714;
  FStirringUp := 0.115714 * AScr.FWs + 0.155714;
  PitmanArm := SI(24.7, 'kg');
  FFrontCover00 := 0.72 * AScr.FWs - 1.54;
  FFrontCover01 := 1.12 * AScr.FWs + 0.78;
  FTopCover := 0.572857 * AScr.FWs + 0.802857;
  FBackCover := 0.618571 * AScr.FWs + 0.788571;
  FTopCoverFixedBeam := 0.167143 * AScr.FWs + 0.167143;
  FFrontCover00FixedBeam := 0.191429 * AScr.FWs + 0.211429;
  FFrontCover01FixedBeam := 0.265714 * AScr.FWs + 0.155714;
  FixingStrip := SI(0.35, 'kg');
  FTerminalBox := SI(5.95, 'kg');
  ConnectingRod := SI(2.5, 'kg');
  FCrank := SI(4.82, 'kg');
  FBottomFlap := 0.105714 * AScr.FWs - 0.0842857;
  FPlateClipFixed := 0.428571 * AScr.FWs - 0.371429;
  PlateClipMoving := 0.435714 * AScr.FWs - 0.334286;
  FBottomRake := 0.175714 * AScr.FWs - 0.164286;
  FBottomFrameBeam := 0.405714 * AScr.FWs - 0.064286;
  FMiddleFrameBeam := 0.534286 * AScr.FWs - 0.365714;
  FTopFrameBeam := 0.662857 * AScr.FWs + 0.0728571;
  FPlateBeamFixed := 0.644286 * AScr.FWs - 0.505714;
  PlateBeamMoving := 0.648571 * AScr.FWs + 3.34857;
  FSideWall := 2.56889 * AScr.FHs + 37.32;
  ParallelogramBeam := 0.785556 * AScr.FHs + 6.39;
  MovingLengthWiseBeam := 1.15667 * AScr.FHs + 4.45;
  FSideCover := 8.67532 * AScr.FDropHeight + 12.498;
  BottomSpacer := 110 * AScr.FBottomSpacerS - 0.01;
  FBackBottomCover := 1.53726 * AScr.FWs * AScr.FDropHeight
    + 0.0213454 * AScr.FWs + 4.82597 * AScr.FDropHeight - 2.0444;
  FHose := 0.06 * AScr.FHs + 0.27;
  FRubberScreen := 2.94 * AScr.FDepth - 0.361;

  if AScr.FPlasticFixed.HasValue then begin
    SteelFixed := 75 * AScr.FSteelFixed.S * AScr.FSteelFixed.Teeth
      + 215 * AScr.FSteelFixed.S;
    PlasticFixed.Value :=
      8.88889 * AScr.FPlasticFixed.Value.S * AScr.FPlasticFixed.Value.Teeth
      + 14.4444 * AScr.FPlasticFixed.Value.S;
    FixPl := SteelFixed + PlasticFixed.Value;
  end
  else begin
    SteelFixed := 73.3333 * AScr.FSteelFixed.S * AScr.FSteelFixed.Teeth
      + 653.333 * AScr.FSteelFixed.S;
    PlasticFixed.Clear;
    FixPl := SteelFixed;
  end;
  FFixedPlates := AScr.FFixedCount * FixPl
    + AScr.FSpacerCount * AScr.FSpacer.Weight
    + BottomSpacer * AScr.FBottomSpacerCount;

  if AScr.FPlasticMoving.HasValue then begin
    SteelMoving := 73.3333 * AScr.FSteelMoving.S * AScr.FSteelMoving.Teeth
      + 230 * AScr.FSteelMoving.S;
    PlasticMoving :=
      6.66667 * AScr.FPlasticMoving.Value.S * AScr.FPlasticMoving.Value.Teeth
      + 40 * AScr.FPlasticMoving.Value.S;
    MovPl := SteelMoving + PlasticMoving.Value;
  end
  else begin
    SteelMoving := 73.3333 * AScr.FSteelMoving.S * AScr.FSteelMoving.Teeth
      + 613.333 * AScr.FSteelMoving.S;
    PlasticMoving.Clear;
    MovPl := SteelMoving;
  end;
  FMovingPlates := AScr.FMovingCount * MovPl;

  if PlasticFixed.HasValue then
    FPlastic := PlasticFixed.Value * AScr.FFixedCount
  else
    FPlastic := 0;
  if PlasticMoving.HasValue then
    FPlastic := FPlastic + PlasticMoving.Value * AScr.FMovingCount;

  FMoving := FMovingPlates
    + SI(5.78, 'kg')
    + FixingStrip * 4
    + PitmanArm * 2
    + PlateBeamMoving * AScr.FBeamCountMoving
    + PlateClipMoving * AScr.FBeamCountMoving
    + MovingLengthWiseBeam * 2
    + ParallelogramBeam * 2
    + ConnectingRod * 8;

  { After CalcFull() }
  FFull := 0;
  FPlateless := 0;
end;

procedure TWeightSet.CalcFull(const AScr: TStepScreenCalculator);
begin
  FFull := FMoving
    + FFixedPlates
    + SI(2.73, 'kg')
    + FButtonPost
    + FSupport * 2
    + FPinSensor
    + FAnchors
    + FDriveSupport
    + FChute
    + FAirSupply
    + FStirringUp * 2
    + FFrontCover00
    + FFrontCover01
    + FTopCover
    + FBackCover
    + FTopCoverFixedBeam
    + FFrontCover00FixedBeam
    + FFrontCover01FixedBeam
    + FSideCover * 2
    + FBackBottomCover
    + FTerminalBox
    + FCrank * 2
    + FBottomFlap
    + FBottomRake
    + FPlateClipFixed * AScr.FBeamCountFixed
    + FPlateBeamFixed * AScr.FBeamCountFixed
    + FBottomFrameBeam
    + FMiddleFrameBeam
    + FTopFrameBeam
    + FSideWall * 2
    + FHose * 2
    + FRubberScreen * 2;
  if AScr.FDrive.HasValue then
    FFull := FFull + AScr.FDrive.Value.Weight;
  FPlateless := FFull - FFixedPlates - FMovingPlates;
end;

initialization
  HeightSeries := specialize TFPGMap<Integer, THsData>.Create;
  AddHeightSerie(6, -19);
  AddHeightSerie(9, -15);
  AddHeightSerie(12, -11);
  AddHeightSerie(15, -7);
  AddHeightSerie(18, -4);
  AddHeightSerie(21, 0);
  AddHeightSerie(24, 4);
  AddHeightSerie(27, 8);
  AddHeightSerie(30, 11);
  //AddHeightSerie(33, 15);

  NominalGapsWithPlasticSpacers := specialize TFPGMap<valreal, TSpacer>.Create;
  AddGapAndSpacer(SI(3, 'mm'), Plastic, SI(2.56, 'gram'), 'RSK130921.001-01',
    SI(2.7, 'mm'));
  AddGapAndSpacer(SI(6, 'mm'), Plastic, SI(4.66, 'gram'), 'RSK130921.001',
    SI(5.7, 'mm'));

  NonPlasticGaps[0] := SI(5, 'mm');

  with PlatesAndSpacers[0] do begin
    Fixed := SI(2, 'mm');
    Moving := SI(3, 'mm');
    Spacer := Plastic;
  end;
  with PlatesAndSpacers[1] do begin
    Fixed := SI(2, 'mm');
    Moving := SI(2, 'mm');
    Spacer := Plastic;
  end;
  with PlatesAndSpacers[2] do begin
    Fixed := SI(3, 'mm');
    Moving := SI(3, 'mm');
    Spacer := Steel;
  end;
  with PlatesAndSpacers[3] do begin
    Fixed := SI(3, 'mm');
    Moving := SI(2, 'mm');
    Spacer := Steel;
  end;
  with PlatesAndSpacers[4] do begin
    Fixed := SI(2, 'mm');
    Moving := SI(2, 'mm');
    Spacer := Steel;
  end;

  DoublePlasticPlates := specialize TFPGMap<ValReal, TPlatePair>.Create;
  AddPlatePair(SI(9, 'mm'), SI(5, 'mm'), SI(4, 'mm'));
  AddPlatePair(SI(10, 'mm'), SI(5, 'mm'), SI(5, 'mm'));
  AddPlatePair(SI(11, 'mm'), SI(6, 'mm'), SI(5, 'mm'));
  AddPlatePair(SI(12, 'mm'), SI(6, 'mm'), SI(6, 'mm'));
  AddPlatePair(SI(13, 'mm'), SI(8, 'mm'), SI(5, 'mm'));
  AddPlatePair(SI(14, 'mm'), SI(8, 'mm'), SI(6, 'mm'));
  AddPlatePair(SI(15, 'mm'), SI(8, 'mm'), SI(6, 'mm'));
  AddPlatePair(SI(16, 'mm'), SI(8, 'mm'), SI(8, 'mm'));
  AddPlatePair(SI(17, 'mm'), SI(8, 'mm'), SI(8, 'mm'));
  AddPlatePair(SI(18, 'mm'), SI(10, 'mm'), SI(8, 'mm'));

  SinglePlasticPlates := specialize TFPGMap<ValReal, ValReal>.Create;
  SinglePlasticPlates.Add(SI(7, 'mm'), SI(6, 'mm'));
  SinglePlasticPlates.Add(SI(8, 'mm'), SI(8, 'mm'));
  SinglePlasticPlates.Add(SI(9, 'mm'), SI(8, 'mm'));
  SinglePlasticPlates.Add(SI(10, 'mm'), SI(10, 'mm'));
  SinglePlasticPlates.Add(SI(11, 'mm'), SI(10, 'mm'));
  SinglePlasticPlates.Add(SI(12, 'mm'), SI(12, 'mm'));
  SinglePlasticPlates.Add(SI(13, 'mm'), SI(12, 'mm'));
  SinglePlasticPlates.Add(SI(14, 'mm'), SI(14, 'mm'));
  SinglePlasticPlates.Add(SI(15, 'mm'), SI(14, 'mm'));

  { Плечо кривошипа. }
  LeverArm := SI(55, 'mm');

  { Шаг зубьев пластин. }
  TeethStep := SI(105, 'mm');

  { Расстояние от сброса до верхней точки решетки. }
  BetwDischargeAndTop := SI(646.68, 'mm');

  { Расстояние от края сброса до оси опоры (гориз.) }
  BetwDischargeAndAxeX := SI(314.94, 'mm');

  { Расстояние между крайними неподвижными балками }
  BetwExtremeFixedBeams := SI(3.795, 'meter');

  { Расстояние между крайними подвижными балками }
  BetwExtremeMovingBeams := SI(3.24, 'meter');

  { Высота сброса, H1 }
  StartFullDropHeight := SI(3.05, 'meter');

  { Длина в плане, D }
  StartHorizLength := SI(3.09774, 'meter');

  { Длина решетки, L }
  StartScreenLength := SI(4.73198, 'meter');

  { Расстояние от дна канала до оси опоры }
  StartAxeHeight := SI(3.13, 'meter');

  { Минимальная высота сброса над каналом.
    2023-02-17: Reduced. It used to be 660 mm.
    2023-03-15: Enlarged. It used to be 300 mm. }
  MinDischargeHeight := SI(630, 'mm');

  { Минимальный зазор между дистанционером и стальной пластиной }
  SteelGapMin := SI(0.36, 'mm');

  { Допустимый зазор между пластиковыми пластинами }
  PlasticGapMin := SteelGapMin;

  PlasticGapMax := SI(1.5, 'mm');

  { Высота пластин подвижных и неподвижных }
  PlateHeight := SI(234, 'mm');

  { Ширина пластиковых листов }
  PlasticSheetWidth := SI(1.5, 'meter');

  { Длина пластиковых листов }
  PlasticSheetLength := SI(3, 'meter');

  PlatesPerSheet := Floor(PlasticSheetWidth / PlateHeight);

  { Угол наклона решетки }
  TiltAngle := SI(50, 'deg');

  { Шаг зубьев по вертикали }
  TeethStepY := TeethStep * sin(TiltAngle);

  { Шаг зубьев по горизонтали }
  TeethStepX := TeethStep * cos(TiltAngle);

  { Примерный шаг между балками }
  FixedBeamStep := SI(800, 'mm');
  MovingBeamStep := SI(650, 'mm');

  with DriveUnits50Hz05XX[0] do begin
    Designation := 'SK9022.1-80LP';
    Weight := SI(49, 'kg');
    Power := SI(0.75, 'kW');
    Torque := SI(586, 'Nm');
    Speed := SI(12, 'rpm');
    Frequency := SI(50, 'Hz');
  end;
  with DriveUnits50Hz05XX[1] do begin
    Designation := 'SK9022.1-90SP';
    Weight := SI(54, 'kg');
    Power := SI(1.1, 'kW');
    Torque := SI(850, 'Nm');
    Speed := SI(12, 'rpm');
    Frequency := SI(50, 'Hz');
  end;

  with DriveUnits60Hz05XX[0] do begin
    Designation := 'SK9022.1-80LP';
    Weight := SI(49, 'kg');
    Power := SI(0.75, 'kW');
    Torque := SI(479, 'Nm');
    Speed := SI(15, 'rpm');
    Frequency := SI(60, 'Hz');
  end;
  with DriveUnits60Hz05XX[1] do begin
    Designation := 'SK9022.1-90SP';
    Weight := SI(53, 'kg');
    Power := SI(1.1, 'kW');
    Torque := SI(699, 'Nm');
    Speed := SI(15, 'rpm');
    Frequency := SI(60, 'Hz');
  end;

  with DriveUnits50Hz[0] do begin
    Designation := 'SK9032.1-80LP';
    Weight := SI(69, 'kg');
    Power := SI(0.75, 'kW');
    Torque := SI(562, 'Nm');
    Speed := SI(13, 'rpm');
    Frequency := SI(50, 'Hz');
  end;
  with DriveUnits50Hz[1] do begin
    Designation := 'SK9032.1-90SP';
    Weight := SI(73, 'kg');
    Power := SI(1.1, 'kW');
    Torque := SI(815, 'Nm');
    Speed := SI(13, 'rpm');
    Frequency := SI(50, 'Hz');
  end;
  with DriveUnits50Hz[2] do begin
    Designation := 'SK9032.1-90LP';
    Weight := SI(75, 'kg');
    Power := SI(1.5, 'kW');
    Torque := SI(1123, 'Nm');
    Speed := SI(13, 'rpm');
    Frequency := SI(50, 'Hz');
  end;
  with DriveUnits50Hz[3] do begin
    Designation := 'SK9032.1-100LP';
    Weight := SI(83, 'kg');
    Power := SI(2.2, 'kW');
    Torque := SI(1596, 'Nm');
    Speed := SI(13, 'rpm');
    Frequency := SI(50, 'Hz');
  end;

  with DriveUnits60Hz[0] do begin
    Designation := 'SK9032.1-80LP';
    Weight := SI(69, 'kg');
    Power := SI(0.75, 'kW');
    Torque := SI(459, 'Nm');
    Speed := SI(16, 'rpm');
    Frequency := SI(60, 'Hz');
  end;
  with DriveUnits60Hz[1] do begin
    Designation := 'SK9032.1-90SP';
    Weight := SI(73, 'kg');
    Power := SI(1.1, 'kW');
    Torque := SI(670, 'Nm');
    Speed := SI(16, 'rpm');
    Frequency := SI(60, 'Hz');
  end;
  with DriveUnits60Hz[2] do begin
    Designation := 'SK9032.1-90LP';
    Weight := SI(75, 'kg');
    Power := SI(1.5, 'kW');
    Torque := SI(919, 'Nm');
    Speed := SI(16, 'rpm');
    Frequency := SI(60, 'Hz');
  end;
  with DriveUnits60Hz[3] do begin
    Designation := 'SK9032.1-100LP';
    Weight := SI(83, 'kg');
    Power := SI(2.2, 'kW');
    Torque := SI(1321, 'Nm');
    Speed := SI(16, 'rpm');
    Frequency := SI(60, 'Hz');
  end;
end.
