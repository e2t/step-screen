unit UMainForm;

{$mode objfpc}{$H+}

interface

uses
  ButtonPanel,
  Classes,
  ComCtrls,
  Controls,
  Dialogs,
  Forms,
  Graphics,
  Menus,
  StdCtrls,
  SysUtils,
  UPresenter,
  UViewPresenter;

type
  TSubMenuEvent = procedure(Sender: TObject) of object;

  { TMainForm }

  TMainForm = class(TForm, IView)
    Hz60Box: TCheckBox;
    MemoOutput: TMemo;
    SteelOnlyBox: TCheckBox;
    DepthBox: TEdit;
    GapBox: TComboBox;
    HsBox: TComboBox;
    HsLabel: TLabel;
    GapLabel: TLabel;
    DepthLabel: TLabel;
    TableLabel: TLabel;
    WsLabel: TLabel;
    PlateTable: TListView;
    WsBox: TComboBox;
    MainButtonPanel: TButtonPanel;
    MainMenu1: TMainMenu;
    GuiMenu: TMenuItem;
    OutMenu: TMenuItem;
    procedure OKButtonClick(Sender: TObject);
  private
    FPresenter: IViewPresenter;
    procedure CallTranslateUi(Sender: TObject);
    procedure CallTranslateOut(Sender: TObject);
    class procedure AddSubMenuInto(AMenu: TMenuItem; const AItems: TStrings;
      AEvent: TSubMenuEvent);
    class function GetSelectedSubMenuOf(AMenu: TMenuItem): Integer;
  public
    constructor Create(TheOwner: TComponent); override;
    { IView }
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

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

constructor TMainForm.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  { After all initialization }
  FPresenter := NewPresenter(self);
end;

procedure TMainForm.FillWidthSeries(const ASeries: TStrings);
begin
  WsBox.Items := ASeries;
end;

procedure TMainForm.SetWidthSerie(AIndex: Integer);
begin
  WsBox.ItemIndex := AIndex;
end;

procedure TMainForm.FillHeightSeries(const ASeries: TStrings);
begin
  HsBox.Items := ASeries;
end;

procedure TMainForm.SetHeightSerie(AIndex: Integer);
begin
  HsBox.ItemIndex := AIndex;
end;

procedure TMainForm.FillGaps(const ASeries: TStrings);
begin
  GapBox.Items := ASeries;
end;

procedure TMainForm.SetGap(AIndex: Integer);
begin
  GapBox.ItemIndex := AIndex;
end;

procedure TMainForm.FillPlates(const AItems: array of TStringList);
var
  Sl: TStrings;
  Row: TListItem;
begin
  for Sl in AItems do begin
    Row := PlateTable.Items.Add;
    Row.Caption := Sl[0];
    Row.SubItems := Sl.Slice(1);
  end;
end;

procedure TMainForm.SetPlatesAndSpacers(AIndex: Integer);
begin
  PlateTable.ItemIndex := AIndex;
end;

procedure TMainForm.SetWsLabel(const AText: String);
begin
  WsLabel.Caption := AText;
end;

procedure TMainForm.SetHsLabel(const AText: String);
begin
  HsLabel.Caption := AText;
end;

procedure TMainForm.SetGapLabel(const AText: String);
begin
  GapLabel.Caption := AText;
end;

procedure TMainForm.SetDepthLabel(const AText: String);
begin
  DepthLabel.Caption := AText;
end;

procedure TMainForm.SetPlateLabel(const AText: String);
begin
  TableLabel.Caption := AText;
end;

procedure TMainForm.SetSteelOnlyLabel(const AText: String);
begin
  SteelOnlyBox.Caption := AText;
end;

procedure TMainForm.SetTitle(const AText: String);
begin
  Caption := AText;
  Application.Title := AText;
end;

class procedure TMainForm.AddSubMenuInto(AMenu: TMenuItem;
  const AItems: TStrings; AEvent: TSubMenuEvent);
var
  I: Integer;
  X: array of TMenuItem = nil;
begin
  SetLength(X, AItems.Count);
  for I := Low(X) to High(X) do begin
    X[I] := TMenuItem.Create(AMenu);
    X[I].Caption := AItems[I];
    X[I].RadioItem := True;
    X[I].AutoCheck := True;
    X[I].OnClick := AEvent;
  end;
  AMenu.Add(X);
end;

class function TMainForm.GetSelectedSubMenuOf(AMenu: TMenuItem): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to AMenu.Count - 1 do
    if AMenu.Items[I].Checked then begin
      Result := I;
      break;
    end;
end;

procedure TMainForm.AddUiSubMenu(const AItems: TStrings);
begin
  AddSubMenuInto(GuiMenu, AItems, @CallTranslateUi);
end;

procedure TMainForm.SelectUiSubMenu(AIndex: Integer);
begin
  GuiMenu.Items[AIndex].Checked := True;
end;

function TMainForm.GetUiSubMenuSelected: Integer;
begin
  Result := GetSelectedSubMenuOf(GuiMenu);
end;

procedure TMainForm.OKButtonClick(Sender: TObject);
begin
  FPresenter.Run;
end;

procedure TMainForm.CallTranslateUi(Sender: TObject);
begin
  FPresenter.TranslateUi;
end;

procedure TMainForm.CallTranslateOut(Sender: TObject);
begin
  FPresenter.TranslateOut;
end;

procedure TMainForm.SetHeaderFixed(const AText: String);
begin
  PlateTable.Column[0].Caption := AText;
end;

procedure TMainForm.SetHeaderMoving(const AText: String);
begin
  PlateTable.Column[1].Caption := AText;
end;

procedure TMainForm.SetHeaderSpacer(const AText: String);
begin
  PlateTable.Column[2].Caption := AText;
end;

procedure TMainForm.SetRunLabel(const AText: String);
begin
  MainButtonPanel.OKButton.Caption := AText;
end;

procedure TMainForm.SetUiMenuLabel(const AText: String);
begin
  GuiMenu.Caption := AText;
end;

procedure TMainForm.SetOutMenuLabel(const AText: String);
begin
  OutMenu.Caption := AText;
end;

procedure TMainForm.FillSpacers(const AItems: array of String);
var
  I: Integer;
begin
  for I := Low(AItems) to High(AItems) do
    PlateTable.Items[I].SubItems[1] := AItems[I];
end;

procedure TMainForm.AddOutSubMenu(const AItems: TStrings);
begin
  AddSubMenuInto(OutMenu, AItems, @CallTranslateOut);
end;

procedure TMainForm.SelectOutSubMenu(AIndex: Integer);
begin
  OutMenu.Items[AIndex].Checked := True;
end;

function TMainForm.GetOutSubMenuSelected: Integer;
begin
  Result := GetSelectedSubMenuOf(OutMenu);
end;

function TMainForm.GetWsIndex: Integer;
begin
  Result := WsBox.ItemIndex;
end;

function TMainForm.GetHsIndex: Integer;
begin
  Result := HsBox.ItemIndex;
end;

function TMainForm.GetGapIndex: Integer;
begin
  Result := GapBox.ItemIndex;
end;

function TMainForm.GetDepthText: String;
begin
  Result := DepthBox.Text;
end;

function TMainForm.GetPlateIndex: Integer;
begin
  Result := PlateTable.ItemIndex;
end;

function TMainForm.GetSteelOnly: Boolean;
begin
  Result := SteelOnlyBox.Checked;
end;

procedure TMainForm.PrintText(const AText: String);
begin
  MemoOutput.Text := AText;
end;

function TMainForm.GetIs60Hz: Boolean;
begin
  Result := Hz60Box.Checked;
end;

procedure TMainForm.Set60HzLabel(const AText: String);
begin
  Hz60Box.Caption := AText;
end;

end.
