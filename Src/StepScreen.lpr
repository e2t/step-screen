program StepScreen;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads,
 {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  GuiMainForm,
  Controller,
  ScreenCalculation,
  StrConvert;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  {$IFDEF WINDOWS} {$WARNINGS OFF}
  Application.MainFormOnTaskBar := True;
  {$WARNINGS ON} {$ENDIF}
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
