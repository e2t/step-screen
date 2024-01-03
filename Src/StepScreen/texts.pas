unit Texts;

{$mode ObjFPC}{$H+}

interface

uses
  L10n,
  StringUtils;

var
  TextUiWs, TextUiHs, TextUiGap, TextUiDep, TextUiPlate, TextUiSteelOnly,
  TextUiTitle, TextUiFixed, TextUiMoving, TextUiSpacer, TextUiSteel,
  TextUiPlastic, TextUiFreq60Hz: TTranslate;

  TextErrDepth, TextErrTooDeep, TextErrNonPlasticGap: TTranslate;

  TextOutRskGapDepth, TextOutWeight, TextOutDrivelessWeight, TextOutDrive,
  TextOutUndefDrive, TextOutExtWidth, TextOutIntWidth, TextOutDropWidth,
  TextOutFullDropHeight, TextOutDropHeight, TextOutScrHeight, TextOutScrLength,
  TextOutHorizLength, TextOutAxeX, TextOutRadius, TextOutForDesigner,
  TextOutMinSideGap, TextOutPlasticSpacers, TextOutSteelSpacers,
  TextOutMovingCount, TextOutSteelS, TextOutPlasticS, TextOutFixedCount,
  TextOutPlasticSheet, TextOutMovingWeight, TextOutMinTorque,
  TextOutEquationFile, TextOutPlasticWeight: TTranslate;

implementation

uses
  SysUtils;

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

  { Errors }

  TextErrDepth := TTranslate.Create;
  TextErrDepth.Add(Eng, 'Wrong channel depth value!');
  TextErrDepth.Add(Ukr, 'Неправильне значення глибини каналу!');
  TextErrDepth.Add(Rus, 'Неправильное значение глубины канала!');
  TextErrDepth.Add(Lit, 'Neteisinga kanalo gylio vertė!');

  TextErrTooDeep := TTranslate.Create;
  TextErrTooDeep.Add(Eng, 'The channel is too deep! (max. %s mm)');
  TextErrTooDeep.Add(Ukr, 'Занадто глибокий канал! (макс. %s мм)');
  TextErrTooDeep.Add(Rus, 'Слишком глубокий канал! (макс. %s мм)');
  TextErrTooDeep.Add(Lit, 'Kanalas per gilus! (max. %s mm)');

  TextErrNonPlasticGap := TTranslate.Create;
  TextErrNonPlasticGap.Add(
    Eng, 'For plastic spacers, only gaps are possible: %s.');
  TextErrNonPlasticGap.Add(
    Ukr, 'Для пластикових дистанційників можливі лише прозори: %s.');
  TextErrNonPlasticGap.Add(
    Rus, 'Для пластиковых дистанционеров возможны только прозоры: %s.');
  TextErrNonPlasticGap.Add(
    Lit, 'Plastikiniams tarpikliams galimi tik tarpai: %s.');

  { Result }

  TextOutRskGapDepth := TTranslate.Create;
  TextOutRskGapDepth.Add(
    Eng, 'RSK %0.2d%0.2d, actual gap %s (%s/%s), depth %s mm');
  TextOutRskGapDepth.Add(
    Ukr, 'РСК %0.2d%0.2d, фактичний прозор %s (%s/%s), глибина %s мм');
  TextOutRskGapDepth.Add(
    Rus, 'РСК %0.2d%0.2d, фактический прозор %s (%s/%s), глубина %s мм');

  TextOutWeight := TTranslate.Create;
  TextOutWeight.Add(Eng, 'Screen weight %s kg');
  TextOutWeight.Add(Ukr, 'Маса решітки %s кг');
  TextOutWeight.Add(Rus, 'Масса решетки %s кг');

  TextOutDrivelessWeight := TTranslate.Create;
  TextOutDrivelessWeight.Add(Eng, 'Screen weight %s kg (without drive)');
  TextOutDrivelessWeight.Add(Ukr, 'Маса решітки %s кг (без приводу)');
  TextOutDrivelessWeight.Add(Rus, 'Масса решетки %s кг (без привода)');

  TextOutDrive := TTranslate.Create;
  TextOutDrive.Add(
    Eng, 'NORD geared motor «%s»  %s kW, %s Hz, %s rpm, %s Nm');
  TextOutDrive.Add(
    Ukr, 'Мотор-редуктор NORD «%s»  %s кВт, %s Гц, %s об/хв, %s Нм');
  TextOutDrive.Add(
    Rus, 'Мотор-редуктор NORD «%s»  %s кВт, %s Гц, %s об/мин, %s Нм');

  TextOutUndefDrive := TTranslate.Create;
  TextOutUndefDrive.Add(Eng, 'Undefined drive unit');
  TextOutUndefDrive.Add(Ukr, 'Нестандартний привід');
  TextOutUndefDrive.Add(Rus, 'Нестандартный привод');

  TextOutExtWidth := TTranslate.Create;
  TextOutExtWidth.Add(Eng, 'External width, B = %s mm');
  TextOutExtWidth.Add(Ukr, 'Ширина зовнішня, B = %s мм');
  TextOutExtWidth.Add(Rus, 'Ширина наружная, B = %s мм');

  TextOutIntWidth := TTranslate.Create;
  TextOutIntWidth.Add(Eng, 'Internal width, A = %s mm');
  TextOutIntWidth.Add(Ukr, 'Ширина внутрішня, A = %s мм');
  TextOutIntWidth.Add(Rus, 'Ширина внутренняя, A = %s мм');

  TextOutDropWidth := TTranslate.Create;
  TextOutDropWidth.Add(Eng, 'Drop width, G = %s mm');
  TextOutDropWidth.Add(Ukr, 'Ширина скидання, G = %s мм');
  TextOutDropWidth.Add(Rus, 'Ширина сброса, G = %s мм');

  TextOutFullDropHeight := TTranslate.Create;
  TextOutFullDropHeight.Add(
    Eng, 'Drop height from the channel bottom, H1 = %s mm');
  TextOutFullDropHeight.Add(
    Ukr, 'Висота скидання від дна, H1 = %s мм');
  TextOutFullDropHeight.Add(
    Rus, 'Высота сброса от дна, H1 = %s мм');

  TextOutDropHeight := TTranslate.Create;
  TextOutDropHeight.Add(Eng, 'Drop height from the channel top, H4 = %s mm');
  TextOutDropHeight.Add(Ukr, 'Висота скидання від підлоги, H4 = %s мм');
  TextOutDropHeight.Add(Rus, 'Высота сброса от пола, H4 = %s мм');

  TextOutScrHeight := TTranslate.Create;
  TextOutScrHeight.Add(Eng, 'Screen height, H2 = %s mm');
  TextOutScrHeight.Add(Ukr, 'Висота решітки, H2 = %s мм');
  TextOutScrHeight.Add(Rus, 'Высота решетки, H2 = %s мм');

  TextOutScrLength := TTranslate.Create;
  TextOutScrLength.Add(Eng, 'Screen length, L = %s mm');
  TextOutScrLength.Add(Ukr, 'Довжина решітки, L = %s мм');
  TextOutScrLength.Add(Rus, 'Длина решетки, L = %s мм');

  TextOutHorizLength := TTranslate.Create;
  TextOutHorizLength.Add(Eng, 'Horizontal length, D = %s mm');
  TextOutHorizLength.Add(Ukr, 'Довжина у плані, D = %s мм');
  TextOutHorizLength.Add(Rus, 'Длина в плане, D = %s мм');

  TextOutAxeX := TTranslate.Create;
  TextOutAxeX.Add(Eng, 'Distance to axis, F = %s mm');
  TextOutAxeX.Add(Ukr, 'Розмір до осі, F = %s мм');
  TextOutAxeX.Add(Rus, 'Размер до оси, F = %s мм');

  TextOutRadius := TTranslate.Create;
  TextOutRadius.Add(Eng, 'Turning radius, R = %s mm');
  TextOutRadius.Add(Ukr, 'Радіус повороту, R = %s мм');
  TextOutRadius.Add(Rus, 'Радиус поворота, R = %s мм');

  TextOutForDesigner := TTranslate.Create;
  TextOutForDesigner.Add(Eng, Heading('For designer'));
  TextOutForDesigner.Add(Ukr, Heading('Для конструктора'));
  TextOutForDesigner.Add(Rus, Heading('Для конструктора'));

  TextOutMinSideGap := TTranslate.Create;
  TextOutMinSideGap.Add(Eng, 'Minimal side gap %s mm');
  TextOutMinSideGap.Add(Ukr, 'Найменший боковий зазор %s мм');
  TextOutMinSideGap.Add(Rus, 'Минимальный боковой зазор %s мм');

  TextOutPlasticSpacers := TTranslate.Create;
  TextOutPlasticSpacers.Add(Eng, 'Spacers ≈%d pcs. «%s»');
  TextOutPlasticSpacers.Add(Ukr, 'Дистанційників ≈%d шт. «%s»');
  TextOutPlasticSpacers.Add(Rus, 'Дистанционеров ≈%d шт. «%s»');

  TextOutSteelSpacers := TTranslate.Create;
  TextOutSteelSpacers.Add(Eng, 'Spacers ≈%d pcs. (welded)');
  TextOutSteelSpacers.Add(Ukr, 'Дистанційників ≈%d шт. (приварні)');
  TextOutSteelSpacers.Add(Rus, 'Дистанционеров ≈%d шт. (приварные)');

  TextOutMovingCount := TTranslate.Create;
  TextOutMovingCount.Add(Eng, 'Moving plates %d pcs.');
  TextOutMovingCount.Add(Ukr, 'Рухомих пластин %d шт.');
  TextOutMovingCount.Add(Rus, 'Подвижных пластин %d шт.');

  TextOutSteelS := TTranslate.Create;
  TextOutSteelS.Add(Eng, '- steel %s mm');
  TextOutSteelS.Add(Ukr, '- сталь %s мм');
  TextOutSteelS.Add(Rus, '- сталь %s мм');

  TextOutPlasticS := TTranslate.Create;
  TextOutPlasticS.Add(Eng, '- plastic %s мм');
  TextOutPlasticS.Add(Ukr, '- пластик %s мм');
  TextOutPlasticS.Add(Rus, '- пластик %s мм');

  TextOutFixedCount := TTranslate.Create;
  TextOutFixedCount.Add(Eng, 'Fixed plates %d pcs.');
  TextOutFixedCount.Add(Ukr, 'Нерухомих пластин %d шт.');
  TextOutFixedCount.Add(Rus, 'Неподвижных пластин %d шт.');

  TextOutPlasticSheet := TTranslate.Create;
  TextOutPlasticSheet.Add(Eng, 'Polypropylene PP-C %s mm - %d sheets %sx%s m');
  TextOutPlasticSheet.Add(Ukr, 'Поліпропілен PP-C %s мм - %d лист. %sx%s м');
  TextOutPlasticSheet.Add(Rus, 'Полипропилен PP-C %s мм - %d лист. %sx%s м');

  TextOutMovingWeight := TTranslate.Create;
  TextOutMovingWeight.Add(Eng, 'Moving part weight %s kg');
  TextOutMovingWeight.Add(Ukr, 'Вага рухомих частин %s кг');
  TextOutMovingWeight.Add(Rus, 'Вес подвижных частей %s кг');

  TextOutMinTorque := TTranslate.Create;
  TextOutMinTorque.Add(Eng, 'Minimal torque %s Nm');
  TextOutMinTorque.Add(Ukr, 'Найменший обертаючий момент %s Нм');
  TextOutMinTorque.Add(Rus, 'Минимальный крутящий момент %s Нм');

  TextOutEquationFile := TTranslate.Create;
  TextOutEquationFile.Add(Eng, Heading('Equation file'));
  TextOutEquationFile.Add(Ukr, Heading('Файл рівнянь'));
  TextOutEquationFile.Add(Rus, Heading('Файл уравнений'));

  TextOutPlasticWeight := TTranslate.Create;
  TextOutPlasticWeight.Add(Eng, 'Weight of plastic plates %s kg');
  TextOutPlasticWeight.Add(Ukr, 'Вага пластикових пластин %s кг');
  TextOutPlasticWeight.Add(Rus, 'Вес пластиковых пластин %s кг');

finalization
  FreeAndNil(TextUiWs);
  FreeAndNil(TextUiHs);
  FreeAndNil(TextUiGap);
  FreeAndNil(TextUiDep);
  FreeAndNil(TextUiPlate);
  FreeAndNil(TextUiSteelOnly);
  FreeAndNil(TextUiTitle);
  FreeAndNil(TextUiFixed);
  FreeAndNil(TextUiMoving);
  FreeAndNil(TextUiSpacer);
  FreeAndNil(TextUiSteel);
  FreeAndNil(TextUiPlastic);
  FreeAndNil(TextUiFreq60Hz);

  FreeAndNil(TextErrDepth);
  FreeAndNil(TextErrTooDeep);
  FreeAndNil(TextErrNonPlasticGap);

  FreeAndNil(TextOutRskGapDepth);
  FreeAndNil(TextOutWeight);
  FreeAndNil(TextOutDrivelessWeight);
  FreeAndNil(TextOutDrive);
  FreeAndNil(TextOutUndefDrive);
  FreeAndNil(TextOutExtWidth);
  FreeAndNil(TextOutIntWidth);
  FreeAndNil(TextOutDropWidth);
  FreeAndNil(TextOutFullDropHeight);
  FreeAndNil(TextOutDropHeight);
  FreeAndNil(TextOutScrHeight);
  FreeAndNil(TextOutScrLength);
  FreeAndNil(TextOutHorizLength);
  FreeAndNil(TextOutAxeX);
  FreeAndNil(TextOutRadius);
  FreeAndNil(TextOutForDesigner);
  FreeAndNil(TextOutMinSideGap);
  FreeAndNil(TextOutPlasticSpacers);
  FreeAndNil(TextOutSteelSpacers);
  FreeAndNil(TextOutMovingCount);
  FreeAndNil(TextOutSteelS);
  FreeAndNil(TextOutPlasticS);
  FreeAndNil(TextOutFixedCount);
  FreeAndNil(TextOutPlasticSheet);
  FreeAndNil(TextOutMovingWeight);
  FreeAndNil(TextOutMinTorque);
  FreeAndNil(TextOutEquationFile);
  FreeAndNil(TextOutPlasticWeight);
end.
