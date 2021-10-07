unit StrConvert;

{$MODE OBJFPC}
{$LONGSTRINGS ON}
{$ASSERTIONS ON}
{$RANGECHECKS ON}
{$BOOLEVAL OFF}

interface

uses SysUtils;

const
  TrueDefaultFormatSettings: TFormatSettings = (
    CurrencyFormat: 1;
    NegCurrFormat: 5;
    ThousandSeparator: ',';
    DecimalSeparator: '.';
    CurrencyDecimals: 2;
    DateSeparator: '-';
    TimeSeparator: ':';
    ListSeparator: ',';
    CurrencyString: '$';
    ShortDateFormat: 'd/m/y';
    LongDateFormat: 'dd" "mmmm" "yyyy';
    TimeAMString: 'AM';
    TimePMString: 'PM';
    ShortTimeFormat: 'hh:nn';
    LongTimeFormat: 'hh:nn:ss';
    ShortMonthNames: ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
    'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
    LongMonthNames: ('January', 'February', 'March', 'April', 'May',
    'June', 'July', 'August', 'September', 'October', 'November', 'December');
    ShortDayNames: ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
    LongDayNames: ('Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday');
    TwoDigitYearCenturyWindow: 50; );

procedure ConvertStrToFloat(const S: string; out IsNumber: Boolean; out Value: Double);
procedure ConvertStrToInt(const S: string; out IsNumber: Boolean; out Value: Integer);

implementation

procedure ConvertStrToFloat(const S: string; out IsNumber: Boolean; out Value: Double);
begin
  IsNumber := TryStrToFloat(S, Value);
  if not IsNumber then
    IsNumber := TryStrToFloat(S, Value, TrueDefaultFormatSettings);
end;

procedure ConvertStrToInt(const S: string; out IsNumber: Boolean; out Value: Integer);
begin
  IsNumber := TryStrToInt(S, Value);
end;

end.
