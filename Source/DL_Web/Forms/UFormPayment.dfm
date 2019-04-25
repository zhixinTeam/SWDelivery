inherited fFormPayment: TfFormPayment
  ClientHeight = 407
  ClientWidth = 410
  Caption = #36130#21153#22238#27454
  ExplicitWidth = 416
  ExplicitHeight = 436
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 244
    Top = 373
    TabOrder = 1
    ExplicitLeft = 244
    ExplicitTop = 373
  end
  inherited BtnExit: TUniButton
    Left = 327
    Top = 373
    TabOrder = 2
    ExplicitLeft = 327
    ExplicitTop = 373
  end
  inherited PanelWork: TUniSimplePanel
    Width = 394
    Height = 357
    TabOrder = 0
    ExplicitWidth = 394
    ExplicitHeight = 357
    object Label2: TUniLabel
      Left = 8
      Top = 20
      Width = 54
      Height = 12
      Hint = ''
      Caption = #19994#21153#20154#21592':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 2
    end
    object Label1: TUniLabel
      Left = 8
      Top = 56
      Width = 54
      Height = 12
      Hint = ''
      Caption = #23458#25143#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 4
    end
    object EditSaleMan: TUniComboBox
      Left = 68
      Top = 15
      Width = 314
      Hint = ''
      Style = csDropDownList
      Text = ''
      Anchors = [akLeft, akTop, akRight
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 1
      OnChange = EditSaleManChange
    end
    object EditCus: TUniComboBox
      Left = 68
      Top = 51
      Width = 314
      Hint = #25353#22238#36710#38190#26597#35810#23458#25143
      ShowHint = True
      ParentShowHint = False
      MaxLength = 35
      Text = ''
      Anchors = [akLeft, akTop, akRight
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 3
      OnKeyPress = EditCusKeyPress
      OnChange = EditCusChange
    end
    object Panel1: TUniSimplePanel
      Left = 8
      Top = 82
      Width = 407
      Height = 1
      Hint = ''
      ParentColor = False
      Border = True
      TabOrder = 5
    end
    object Label3: TUniLabel
      Left = 8
      Top = 100
      Width = 54
      Height = 12
      Hint = ''
      Caption = #20837#37329#24635#39069':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 8
    end
    object EditIn: TUniEdit
      Left = 68
      Top = 95
      Width = 110
      Hint = ''
      Text = '0'
      TabOrder = 6
      ReadOnly = True
    end
    object EditOut: TUniEdit
      Left = 265
      Top = 95
      Width = 100
      Hint = ''
      Text = '0'
      TabOrder = 7
      ReadOnly = True
    end
    object Label4: TUniLabel
      Left = 205
      Top = 100
      Width = 54
      Height = 12
      Hint = ''
      Caption = #20986#37329#24635#39069':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 10
    end
    object Label5: TUniLabel
      Left = 182
      Top = 100
      Width = 12
      Height = 12
      Hint = ''
      Caption = #20803
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 9
    end
    object Label6: TUniLabel
      Left = 370
      Top = 100
      Width = 12
      Height = 12
      Hint = ''
      Caption = #20803
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 11
    end
    object Panel2: TUniSimplePanel
      Left = 8
      Top = 130
      Width = 407
      Height = 1
      Hint = ''
      ParentColor = False
      Border = True
      TabOrder = 12
    end
    object Label7: TUniLabel
      Left = 8
      Top = 150
      Width = 54
      Height = 12
      Hint = ''
      Caption = #20184#27454#26041#24335':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 15
    end
    object EditType: TUniComboBox
      Left = 68
      Top = 145
      Width = 110
      Hint = ''
      MaxLength = 20
      Text = ''
      Anchors = [akLeft, akTop, akRight
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 13
    end
    object Label8: TUniLabel
      Left = 205
      Top = 150
      Width = 54
      Height = 12
      Hint = ''
      Caption = #32564#32435#37329#39069':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 16
    end
    object EditMoney: TUniEdit
      Left = 265
      Top = 145
      Width = 100
      Hint = ''
      Text = '0'
      TabOrder = 14
    end
    object Label9: TUniLabel
      Left = 370
      Top = 150
      Width = 12
      Height = 12
      Hint = ''
      Caption = #20803
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 17
    end
    object Label10: TUniLabel
      Left = 8
      Top = 180
      Width = 54
      Height = 12
      Hint = ''
      Caption = #22791#27880#20449#24687':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 18
    end
    object EditDesc: TUniMemo
      Left = 8
      Top = 200
      Width = 374
      Height = 145
      Hint = ''
      Lines.Strings = (
        #38144#21806#22238#27454#25110#39044#20184#27454)
      Anchors = [akLeft, akTop, akRight
      TabOrder = 19
    end
  end
end
