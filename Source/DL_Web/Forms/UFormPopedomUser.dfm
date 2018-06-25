inherited fFormPopedomUser: TfFormPopedomUser
  ClientHeight = 327
  ClientWidth = 312
  Caption = #31995#32479#29992#25143
  ExplicitWidth = 318
  ExplicitHeight = 356
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 146
    Top = 293
    TabOrder = 1
    ExplicitLeft = 122
    ExplicitTop = 135
  end
  inherited BtnExit: TUniButton
    Left = 229
    Top = 293
    TabOrder = 2
    ExplicitLeft = 205
    ExplicitTop = 135
  end
  inherited PanelWork: TUniSimplePanel
    Width = 296
    Height = 277
    TabOrder = 0
    ExplicitWidth = 272
    ExplicitHeight = 119
    object EditName: TUniEdit
      Left = 65
      Top = 15
      Width = 220
      Hint = ''
      MaxLength = 32
      Text = ''
      TabOrder = 1
    end
    object UniLabel1: TUniLabel
      Left = 7
      Top = 20
      Width = 52
      Height = 13
      Hint = ''
      Caption = #29992#25143#21517#31216':'
      TabOrder = 2
    end
    object UniLabel2: TUniLabel
      Left = 7
      Top = 58
      Width = 52
      Height = 13
      Hint = ''
      Caption = #29992#25143#23494#30721':'
      TabOrder = 3
    end
    object EditPwd: TUniEdit
      Left = 65
      Top = 52
      Width = 220
      Hint = ''
      PasswordChar = '*'
      MaxLength = 16
      Text = ''
      TabOrder = 4
    end
    object UniLabel3: TUniLabel
      Left = 7
      Top = 95
      Width = 52
      Height = 13
      Hint = ''
      Caption = #30005#23376#37038#20214':'
      TabOrder = 5
    end
    object EditMail: TUniEdit
      Left = 65
      Top = 90
      Width = 220
      Hint = ''
      MaxLength = 25
      Text = ''
      TabOrder = 6
    end
    object UniLabel4: TUniLabel
      Left = 7
      Top = 132
      Width = 52
      Height = 13
      Hint = ''
      Caption = #32852#31995#30005#35805':'
      TabOrder = 7
    end
    object EditPhone: TUniEdit
      Left = 65
      Top = 128
      Width = 220
      Hint = ''
      MaxLength = 15
      Text = ''
      TabOrder = 8
    end
    object UniLabel5: TUniLabel
      Left = 7
      Top = 170
      Width = 46
      Height = 13
      Hint = ''
      Caption = #25152' '#22312' '#32452':'
      TabOrder = 9
    end
    object EditGroup: TUniComboBox
      Left = 65
      Top = 165
      Width = 220
      Hint = ''
      Style = csDropDownList
      Text = ''
      TabOrder = 10
    end
  end
end
