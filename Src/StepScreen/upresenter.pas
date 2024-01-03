unit UPresenter;

{$mode ObjFPC}{$H+}

interface

uses
  BaseCalcApp,
  Classes;

type
  {$interfaces CORBA}
  IView = interface(IBaseView)
    procedure FillWidthSeries(ASeries: TStrings);
    procedure SetWidthSerie(AIndex: Integer);
    procedure FillHeightSeries(ASeries: TStrings);
    procedure SetHeightSerie(AIndex: Integer);
    procedure FillGaps(ASeries: TStrings);
    procedure SetGap(AIndex: Integer);
    procedure FillColFixed(const AItems: array of String);
    procedure FillColMoving(const AItems: array of String);
    procedure FillColSpacer(const AItems: array of String);
    procedure SetPlatesAndSpacers(AIndex: Integer);
    procedure SetWsLabel(const AText: String);
    procedure SetHsLabel(const AText: String);
    procedure SetGapLabel(const AText: String);
    procedure SetDepthLabel(const AText: String);
    procedure SetPlateLabel(const AText: String);
    procedure SetSteelOnlyLabel(const AText: String);
    procedure SetHeaderFixed(const AText: String);
    procedure SetHeaderMoving(const AText: String);
    procedure SetHeaderSpacer(const AText: String);
    procedure Set60HzLabel(const AText: String);
    function GetWsIndex: Integer;
    function GetHsIndex: Integer;
    function GetGapIndex: Integer;
    function GetDepthText: String;
    function GetPlateIndex: Integer;
    function GetSteelOnly: Boolean;
    function GetIs60Hz: Boolean;
  end;

  IViewPresenter = interface(IBaseViewPresenter)
  end;

  IModelPresenter = interface(IBaseModelPresenter)
  end;

function NewPresenter(AView: IView): IViewPresenter;

implementation

uses
  Fgl,
  FloatUtils,
  L10n,
  MeasurementUtils,
  Model,
  SysUtils,
  Texts;

type
  TPresenter = class sealed(IViewPresenter, IModelPresenter, ICorePresenter)
  private
    FCore: ICore;
    FView: IView;
    FInputData: TInputData;
    FGapItems: specialize TFPGMap<String, ValReal>;

    { ICorePresenter }
    procedure DoInitView;
    procedure DoTranslateUi;
    procedure GetInputData;
    procedure Calculate;
    procedure PrintResults;
    procedure PrintErrors;
    procedure ClearQueues;
    { IViewPresenter }
    procedure InitView;
    procedure TranslateUi;
    procedure TranslateOut;
    procedure Run;
    { IModelPresenter }
    procedure LogError(SpecMap: TTranslate; const Args: array of const);
    procedure AddOutput(SpecMap: TTranslate; const Args: array of const);
    procedure AddOutput(const AText: String);
  public
    constructor Create(AView: IView);
    destructor Destroy; override;
  end;

const
  UiLangs: array of TLanguage = (Eng, Ukr, Lit);
  OutLangs: array of TLanguage = (Eng, Ukr, Rus);
  AppVersion = '24.1';

function AppVendor: String;
begin
  Result := 'Esmil';
end;

function AppName: String;
begin
  Result := 'StepScreen';
end;

function NewPresenter(AView: IView): IViewPresenter;
begin
  Result := TPresenter.Create(AView);
end;

{ TPresenter }

constructor TPresenter.Create(AView: IView);
var
  I: Integer;
  S: String;
  F: ValReal;
begin
  FCore := NewCore(Self, AView, UiLangs, OutLangs, @AppName, @AppVendor,
    AppVersion, TextUiTitle);
  FView := AView;

  FGapItems := specialize TFPGMap<String, ValReal>.Create;
  for I := 0 to NominalGapsWithPlasticSpacers.Count - 1 do
  begin
    F := NominalGapsWithPlasticSpacers.Keys[I];
    S := FStr(FromSI('mm', F));
    FGapItems.Add(S, F);
  end;
  for F in NonPlasticGaps do
  begin
    S := FStr(FromSI('mm', F)) + '*';
    FGapItems.Add(S, F);
  end;
  FGapItems.Sort;
end;

destructor TPresenter.Destroy;
begin
  FreeAndNil(FGapItems);
  inherited Destroy;
end;

procedure TPresenter.DoInitView;
var
  I: Integer;
  Sl: TStringList;
  Sa: array [TPlateAndSpacerRange] of String;
begin
  Sl := TStringList.Create;
  for I in TWidthSeries do
    Sl.Add(Format('%0.2d', [I]));
  FView.FillWidthSeries(Sl);
  FView.SetWidthSerie(0);

  Sl.Clear;
  for I := 0 to HeightSeries.Count - 1 do
    Sl.Add(Format('%0.2d', [HeightSeries.Keys[I]]));
  FView.FillHeightSeries(Sl);
  FView.SetHeightSerie(0);

  Sl.Clear;
  for I := 0 to FGapItems.Count - 1 do
    Sl.Add(FGapItems.Keys[I]);
  FView.FillGaps(Sl);
  FView.SetGap(0);

  for I in TPlateAndSpacerRange do
    Sa[I] := FStr(FromSI('mm', PlatesAndSpacers[I].Fixed));
  FView.FillColFixed(Sa);
  for I in TPlateAndSpacerRange do
    Sa[I] := FStr(FromSI('mm', PlatesAndSpacers[I].Moving));
  FView.FillColMoving(Sa);
  FView.SetPlatesAndSpacers(0);

  FreeAndNil(Sl);
end;

procedure TPresenter.DoTranslateUi;
var
  I: Integer;
  Sa: array [TPlateAndSpacerRange] of String;
  UiLang: TLanguage;
begin
  UiLang := FCore.UiLang;
  FView.SetWsLabel(TextUiWs.KeyData[UiLang]);
  FView.SetHsLabel(TextUiHs.KeyData[UiLang]);
  FView.SetGapLabel(TextUiGap.KeyData[UiLang]);
  FView.SetDepthLabel(TextUiDep.KeyData[UiLang]);
  FView.SetPlateLabel(TextUiPlate.KeyData[UiLang]);
  FView.SetSteelOnlyLabel(TextUiSteelOnly.KeyData[UiLang]);
  FView.SetHeaderFixed(TextUiFixed.KeyData[UiLang]);
  FView.SetHeaderMoving(TextUiMoving.KeyData[UiLang]);
  FView.SetHeaderSpacer(TextUiSpacer.KeyData[UiLang]);
  FView.Set60HzLabel(TextUiFreq60Hz.KeyData[UiLang]);

  for I in TPlateAndSpacerRange do
    if PlatesAndSpacers[I].Spacer = Steel then
      Sa[I] := TextUiSteel.KeyData[UiLang]
    else
      Sa[I] := TextUiPlastic.KeyData[UiLang];
  FView.FillColSpacer(Sa);
end;

procedure TPresenter.GetInputData;
begin
  FInputData := Default(TInputData);
  FInputData.Ws := Low(TWidthSeries) + FView.GetWsIndex;
  FInputData.Hs := HeightSeries.Keys[FView.GetHsIndex];
  FInputData.NominalGap := FGapItems.Data[FView.GetGapIndex];
  try
    FInputData.Depth := SI(AdvStrToFloat(FView.GetDepthText), 'mm');
  except
    on E: EConvertError do
      LogError(TextErrDepth, []);
  end;
  FInputData.PlateAndSpacer := PlatesAndSpacers[FView.GetPlateIndex];
  FInputData.IsSteelOnly := FView.GetSteelOnly;
  FInputData.Is60Hz := FView.GetIs60Hz;
end;

procedure TPresenter.Calculate;
begin
  CalcStepScreen(FInputData, Self);
end;

procedure TPresenter.PrintResults;
begin
  FCore.PrintPlainResults;
end;

procedure TPresenter.PrintErrors;
begin
  FCore.PrintErrorsOnly;
end;

procedure TPresenter.ClearQueues;
begin
  FCore.ClearQueues;
end;

{ delegation only }

procedure TPresenter.InitView;
begin
  FCore.InitView;
end;

procedure TPresenter.TranslateUi;
begin
  FCore.TranslateUi;
end;

procedure TPresenter.TranslateOut;
begin
  FCore.TranslateOut;
end;

procedure TPresenter.Run;
begin
  FCore.Run;
end;

procedure TPresenter.LogError(SpecMap: TTranslate; const Args: array of const);
begin
  FCore.LogError(SpecMap, Args);
end;

procedure TPresenter.AddOutput(SpecMap: TTranslate; const Args: array of const);
begin
  FCore.AddOutput(SpecMap, Args);
end;

procedure TPresenter.AddOutput(const AText: String);
begin
  FCore.AddOutput(AText);
end;

end.
