object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Maze Viewer'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnDestroy = FormDestroy
  DesignSize = (
    624
    441)
  TextHeight = 15
  object MazeDisplayArea: TPaintBox
    Left = 0
    Top = 49
    Width = 618
    Height = 392
    Anchors = [akLeft, akTop, akRight, akBottom]
    OnPaint = MazeDisplayAreaPaint
    ExplicitWidth = 624
  end
  object pnlTopControls: TPanel
    Left = 0
    Top = 0
    Width = 618
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 616
    DesignSize = (
      618
      49)
    object btnRegenerate: TButton
      Left = 20
      Top = 12
      Width = 105
      Height = 25
      Caption = '&Regenerate'
      TabOrder = 0
      OnClick = btnRegenerateClick
    end
    object btnSettings: TButton
      Left = 502
      Top = 12
      Width = 96
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Settings...'
      TabOrder = 1
      OnClick = btnSettingsClick
      ExplicitLeft = 500
    end
  end
end
