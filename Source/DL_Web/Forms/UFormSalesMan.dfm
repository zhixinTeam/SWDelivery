inherited fFormSalesMan: TfFormSalesMan
  ClientHeight = 351
  ClientWidth = 327
  Caption = #19994#21153#21592
  ExplicitWidth = 333
  ExplicitHeight = 376
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 163
    Top = 315
    TabOrder = 1
    ExplicitLeft = 163
    ExplicitTop = 315
  end
  inherited BtnExit: TUniButton
    Left = 244
    Top = 315
    TabOrder = 2
    ExplicitLeft = 244
    ExplicitTop = 315
  end
  inherited PanelWork: TUniSimplePanel
    Width = 311
    Height = 301
    TabOrder = 0
    ExplicitWidth = 311
    ExplicitHeight = 301
    object EditName: TUniEdit
      Left = 70
      Top = 15
      Width = 228
      Hint = ''
      MaxLength = 30
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight
      TabOrder = 1
    end
    object UniLabel1: TUniLabel
      Left = 8
      Top = 20
      Width = 54
      Height = 12
      Hint = ''
      Caption = #20154#21592#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 2
    end
    object UniLabel2: TUniLabel
      Left = 8
      Top = 95
      Width = 54
      Height = 12
      Hint = ''
      Caption = #25152#22312#21306#22495':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 6
    end
    object EditArea: TUniEdit
      Left = 70
      Top = 90
      Width = 228
      Hint = ''
      MaxLength = 50
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight
      TabOrder = 5
    end
    object EditMemo: TUniMemo
      Left = 8
      Top = 142
      Width = 290
      Height = 127
      Hint = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight, akBottom
      TabOrder = 8
    end
    object UniLabel13: TUniLabel
      Left = 8
      Top = 122
      Width = 60
      Height = 12
      Hint = ''
      Caption = #22791#27880#20449#24687#65306
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 7
    end
    object UniLabel6: TUniLabel
      Left = 8
      Top = 58
      Width = 54
      Height = 12
      Hint = ''
      Caption = #32852#31995#30005#35805':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 4
    end
    object EditPhone: TUniEdit
      Left = 70
      Top = 52
      Width = 228
      Hint = ''
      MaxLength = 20
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight
      TabOrder = 3
    end
    object Check1: TUniCheckBox
      Left = 8
      Top = 277
      Width = 195
      Height = 17
      Hint = ''
      Caption = #26080#25928#20154#21592': '#27491#24120#26597#35810#26102#19981#20104#26174#31034'.'
      Anchors = [akLeft, akBottom
      TabOrder = 9
    end
  end
end
