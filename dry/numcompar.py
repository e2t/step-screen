from math import isclose

STD_ACCURACY = 1e-6


def is_equal(a: float, b: float, acc: float = STD_ACCURACY) -> bool:
    return isclose(a, b, abs_tol=acc)


def is_more(large: float, small: float, acc: float = STD_ACCURACY) -> bool:
    return not is_equal(large, small, acc) and large > small


def is_moreeq(large: float, small: float, acc: float = STD_ACCURACY) -> bool:
    return large > small or is_equal(large, small, acc)


def is_less(small: float, large: float, acc: float = STD_ACCURACY) -> bool:
    return not is_equal(small, large, acc) and small < large


def is_lesseq(small: float, large: float, acc: float = STD_ACCURACY) -> bool:
    return small < large or is_equal(small, large, acc)


# function IsThis(const Condition: Boolean; const Message: string): Boolean;
# begin
#   Result := Condition;
#   if not Condition then
#     WriteLn(Message);
# end;

# function IsPositiveInt(const Value: Integer): Boolean;
# begin
#   Result := IsThis(Value > 0, 'Ожидается целое число больше нуля.');
# end;

# function IsPositiveFloat(const Value: Double): Boolean;
# begin
#   Result := IsThis(IsMore(Value, 0), 'Ожидается число больше нуля.');
# end;

# function IsPositiveOrZeroFloat(const Value: Double): Boolean;
# begin
#   Result := IsThis(IsMoreEq(Value, 0), 'Ожидается число не меньше нуля.');
# end;

# function IsNonZeroFloat(const Value: Double): Boolean;
# begin
#   Result := IsThis(not IsEqual(Value, 0), 'Ожидается число, не равное нулю.')
# end;
