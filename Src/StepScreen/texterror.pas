unit TextError;

{$mode ObjFPC}{$H+}

interface

uses
  L10n;

var
  TextErrDepth, TextErrTooDeep, TextErrNonPlasticGap: TTranslate;

implementation

initialization
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
  TextErrNonPlasticGap.Add(Eng, 'For plastic spacers, only gaps are possible: %s.');
  TextErrNonPlasticGap.Add(Ukr, 'Для пластикових дистанційників можливі лише прозори: %s.');
  TextErrNonPlasticGap.Add(Rus, 'Для пластиковых дистанционеров возможны только прозоры: %s.');
  TextErrNonPlasticGap.Add(Lit, 'Plastikiniams tarpikliams galimi tik tarpai: %s.');
end.
