unit SettingsForm;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Maze.Settings;

type
  /// <summary>
  ///   Dialog form allowing the user to configure maze generation settings.
  /// </summary>
  TSettingsForm = class(TForm)
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    lblAlgorithm: TLabel;
    cbAlgorithm: TComboBox;
  private
    FSettings: TMazeSettings;
    procedure LoadFromSettings;
    procedure SaveToSettings;
  public
    /// <summary>
    ///   Shows the dialog for the given settings and, if the user confirms,
    ///   returns True and writes the updated values back to <paramref name="ASettings"/>.
    /// </summary>
    class function Execute(var ASettings: TMazeSettings): Boolean; static;
  end;

implementation

{$R *.dfm}

{ TSettingsForm }

class function TSettingsForm.Execute(var ASettings: TMazeSettings): Boolean;
var
  LForm: TSettingsForm;
begin
  LForm := TSettingsForm.Create(nil);
  try
    LForm.FSettings := ASettings;
    LForm.LoadFromSettings;

    Result := LForm.ShowModal = mrOk;
    if Result then begin
      LForm.SaveToSettings;
      ASettings := LForm.FSettings;
    end;
  finally
    LForm.Free;
  end;
end;

procedure TSettingsForm.LoadFromSettings;
var
  LNames: TArray<string>;
  LName: string;
  LCurrentName: string;
  LIndex: Integer;
begin
  cbAlgorithm.Items.Clear;

  LNames := GetAllAlgorithmDisplayNames;
  for LName in LNames do begin
    cbAlgorithm.Items.Add(LName);
  end;

  if cbAlgorithm.Items.Count > 0 then begin
    LCurrentName := TMazeSettings.AlgorithmToDisplayName(FSettings.Algorithm);
    LIndex := cbAlgorithm.Items.IndexOf(LCurrentName);
    if LIndex >= 0 then begin
      cbAlgorithm.ItemIndex := LIndex;
    end else begin
      cbAlgorithm.ItemIndex := 0;
    end;
  end;
end;

procedure TSettingsForm.SaveToSettings;
var
  LName: string;
begin
  if (cbAlgorithm.ItemIndex >= 0) and (cbAlgorithm.ItemIndex < cbAlgorithm.Items.Count) then begin
    LName := cbAlgorithm.Items[cbAlgorithm.ItemIndex];
    FSettings.Algorithm := TMazeSettings.DisplayNameToAlgorithm(LName);
  end;
end;

end.
