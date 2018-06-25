inherited fFormChangePwd: TfFormChangePwd
  ClientHeight = 173
  ClientWidth = 294
  Caption = #20462#25913#23494#30721
  ExplicitWidth = 300
  ExplicitHeight = 198
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 128
    Top = 139
    ExplicitLeft = 128
    ExplicitTop = 139
  end
  inherited BtnExit: TUniButton
    Left = 211
    Top = 139
    ExplicitLeft = 211
    ExplicitTop = 139
  end
  inherited PanelWork: TUniSimplePanel
    Width = 278
    Height = 123
    object UniLabel1: TUniLabel
      Left = 16
      Top = 20
      Width = 40
      Height = 13
      Hint = ''
      Caption = #26087#23494#30721':'
      TabOrder = 4
    end
    object EditOld: TUniEdit
      Left = 76
      Top = 18
      Width = 165
      Hint = ''
      PasswordChar = '*'
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 1
    end
    object UniLabel2: TUniLabel
      Left = 16
      Top = 79
      Width = 52
      Height = 13
      Hint = ''
      Caption = #20877#36755#19968#27425':'
      TabOrder = 5
    end
    object EditAgain: TUniEdit
      Left = 76
      Top = 74
      Width = 165
      Hint = ''
      PasswordChar = '*'
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 3
    end
    object UniLabel3: TUniLabel
      Left = 16
      Top = 51
      Width = 40
      Height = 13
      Hint = ''
      Caption = #26032#23494#30721':'
      TabOrder = 6
    end
    object EditNew: TUniEdit
      Left = 76
      Top = 46
      Width = 165
      Hint = ''
      PasswordChar = '*'
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 2
    end
  end
end
