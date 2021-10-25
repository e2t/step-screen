unit Controller;

{$MODE OBJFPC}
{$LONGSTRINGS ON}
{$ASSERTIONS ON}
{$RANGECHECKS ON}
{$BOOLEVAL OFF}

interface

procedure Run();
procedure MainFormInit();

implementation

uses
  ProgramInfo, GuiMainForm, GuiHelper, Measurements, Classes, SysUtils,
  ScreenCalculation, StrConvert;

procedure MainFormInit();
var
  I: Integer;
  J: THeightSerie;
  K: Double;
  L: TPlatesSet;
begin
  MainForm.Caption := GetProgramTitle;
  for I in ScreenWidthSeries do
    MainForm.ComboBoxWidth.Items.Add(Format('%.2d', [I]));
  MainForm.ComboBoxWidth.Text := MainForm.ComboBoxWidth.Items[0];
  for J in ScreenHeightSeries do
    MainForm.ComboBoxHeight.Items.Add(Format('%.2d', [J.Serie]));
  MainForm.ComboBoxHeight.Text := MainForm.ComboBoxHeight.Items[0];
  for K in SteelGaps do
    MainForm.ComboBoxGap.Items.Add(FormatFloat('.0#', ToMm(K)));
  MainForm.ComboBoxGap.Text := MainForm.ComboBoxGap.Items[0];
  for L in ThicknessSteel do
    MainForm.ComboBoxThickness.Items.Add(Format('%.0f/%.0f', [
      ToMm(L.Moving), ToMm(L.Fixed)]));
  MainForm.ComboBoxThickness.Text := MainForm.ComboBoxThickness.Items[0];
end;

procedure CreateInputData(out InputData: TInputData; out Error: string);
const
  SIncorrectValue = ' - неправильное значение.';
var
  IsValid: Boolean;
begin
  InputData := Default(TInputData);
  Error := '';

  MainForm.ComboBoxWidth.GetInt(IsValid, InputData.ScreenWS);
  Assert(IsValid);

  MainForm.ComboBoxHeight.GetInt(IsValid, InputData.ScreenHS);
  Assert(IsValid);

  MainForm.ComboBoxGap.GetRealMin(0, IsValid, InputData.MainSteelGapMm);
  if not IsValid then
  begin
    Error := 'Прозор' + SIncorrectValue;
    Exit;
  end;

  InputData.SteelS := ThicknessSteel[MainForm.ComboBoxThickness.ItemIndex];

  MainForm.EditDepth.GetRealMin(0, IsValid, InputData.ChannelHeightMm);
  if not IsValid then
  begin
    Error := 'Глубина канала' + SIncorrectValue;
    Exit;
  end;

  InputData.HavePlasticPart := not MainForm.CheckBoxPlasticPart.Checked;
end;

function CreateOutput(const Scr: TStepScreen): string;
var
  Lines: TStringList;
  Drive: string;
  WoDriveMark: string = '';
  SMovingSteelS, SFixedSteelS: string;
  I: Integer;
begin
  if Scr.DriveUnit.HasValue then
    Drive := Format('«%s»  %s кВт; %s об/мин; %s Нм', [
      Scr.DriveUnit.Value.Name,
      FormatFloat('0.###', ToKw(Scr.DriveUnit.Value.Power)),
      FormatFloat('0.###', ToRpm(Scr.DriveUnit.Value.Speed)),
      FormatFloat('0.###', Scr.DriveUnit.Value.Torque)
      ])
  else
  begin
    Drive := 'нестандартный';
    WoDriveMark := ' (без привода)';
  end;
  SMovingSteelS := FormatFloat('0.###', ToMm(Scr.MovingSteelS));
  SFixedSteelS := FormatFloat('0.###', ToMm(Scr.FixedSteelS));

  Lines := TStringList.Create;
  Lines.AddStrings([
    Format('РСК %s, прозор %s (%s/%s), глубина %s мм', [Scr.Description,
    FormatFloat('0.###', ToMm(Scr.MainSteelGap)), SMovingSteelS, SFixedSteelS,
    FormatFloat('0.###', ToMm(Scr.ChannelHeight))]),

    Format('Масса решетки %.0f кг%s', [Scr.Weight, WoDriveMark]),
    Format('Привод %s', [Drive]),
    '',
    Format('Ширина наружная B = %.0f мм', [ToMm(Scr.OuterScreenWidth)]),
    Format('Ширина внутренняя A = %.0f мм', [ToMm(Scr.InnerScreenWidth)]),
    Format('Ширина сброса G = %.0f мм', [ToMm(Scr.DischargeWidth)]),
    Format('Высота сброса до дна H1 = %.0f мм', [ToMm(Scr.DischargeFullHeight)]),
    Format('Высота сброса до пола H4 = %.0f мм', [ToMm(Scr.DischargeHeight)]),
    Format('Высота решетки H2 = %.0f мм', [ToMm(Scr.ScreenHeight)]),
    Format('Длина решетки L = %.0f мм', [ToMm(Scr.ScreenLength)]),
    Format('Длина в плане D = %.0f мм', [ToMm(Scr.HorizLength)]),
    Format('Размер до оси F = %.0f мм', [ToMm(Scr.AxeDistanceX)]),
    Format('Радиус поворота R = %.0f мм', [ToMm(Scr.TurningRadius)]),
    '',
    '====== Для конструктора ======',
    '',
    Format('Толщина боковой накладки не более %.1f мм', [ToMm(Scr.MinSideGap)]),
    Format('Подвижных пластин %d шт.', [Scr.MovingPlatesNumber]),
    Format('- сталь %s мм', [SMovingSteelS])
    ]);
  if Scr.HavePlasticPart then
    Lines.Add(Format('- пластик %s мм', [
      FormatFloat('0.###', ToMm(Scr.MovingPlasticS.Value))]));
  Lines.AddStrings([
    Format('- крайний паз %s мм', [
    FormatFloat('0.###', ToMm(Scr.StartMoving))]),
    Format('Неподвижных пластин %d шт.', [Scr.FixedPlatesNumber]),
    Format('- сталь %s мм', [SFixedSteelS])
    ]);
  if Scr.HavePlasticPart then
    Lines.Add(Format('- пластик %s мм', [
      FormatFloat('0.###', ToMm(Scr.FixedPlasticS.Value))]));
  Lines.AddStrings([
    Format('- крайний паз %s мм', [
    FormatFloat('0.###', ToMm(Scr.StartFixed))]),
    Format('Шаг пластин по ширине %s мм', [
    FormatFloat('0.###', ToMm(Scr.PlatesStep))]),
    ''
    ]);

  for I := 0 to Scr.PlasticSheetCounts.Count - 1 do
    Lines.Add(Format('Листовой полипропилен PP-C %.1f мм - %d лист. %.1fx%.1f', [
      ToMm(Scr.PlasticSheetCounts.Keys[I]), Scr.PlasticSheetCounts.Data[I],
      PlasticSheetWidth, PlasticSheetLength]));

  if Scr.HavePlasticPart then
    Lines.Add(Format('Сумма толщин пластиковых пластин %s…%s мм', [
      FormatFloat('0.###', ToMm(Scr.SumPlasticS[0])),
      FormatFloat('0.###', ToMm(Scr.SumPlasticS[1]))]));
  Lines.AddStrings([
    Format('Вес подвижных частей %.0f кг', [Scr.MovingWeight]),
    Format('Крутяший момент %.0f Нм', [Scr.MinTorque]),
    '',
    '====== Файл уравнений ======',
    '',
    Scr.EquationFile
    ]);

  Result := Lines.Text;
  Lines.Free;
end;

procedure PrintOutput(const Text: string);
begin
  MainForm.MemoOutput.Clear;
  MainForm.MemoOutput.Text := Text;
  MainForm.MemoOutput.SelStart := 0;
end;

var
  Scr: TStepScreen;

procedure Run();
var
  InputData: TInputData;
  InputDataError, CalcError: string;
begin
  CreateInputData(InputData, InputDataError);
  if InputDataError = '' then
  begin
    CalcStepScreen(Scr, InputData, CalcError);
    if CalcError = '' then
      PrintOutput(CreateOutput(Scr))
    else
      PrintOutput(CalcError);
  end
  else
    PrintOutput(InputDataError);
end;

initialization
  Scr := Default(TStepScreen);
  Scr.PlasticSheetCounts := TSheetCounts.Create;
end.
