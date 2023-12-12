unit UMsgQueue;

{$mode ObjFPC}{$H+}

interface

uses
  L10n,
  SysUtils;

type
  TLangArray = array of TLanguage;

  IAddOnlyQueue = interface
    procedure Append(SpecMap: TTranslate; const Args: array of const);
    procedure Append(const AText: String);
  end;

  IMsgQueue = interface(IAddOnlyQueue)
    procedure Clear;
    function Text(ALang: TLanguage): String;
    function IsEmpty: Boolean;
  end;

function NewMsgQueue(ALangs: TLangArray): IMsgQueue;

implementation

uses
  Fgl;

type
  TMsgQueue = class sealed(TInterfacedObject, IMsgQueue)
    procedure Append(SpecMap: TTranslate; const Args: array of const);
    procedure Append(const AText: String);
    procedure Clear;
    function Text(ALang: TLanguage): String;
    function IsEmpty: Boolean;
  private
    FLangs: array of TLanguage;
    FQueue: specialize TFPGMap<TLanguage, TAnsiStringBuilder>;
  public
    constructor Create(ALangs: TLangArray);
  end;

function NewMsgQueue(ALangs: TLangArray): IMsgQueue;
begin
  Result := TMsgQueue.Create(ALangs);
end;

{ TMsgQueue }

constructor TMsgQueue.Create(ALangs: TLangArray);
var
  I: TLanguage;
begin
  FLangs := ALangs;
  FQueue := specialize TFPGMap<TLanguage, TAnsiStringBuilder>.Create;
  for I in FLangs do
    FQueue.Add(I, TAnsiStringBuilder.Create);
end;

procedure TMsgQueue.Append(SpecMap: TTranslate; const Args: array of const);
var
  I: TLanguage;
begin
  for I in FLangs do begin
    if FQueue.KeyData[I].Length > 0 then
      FQueue.KeyData[I].Append(LineEnding);
    FQueue.KeyData[I].Append(SpecMap.KeyData[I], Args);
  end;
end;

procedure TMsgQueue.Append(const AText: String);
var
  I: TLanguage;
begin
  for I in FLangs do begin
    if FQueue.KeyData[I].Length > 0 then
      FQueue.KeyData[I].Append(LineEnding);
    FQueue.KeyData[I].Append(AText);
  end;
end;

procedure TMsgQueue.Clear;
var
  I: TLanguage;
begin
  for I in FLangs do
    FQueue.KeyData[I].Clear;
end;

function TMsgQueue.Text(ALang: TLanguage): String;
begin
  Result := FQueue.KeyData[ALang].ToString;
end;

function TMsgQueue.IsEmpty: Boolean;
begin
  Result := FQueue.Data[0].Length = 0;
end;

end.
