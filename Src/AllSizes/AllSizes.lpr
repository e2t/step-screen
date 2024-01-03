program AllSizes;

uses
  Model,
  UPresenter,
  L10n,
  SysUtils;

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

const
  HeapFile = 'heap.trc';
var
  Presenter: TPresenter;
begin
  {$IFDEF DEBUG}
  if FileExists(HeapFile) then
    DeleteFile(HeapFile);
  SetHeapTraceOutput(HeapFile);
  {$ENDIF}

  Presenter := TPresenter.Create;
  CalcAllSizes(Presenter);
  Presenter.Free;
  ReadLn;
end.
