inherited fFormZKPrice: TfFormZKPrice
  ClientHeight = 244
  ClientWidth = 466
  Caption = #32440#21345#35843#20215
  ExplicitWidth = 472
  ExplicitHeight = 273
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 300
    Top = 210
    ExplicitLeft = 300
    ExplicitTop = 210
  end
  inherited BtnExit: TUniButton
    Left = 383
    Top = 210
    ExplicitLeft = 383
    ExplicitTop = 210
  end
  inherited PanelWork: TUniSimplePanel
    Width = 450
    Height = 194
    ExplicitWidth = 450
    ExplicitHeight = 194
    object Label1: TUniLabel
      Left = 8
      Top = 20
      Width = 54
      Height = 12
      Hint = ''
      Caption = #27700#27877#21697#31181':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 1
    end
    object EditStock: TUniEdit
      Left = 68
      Top = 15
      Width = 370
      Hint = ''
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      ReadOnly = True
    end
    object Label2: TUniLabel
      Left = 8
      Top = 55
      Width = 54
      Height = 12
      Hint = ''
      Caption = #38144#21806#20215#26684':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 3
    end
    object EditPrice: TUniEdit
      Left = 68
      Top = 50
      Width = 370
      Hint = ''
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      ReadOnly = True
    end
    object Label3: TUniLabel
      Left = 8
      Top = 91
      Width = 54
      Height = 12
      Hint = ''
      Caption = #26032' '#20215' '#26684':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 5
    end
    object EditNew: TUniEdit
      Left = 68
      Top = 86
      Width = 370
      Hint = ''
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 6
    end
    object Check1: TUniCheckBox
      Left = 8
      Top = 128
      Width = 185
      Height = 17
      Hint = ''
      Caption = #26032#21333#20215#29983#25928#21518#35299#20923#32440#21345'.'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 7
    end
    object Check2: TUniCheckBox
      Left = 8
      Top = 150
      Width = 185
      Height = 17
      Hint = ''
      Caption = #22312#21407#21333#20215#22522#30784#19978#24212#29992#26032#21333#20215'.'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 8
    end
  end
end
