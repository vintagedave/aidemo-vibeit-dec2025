unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Maze.Generation,
  Maze.Settings,
  SettingsForm;

type
  /// <summary>
  ///   Main application form that hosts the maze display area and user controls
  ///   for regenerating the maze and adjusting generation settings.
  /// </summary>
  TForm1 = class(TForm)
    pnlTopControls: TPanel;
    btnSettings: TButton;
    btnRegenerate: TButton;
    MazeDisplayArea: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MazeDisplayAreaPaint(Sender: TObject);
    procedure btnRegenerateClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
  private
    FSettings: TMazeSettings;
    FMaze: TMazeGrid;
    /// <summary>
    ///   Generates a new maze grid using the current settings and replaces the
    ///   existing <see cref="FMaze"/> instance.
    /// </summary>
    procedure RegenerateMaze;
    /// <summary>
    ///   Renders the current maze grid into <see cref="MazeDisplayArea"/> by
    ///   drawing each cell as a filled rectangle, scaled to the control size.
    /// </summary>
    procedure DrawMaze;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnRegenerateClick(Sender: TObject);
begin
  RegenerateMaze;
  MazeDisplayArea.Invalidate;
end;

procedure TForm1.btnSettingsClick(Sender: TObject);
begin
  var LSettings := FSettings;
  if TSettingsForm.Execute(LSettings) then begin
    FSettings := LSettings;
    RegenerateMaze;
    MazeDisplayArea.Invalidate;
  end;
end;

procedure TForm1.DrawMaze;
begin
  MazeDisplayArea.Canvas.Brush.Color := clWhite;
  MazeDisplayArea.Canvas.FillRect(MazeDisplayArea.ClientRect);

  if not Assigned(FMaze) then begin
    Exit;
  end;

  var LCellWidth, LCellHeight: Double;

  if FMaze.Width > 0 then begin
    LCellWidth := MazeDisplayArea.ClientWidth / FMaze.Width;
  end else begin
    LCellWidth := 0;
  end;

  if FMaze.Height > 0 then begin
    LCellHeight := MazeDisplayArea.ClientHeight / FMaze.Height;
  end else begin
    LCellHeight := 0;
  end;

  for var LY := 0 to Pred(FMaze.Height) do begin
    for var LX := 0 to Pred(FMaze.Width) do begin
      if FMaze[LX, LY] = TMazeCellType.Wall then begin
        MazeDisplayArea.Canvas.Brush.Color := clBlack;
      end else begin
        MazeDisplayArea.Canvas.Brush.Color := clWhite;
      end;

      const LLeft = Round(LX * LCellWidth);
      const LTop = Round(LY * LCellHeight);
      const LRight = Round((LX + 1) * LCellWidth);
      const LBottom = Round((LY + 1) * LCellHeight);

      MazeDisplayArea.Canvas.FillRect(Rect(LLeft, LTop, LRight, LBottom));
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  FSettings := TMazeSettings.CreateDefault;
  RegenerateMaze;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FMaze);
end;

procedure TForm1.MazeDisplayAreaPaint(Sender: TObject);
begin
  DrawMaze;
end;

procedure TForm1.RegenerateMaze;
begin
  FreeAndNil(FMaze);

  const LMazeWidth = 41;
  const LMazeHeight = 41;

  var LGenerator: IMazeGenerator;

  LGenerator := CreateMazeGenerator(FSettings, LMazeWidth, LMazeHeight);
  FMaze := LGenerator.GenerateMaze;
end;

end.
