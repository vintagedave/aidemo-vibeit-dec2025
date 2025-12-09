program Project1;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Maze.Generation in 'Maze.Generation.pas',
  SettingsForm in 'SettingsForm.pas' {SettingsForm},
  Maze.Settings in 'Maze.Settings.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
