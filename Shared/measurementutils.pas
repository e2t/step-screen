unit MeasurementUtils;

{$mode ObjFPC}{$H+}

interface

type
  TFloatTransform = function(Value: ValReal): ValReal;

function ToSIConverter(const Units: String): TFloatTransform;
function FromSIConverter(const Units: String): TFloatTransform;
function SI(Value: ValReal; const Units: String): ValReal;
function FromSI(const Units: String; Value: ValReal): ValReal;

implementation

uses
  Fgl,
  Math;

type
  TUnitConverter = record
    ToSI, FromSI: TFloatTransform;
  end;

  TConverterDict = specialize TFPGMap<String, TUnitConverter>;

function SameFloat(Value: ValReal): ValReal;
begin
  Result := Value;
end;

function Reduce1e3(Value: ValReal): ValReal;
begin
  Result := Value / 1e3;
end;

function Increase1e3(Value: ValReal): ValReal;
begin
  Result := Value * 1e3;
end;

function Reduce1e6(Value: ValReal): ValReal;
begin
  Result := Value / 1e6;
end;

function Increase1e6(Value: ValReal): ValReal;
begin
  Result := Value * 1e6;
end;

function Reduce60(Value: ValReal): ValReal;
begin
  Result := Value / 60;
end;

function Increase60(Value: ValReal): ValReal;
begin
  Result := Value * 60;
end;

function Reduce25_4(Value: ValReal): ValReal;
begin
  Result := Value / 25.4;
end;

function Increase25_4(Value: ValReal): ValReal;
begin
  Result := Value * 25.4;
end;

const
  AsIs: TUnitConverter = (ToSI: @SameFloat; FromSI: @SameFloat);

var
  ConverterDict: TConverterDict;

procedure AddConverter(const Units: String; ToSI, FromSI: TFloatTransform);
var
  Uc: TUnitConverter;
begin
  Uc.ToSI := ToSI;
  Uc.FromSI := FromSI;
  ConverterDict.Add(Units, Uc);
end;

function ToSIConverter(const Units: String): TFloatTransform;
begin
  Result := ConverterDict.KeyData[Units].ToSI;
end;

function SI(Value: ValReal; const Units: String): ValReal;
begin
  Result := ConverterDict.KeyData[Units].ToSI(Value);
end;

function FromSIConverter(const Units: String): TFloatTransform;
begin
  Result := ConverterDict.KeyData[Units].FromSI;
end;

function FromSI(const Units: String; Value: ValReal): ValReal;
begin
  Result := ConverterDict.KeyData[Units].FromSI(Value);
end;

initialization
  ConverterDict := TConverterDict.Create;
  ConverterDict.Add('', AsIs);
  AddConverter('deg', @DegToRad, @RadToDeg);
  AddConverter('gram', @Reduce1e3, @Increase1e3);
  ConverterDict.Add('kg', AsIs);
  AddConverter('kW', @Increase1e3, @Reduce1e3);
  AddConverter('l/sec', @Reduce1e3, @Increase1e3);
  ConverterDict.Add('meter', AsIs);
  AddConverter('mm', @Reduce1e3, @Increase1e3);
  AddConverter('MPa', @Increase1e6, @Reduce1e6);
  ConverterDict.Add('Nm', AsIs);
  ConverterDict.Add('rad', AsIs);
  AddConverter('rpm', @Reduce60, @Increase60);
  AddConverter('inch', @Reduce25_4, @Increase25_4);
  ConverterDict.Add('Hz', AsIs);
end.
