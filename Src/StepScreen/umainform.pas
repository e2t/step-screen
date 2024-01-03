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
  GuiUtils,
  Menus,
  StdCtrls,
  SysUtils,
  UPresenter;

type
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
    { IBaseView }
    procedure PrintText(const AText: String);
    procedure SetTitle(const AText: String);
    procedure SetRunLabel(const AText: String);
    procedure SetUiMenuLabel(const AText: String);
    procedure SetOutMenuLabel(const AText: String);
    procedure AddUiSubMenu(AItems: TStrings);
    procedure SelectUiSubMenu(AIndex: Integer);
    function GetUiSubMenuSelected: Integer;
    procedure AddOutSubMenu(AItems: TStrings);
    procedure SelectOutSubMenu(AIndex: Integer);
    function GetOutSubMenuSelected: Integer;
    { IView }
    procedure FillWidthSeries(ASeries: TStrings);
    procedure SetWidthSerie(AIndex: Integer);
    procedure FillHeightSeries(ASeries: TStrings);
    procedure SetHeightSerie(AIndex: Integer);
    procedure FillGaps(ASeries: TStrings);
    procedure SetGap(AIndex: Integer);
    procedure FillColFixed(const AItems: array of String);
    procedure FillColMoving(const AItems: array of String);
    procedure FillColSpacer(const AItems: array of String);
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
    function GetWsIndex: Integer;
    function GetHsIndex: Integer;
    function GetGapIndex: Integer;
    function GetDepthText: String;
    function GetPlateIndex: Integer;
    function GetSteelOnly: Boolean;
    function GetIs60Hz: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

const
  ColFix = 0;
  ColMov = 1;
  ColSpacer = 2;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  FPresenter := NewPresenter(self);
  FPresenter.InitView;
end;

destructor TMainForm.Destroy;
begin
  FPresenter.Free;
  inherited;
end;

procedure TMainForm.FillWidthSeries(ASeries: TStrings);
begin
  WsBox.Items := ASeries;
end;

procedure TMainForm.SetWidthSerie(AIndex: Integer);
begin
  WsBox.ItemIndex := AIndex;
end;

procedure TMainForm.FillHeightSeries(ASeries: TStrings);
begin
  HsBox.Items := ASeries;
end;

procedure TMainForm.SetHeightSerie(AIndex: Integer);
begin
  HsBox.ItemIndex := AIndex;
end;

procedure TMainForm.FillGaps(ASeries: TStrings);
begin
  GapBox.Items := ASeries;
end;

procedure TMainForm.SetGap(AIndex: Integer);
begin
  GapBox.ItemIndex := AIndex;
end;

procedure TMainForm.FillColFixed(const AItems: array of String);
begin
  FillColumn(PlateTable, ColFix, AItems);
end;

procedure TMainForm.FillColMoving(const AItems: array of String);
begin
  FillColumn(PlateTable, ColMov, AItems);
end;

procedure TMainForm.FillColSpacer(const AItems: array of String);
begin
  FillColumn(PlateTable, ColSpacer, AItems);
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

procedure TMainForm.AddUiSubMenu(AItems: TStrings);
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
  PlateTable.Column[ColFix].Caption := AText;
end;

procedure TMainForm.SetHeaderMoving(const AText: String);
begin
  PlateTable.Column[ColMov].Caption := AText;
end;

procedure TMainForm.SetHeaderSpacer(const AText: String);
begin
  PlateTable.Column[ColSpacer].Caption := AText;
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

procedure TMainForm.AddOutSubMenu(AItems: TStrings);
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
