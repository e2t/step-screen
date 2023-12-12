unit TextUi;

{$mode ObjFPC}{$H+}

interface

uses
  L10n;

var
  TextUiWs, TextUiHs, TextUiGap, TextUiDep, TextUiPlate, TextUiSteelOnly,
  TextUiTitle, TextUiFixed, TextUiMoving, TextUiSpacer, TextUiSteel,
  TextUiPlastic, TextUiFreq60Hz: TTranslate;

implementation

initialization
  TextUiWs := TTranslate.Create;
  TextUiWs.Add(Eng, 'Width (series):');
  TextUiWs.Add(Ukr, 'Ширина (серія):');
  TextUiWs.Add(Rus, 'Ширина (серия):');
  TextUiWs.Add(Lit, 'Plotis (serija):');

  TextUiHs := TTranslate.Create;
  TextUiHs.Add(Eng, 'Height (series):');
  TextUiHs.Add(Ukr, 'Висота (серія):');
  TextUiHs.Add(Rus, 'Высота (серия):');
  TextUiHs.Add(Lit, 'Aukštis (serija):');

  TextUiGap := TTranslate.Create;
  TextUiGap.Add(Eng, 'Nominal gap (mm):');
  TextUiGap.Add(Ukr, 'Номінальний прозор (мм):');
  TextUiGap.Add(Rus, 'Номинальный прозор (мм):');
  TextUiGap.Add(Lit, 'Nominalus protarpis (mm):');

  TextUiDep := TTranslate.Create;
  TextUiDep.Add(Eng, 'Channel or tank depth (mm):');
  TextUiDep.Add(Ukr, 'Глибина каналу або бака (мм):');
  TextUiDep.Add(Rus, 'Глубина канала или бака (мм):');
  TextUiDep.Add(Lit, 'Kanalo arba rezervuaro gylis (mm):');

  TextUiPlate := TTranslate.Create;
  TextUiPlate.Add(Eng, 'Plate thickness (mm) and spacers:');
  TextUiPlate.Add(Ukr, 'Товщина пластин (мм) та дистанційники:');
  TextUiPlate.Add(Rus, 'Толщина пластин (мм) и дистанционеры:');
  TextUiPlate.Add(Lit, 'Plokštės storis (mm) ir tarpikliai:');

  TextUiSteelOnly := TTranslate.Create;
  TextUiSteelOnly.Add(Eng, 'Steel plates only');
  TextUiSteelOnly.Add(Ukr, 'Тільки сталеві пластини');
  TextUiSteelOnly.Add(Rus, 'Только стальные пластины');
  TextUiSteelOnly.Add(Lit, 'Tik plieniniai tarpikliai');

  TextUiTitle := TTranslate.Create;
  TextUiTitle.Add(Eng, 'RSK calculation');
  TextUiTitle.Add(Ukr, 'Розрахунок РСК');
  TextUiTitle.Add(Rus, 'Расчет РСК');
  TextUiTitle.Add(Lit, 'RSK skaičiavimas');

  TextUiFixed := TTranslate.Create;
  TextUiFixed.Add(Eng, 'Fixed');
  TextUiFixed.Add(Ukr, 'Нерухомі');
  TextUiFixed.Add(Rus, 'Неподвижные');
  TextUiFixed.Add(Lit, 'Nejudanti');

  TextUiMoving := TTranslate.Create;
  TextUiMoving.Add(Eng, 'Movable');
  TextUiMoving.Add(Ukr, 'Рухомі');
  TextUiMoving.Add(Rus, 'Подвижные');
  TextUiMoving.Add(Lit, 'Judanti');

  TextUiSpacer := TTranslate.Create;
  TextUiSpacer.Add(Eng, 'Spacers');
  TextUiSpacer.Add(Ukr, 'Дистанційники');
  TextUiSpacer.Add(Rus, 'Дистанционеры');
  TextUiSpacer.Add(Lit, 'Tarpikliai');

  TextUiSteel := TTranslate.Create;
  TextUiSteel.Add(Eng, 'steel');
  TextUiSteel.Add(Ukr, 'сталеві');
  TextUiSteel.Add(Rus, 'стальные');
  TextUiSteel.Add(Lit, 'plieniniai');

  TextUiPlastic := TTranslate.Create;
  TextUiPlastic.Add(Eng, 'plastic');
  TextUiPlastic.Add(Ukr, 'пластикові');
  TextUiPlastic.Add(Rus, 'пластиковые');
  TextUiPlastic.Add(Lit, 'plastikiniai');

  TextUiFreq60Hz := TTranslate.Create;
  TextUiFreq60Hz.Add(Eng, 'Frequency 60 Hz');
  TextUiFreq60Hz.Add(Ukr, 'Частота 60 Гц');
  TextUiFreq60Hz.Add(Rus, 'Частота 60 Гц');
  TextUiFreq60Hz.Add(Lit, 'Dažnis 60 Hz');
end.
