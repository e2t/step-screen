unit GuiMainForm;

{$MODE OBJFPC}
{$LONGSTRINGS ON}
{$ASSERTIONS ON}
{$RANGECHECKS ON}
{$BOOLEVAL OFF}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    ButtonRun: TButton;
    CheckBoxPlasticPart: TCheckBox;
    ComboBoxWidth: TComboBox;
    ComboBoxHeight: TComboBox;
    ComboBoxGap: TComboBox;
    ComboBoxThickness: TComboBox;
    EditDepth: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    MemoOutput: TMemo;
    procedure ButtonRunClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

uses
  Controller, LCLType;

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_RETURN) then
    Run();
end;

procedure TMainForm.ButtonRunClick(Sender: TObject);
begin
  Run();
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainFormInit();
end;

end.

