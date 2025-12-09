object SettingsForm: TSettingsForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 180
  ClientWidth = 380
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object lblAlgorithm: TLabel
    Left = 20
    Top = 28
    Width = 57
    Height = 15
    Caption = '&Algorithm:'
    FocusControl = cbAlgorithm
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 139
    Width = 380
    Height = 41
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    DesignSize = (
      380
      41)
    object btnOK: TButton
      Left = 206
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 287
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object cbAlgorithm: TComboBox
    Left = 20
    Top = 48
    Width = 260
    Height = 23
    Style = csDropDownList
    TabOrder = 0
  end
end
