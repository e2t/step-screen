unit UModelPresenter;

{$mode ObjFPC}{$H+}

interface

uses
  L10n;

type
  IModelPresenter = interface
    procedure LogError(SpecMap: TTranslate; const Args: array of const);
    procedure AddOutput(SpecMap: TTranslate; const Args: array of const);
    procedure AddOutput(const AText: String);
  end;

implementation

end.
