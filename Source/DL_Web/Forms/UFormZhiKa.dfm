inherited fFormZhiKa: TfFormZhiKa
  ClientHeight = 609
  ClientWidth = 578
  Caption = #32440#21345
  ExplicitWidth = 584
  ExplicitHeight = 638
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 414
    Top = 575
    TabOrder = 1
    ExplicitLeft = 414
    ExplicitTop = 575
  end
  inherited BtnExit: TUniButton
    Left = 495
    Top = 575
    TabOrder = 2
    ExplicitLeft = 495
    ExplicitTop = 575
  end
  inherited PanelWork: TUniSimplePanel
    Width = 562
    Height = 559
    TabOrder = 0
    ExplicitWidth = 562
    ExplicitHeight = 559
    object EditName: TUniEdit
      Left = 68
      Top = 15
      Width = 185
      Hint = ''
      MaxLength = 100
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 1
    end
    object UniLabel1: TUniLabel
      Left = 8
      Top = 20
      Width = 54
      Height = 12
      Hint = ''
      Caption = #32440#21345#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 4
    end
    object UniLabel2: TUniLabel
      Left = 275
      Top = 20
      Width = 54
      Height = 12
      Hint = ''
      Caption = #21512#21516#32534#21495':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 5
    end
    object EditCID: TUniEdit
      Left = 338
      Top = 15
      Width = 190
      Hint = ''
      MaxLength = 15
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 2
      OnKeyPress = EditCIDKeyPress
    end
    object UniLabel3: TUniLabel
      Left = 8
      Top = 56
      Width = 54
      Height = 12
      Hint = ''
      Caption = #39033#30446#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 7
    end
    object EditProject: TUniEdit
      Left = 68
      Top = 51
      Width = 460
      Hint = ''
      MaxLength = 100
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 6
    end
    object EditSaleMan: TUniComboBox
      Left = 68
      Top = 87
      Width = 460
      Hint = ''
      Style = csDropDownList
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 8
      OnChange = EditSaleManChange
    end
    object UniLabel8: TUniLabel
      Left = 8
      Top = 92
      Width = 54
      Height = 12
      Hint = ''
      Caption = #19994#21153#20154#21592':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 9
    end
    object UniLabel9: TUniLabel
      Left = 8
      Top = 128
      Width = 54
      Height = 12
      Hint = ''
      Caption = #23458#25143#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 11
    end
    object EditCus: TUniComboBox
      Left = 68
      Top = 123
      Width = 460
      Hint = #25353#22238#36710#38190#26597#35810#23458#25143
      ShowHint = True
      ParentShowHint = False
      MaxLength = 35
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 10
      OnKeyPress = EditCusKeyPress
    end
    object UniLabel13: TUniLabel
      Left = 275
      Top = 162
      Width = 54
      Height = 12
      Hint = ''
      Caption = #25552#36135#26102#38271':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 14
    end
    object UniLabel14: TUniLabel
      Left = 8
      Top = 200
      Width = 54
      Height = 12
      Hint = ''
      Caption = #20184#27454#26041#24335':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 18
    end
    object UniLabel6: TUniLabel
      Left = 275
      Top = 200
      Width = 54
      Height = 12
      Hint = ''
      Caption = #39044#20184#37329#39069':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 19
    end
    object EditMoney: TUniEdit
      Left = 338
      Top = 195
      Width = 190
      Hint = ''
      MaxLength = 6
      Text = '0'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 17
    end
    object EditDays: TUniDateTimePicker
      Left = 338
      Top = 158
      Width = 190
      Hint = ''
      DateTime = 43224.000000000000000000
      DateFormat = 'yyyy-MM-dd'
      TimeFormat = 'HH:mm:ss'
      TabOrder = 12
    end
    object Label1: TUniLabel
      Left = 532
      Top = 200
      Width = 12
      Height = 12
      Hint = ''
      Caption = #20803
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 20
    end
    object EditPayment: TUniComboBox
      Left = 68
      Top = 195
      Width = 185
      Hint = ''
      MaxLength = 20
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 16
    end
    object Grid1: TUniStringGrid
      Left = 8
      Top = 255
      Width = 542
      Height = 295
      Hint = #21452#20987#32534#36753
      ShowHint = True
      ParentShowHint = False
      FixedCols = 0
      FixedRows = 0
      ColCount = 8
      Options = [goVertLine, goHorzLine, goEditing, goAlwaysShowEditor, goFixedColClick
      ShowColumnTitles = True
      Columns = <
        item
          Title.Caption = #27700#27877#32534#21495
          Width = 100
        end
        item
          Title.Caption = #27700#27877#21517#31216
          Width = 145
        end
        item
          Title.Caption = #21333#20215'('#20803'/'#21544')'
          Width = 75
        end
        item
          Title.Caption = #36820#21033'('#20215#24046')'
          Width = 72
        end
        item
          Title.Caption = #36816#36153'('#20803'/'#21544')'
          Width = 72
        end
        item
          Title.Caption = #21150#29702#37327'('#21544')'
          Width = 72
        end
        item
          Title.Caption = #21253#35013#31867#22411
          Width = 0
        end
        item
          Title.Caption = #36873#20013
          Width = 32
        end>
      OnClick = Grid1Click
      Anchors = [akLeft, akTop, akRight, akBottom
      TabOrder = 22
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
    end
    object Label3: TUniLabel
      Left = 8
      Top = 237
      Width = 54
      Height = 12
      Hint = ''
      Caption = #32440#21345#26126#32454':'
      Anchors = [akLeft, akTop, akRight
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 21
    end
    object BtnGetContract: TUniBitBtn
      Left = 528
      Top = 15
      Width = 22
      Height = 22
      Hint = #36873#25321#21512#21516
      ShowHint = True
      ParentShowHint = False
      Caption = '...'
      TabOrder = 3
      OnClick = BtnGetContractClick
    end
    object Label2: TUniLabel
      Left = 8
      Top = 164
      Width = 54
      Height = 12
      Hint = ''
      Caption = #25552#36135#26041#24335':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 15
    end
    object EditLading: TUniComboBox
      Left = 68
      Top = 159
      Width = 185
      Hint = ''
      Style = csDropDownList
      MaxLength = 20
      Text = ''
      Items.Strings = (
        'T.'#33258#25552
        'S.'#36865#36135
        'X.'#36816#21368)
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 13
    end
  end
end
