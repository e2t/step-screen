unit UPresenter;

{$mode ObjFPC}{$H+}

interface

uses
  UModelPresenter,
  UViewPresenter;

function NewPresenter(AView: IView): IViewPresenter;

implementation

uses
  Classes,
  Errors,
  Fgl,
  FloatUtils,
  L10n,
  MeasurementUtils,
  Model,
  SysUtils,
  TextError,
  TextUi,
  UMsgQueue,
  USettings;

type
  TSubMenuSelector = procedure(AIndex: Integer) of object;

  TPresenter = class sealed(TInterfacedObject, IViewPresenter, IModelPresenter)
    { IViewPresenter }
    procedure TranslateUi;
    procedure TranslateOut;
    procedure Run;
    { IModelPresenter }
    procedure LogError(SpecMap: TTranslate; const Args: array of const);
    procedure AddOutput(SpecMap: TTranslate; const Args: array of const);
    procedure AddOutput(const AText: String);
  private
    FView: IView;
    FUiLang, FOutLang: TLanguage;
    FErrors, FResults: IMsgQueue;
    FSettings: ISettingManager;
    FGapItems: specialize TFPGMap<String, ValReal>;
    procedure InitView;
    procedure DoTranslateUi;
    class procedure SelectLangMenuItem(ALang: TLanguage;
      ALangs: array of TLanguage; AViewCall: TSubMenuSelector);
    function GetInputData: TInputData;
    procedure SetUiLang(Lang: TLanguage);
    procedure SetOutLang(Lang: TLanguage);
    procedure PrintErrors;
    procedure PrintResults;
  public
    constructor Create(AView: IView);
    destructor Destroy; override;
  end;

const
  UiLangs: array of TLanguage = (Eng, Ukr, Lit);
  OutLangs: array of TLanguage = (Eng, Ukr, Rus);
  AppVersion = '23.3';

function NewPresenter(AView: IView): IViewPresenter;
begin
  Result := TPresenter.Create(AView);
end;

function AppVendor: String;
begin
  Result := 'Esmil';
end;

function AppName: String;
begin
  Result := 'StepScreen';
end;

constructor TPresenter.Create(AView: IView);
begin
  FView := AView;
  FErrors := NewMsgQueue(UiLangs);
  FResults := NewMsgQueue(OutLangs);
  FSettings := NewSettingManager(@AppName, @AppVendor);
  SetUiLang(StrToLanguage(FSettings.GetUiLangCode, UiLangs[0]));
  SetOutLang(StrToLanguage(FSettings.GetOutLangCode, OutLangs[0]));

  InitView;
  SelectLangMenuItem(FUiLang, UiLangs, @FView.SelectUiSubMenu);
  SelectLangMenuItem(FOutLang, OutLangs, @FView.SelectOutSubMenu);
  DoTranslateUi;
end;

destructor TPresenter.Destroy;
begin
  FreeAndNil(FGapItems);
end;

procedure TPresenter.SetUiLang(Lang: TLanguage);
begin
  FUiLang := Lang;
  FSettings.SetUiLangCode(Lang);
end;

procedure TPresenter.SetOutLang(Lang: TLanguage);
begin
  FOutLang := Lang;
  FSettings.SetOutLangCode(Lang);
end;

procedure TPresenter.InitView;
var
  I: Integer;
  Sl: TStringList;
  S: String;
  L: TLanguage;
  F: ValReal;
  Plates: array [TPlateAndSpacerRange] of TStringList;
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
  FGapItems := specialize TFPGMap<String, ValReal>.Create;
  for I := 0 to NominalGapsWithPlasticSpacers.Count - 1 do begin
    S := FStr(FromSI('mm', NominalGapsWithPlasticSpacers.Keys[I]));
    FGapItems.Add(S, NominalGapsWithPlasticSpacers.Keys[I]);
  end;
  for F in NonPlasticGaps do begin
    S := FStr(FromSI('mm', F)) + '*';
    FGapItems.Add(S, F);
  end;
  FGapItems.Sort;
  for I := 0 to FGapItems.Count - 1 do
    Sl.Add(FGapItems.Keys[I]);
  FView.FillGaps(Sl);
  FView.SetGap(0);

  for I in TPlateAndSpacerRange do begin
    Plates[I] := TStringList.Create;
    Plates[I].Add(FStr(FromSI('mm', PlatesAndSpacers[I].Fixed)));
    Plates[I].Add(FStr(FromSI('mm', PlatesAndSpacers[I].Moving)));
    Plates[I].Add('');
  end;
  FView.FillPlates(Plates);
  FView.SetPlatesAndSpacers(0);

  Sl.Clear;
  for L in UiLangs do
    Sl.Add(LangNames.KeyData[L]);
  FView.AddUiSubMenu(Sl);

  Sl.Clear;
  for L in OutLangs do
    Sl.Add(LangNames.KeyData[L]);
  FView.AddOutSubMenu(Sl);

  FreeAndNil(Sl);
  for I in TPlateAndSpacerRange do
    FreeAndNil(Plates[I]);
end;

procedure TPresenter.DoTranslateUi;
var
  I: Integer;
  Sa: array [TPlateAndSpacerRange] of String;
begin
  FView.SetTitle(Format('%s - %s %s',
    [TextUiTitle.KeyData[FUiLang], AppName, AppVersion]));
  FView.SetRunLabel(TextUiRun.KeyData[FUiLang]);
  FView.SetUiMenuLabel(TextUiMenu.KeyData[FUiLang]);
  FView.SetOutMenuLabel(TextOutMenu.KeyData[FUiLang]);

  FView.SetWsLabel(TextUiWs.KeyData[FUiLang]);
  FView.SetHsLabel(TextUiHs.KeyData[FUiLang]);
  FView.SetGapLabel(TextUiGap.KeyData[FUiLang]);
  FView.SetDepthLabel(TextUiDep.KeyData[FUiLang]);
  FView.SetPlateLabel(TextUiPlate.KeyData[FUiLang]);
  FView.SetSteelOnlyLabel(TextUiSteelOnly.KeyData[FUiLang]);
  FView.SetHeaderFixed(TextUiFixed.KeyData[FUiLang]);
  FView.SetHeaderMoving(TextUiMoving.KeyData[FUiLang]);
  FView.SetHeaderSpacer(TextUiSpacer.KeyData[FUiLang]);
  FView.Set60HzLabel(TextUiFreq60Hz.KeyData[FUiLang]);

  for I in TPlateAndSpacerRange do
    if PlatesAndSpacers[I].Spacer = Steel then
      Sa[I] := TextUiSteel.KeyData[FUiLang]
    else
      Sa[I] := TextUiPlastic.KeyData[FUiLang];
  FView.FillSpacers(Sa);
end;

class procedure TPresenter.SelectLangMenuItem(ALang: TLanguage;
  ALangs: array of TLanguage; AViewCall: TSubMenuSelector);
var
  I: Integer;
begin
  for I := Low(ALangs) to High(ALangs) do
    if ALangs[I] = ALang then begin
      AViewCall(I);
      break;
    end;
end;

procedure TPresenter.TranslateUi;
begin
  SetUiLang(UiLangs[FView.GetUiSubMenuSelected]);
  DoTranslateUi;
  if not FErrors.IsEmpty then
    PrintErrors;
end;

procedure TPresenter.TranslateOut;
begin
  SetOutLang(OutLangs[FView.GetOutSubMenuSelected]);
  if FErrors.IsEmpty then
    PrintResults;
end;

function TPresenter.GetInputData: TInputData;
begin
  Result.Ws := Low(TWidthSeries) + FView.GetWsIndex;
  Result.Hs := HeightSeries.Keys[FView.GetHsIndex];
  Result.NominalGap := FGapItems.Data[FView.GetGapIndex];
  try
    Result.Depth := SI(AdvStrToFloat(FView.GetDepthText), 'mm');
  except
    on E: EConvertError do
      FErrors.Append(TextErrDepth, []);
  end;
  Result.PlateAndSpacer := PlatesAndSpacers[FView.GetPlateIndex];
  Result.IsSteelOnly := FView.GetSteelOnly;
  Result.Is60Hz := FView.GetIs60Hz;
  if not FErrors.IsEmpty then
    raise ELoggedError.Create('Invalid input data');
end;

procedure TPresenter.Run;
begin
  FErrors.Clear;
  FResults.Clear;
  try
    CalcStepScreen(GetInputData, Self);
  except
    on ELoggedError do begin
      PrintErrors;
      exit;
    end;
  end;
  PrintResults;
end;

procedure TPresenter.PrintErrors;
begin
  FView.PrintText(FErrors.Text(FUiLang));
end;

procedure TPresenter.PrintResults;
begin
  FView.PrintText(FResults.Text(FOutLang));
end;

procedure TPresenter.LogError(SpecMap: TTranslate; const Args: array of const);
begin
  FErrors.Append(SpecMap, Args);
end;

procedure TPresenter.AddOutput(SpecMap: TTranslate; const Args: array of const);
begin
  FResults.Append(SpecMap, Args);
end;

procedure TPresenter.AddOutput(const AText: String);
begin
  FResults.Append(AText);
end;

end.
