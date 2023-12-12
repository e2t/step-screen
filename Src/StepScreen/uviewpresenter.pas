unit UViewPresenter;

{$mode ObjFPC}{$H+}

interface

uses
  Classes;

type
  IView = interface
    procedure FillWidthSeries(const ASeries: TStrings);
    procedure SetWidthSerie(AIndex: Integer);
    procedure FillHeightSeries(const ASeries: TStrings);
    procedure SetHeightSerie(AIndex: Integer);
    procedure FillGaps(const ASeries: TStrings);
    procedure SetGap(AIndex: Integer);
    procedure FillPlates(const AItems: array of TStringList);
    procedure SetPlatesAndSpacers(AIndex: Integer);
    procedure SetWsLabel(const AText: String);
    procedure SetHsLabel(const AText: String);
    procedure SetGapLabel(const AText: String);
    procedure SetDepthLabel(const AText: String);
    procedure SetPlateLabel(const AText: String);
    procedure SetSteelOnlyLabel(const AText: String);
    procedure SetHeaderFixed(const AText: String);
    procedure SetHeaderMoving(const AText: String);
    procedure SetHeaderSpacer(const AText: String);
    procedure Set60HzLabel(const AText: String);
    procedure FillSpacers(const AItems: array of String);
    function GetWsIndex: Integer;
    function GetHsIndex: Integer;
    function GetGapIndex: Integer;
    function GetDepthText: String;
    function GetPlateIndex: Integer;
    function GetSteelOnly: Boolean;
    function GetIs60Hz: Boolean;
    procedure PrintText(const AText: String);
    { base }
    procedure SetTitle(const AText: String);
    procedure SetRunLabel(const AText: String);
    procedure SetUiMenuLabel(const AText: String);
    procedure SetOutMenuLabel(const AText: String);
    procedure AddUiSubMenu(const AItems: TStrings);
    procedure SelectUiSubMenu(AIndex: Integer);
    function GetUiSubMenuSelected: Integer;
    procedure AddOutSubMenu(const AItems: TStrings);
    procedure SelectOutSubMenu(AIndex: Integer);
    function GetOutSubMenuSelected: Integer;
  end;

  IViewPresenter = interface
    procedure TranslateUi;
    procedure TranslateOut;
    procedure Run;
  end;

implementation

end.
