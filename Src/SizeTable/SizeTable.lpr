program SizeTable;

uses
  Model,
  L10n,
  SysUtils,
  UModelPresenter;

type
  TPresenter = class(TInterfacedObject, IModelPresenter)
    procedure LogError(SpecMap: TTranslate; const Args: array of const);
    procedure AddOutput(SpecMap: TTranslate; const Args: array of const);
    procedure AddOutput(const AText: String);
  end;

procedure TPresenter.LogError(SpecMap: TTranslate; const Args: array of const);
begin
  WriteLn(Format(SpecMap.KeyData[Eng], Args));
end;

procedure TPresenter.AddOutput(SpecMap: TTranslate; const Args: array of const);
begin
  WriteLn(Format(SpecMap.KeyData[Eng], Args));
end;

procedure TPresenter.AddOutput(const AText: String);
begin
  WriteLn(AText);
end;

var
  Presenter: TPresenter;
begin
  Presenter := TPresenter.Create;
  CalcSizeTable(Presenter);
  ReadLn;
end.
