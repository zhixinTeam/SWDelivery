object fFormHYStock: TfFormHYStock
  Left = 668
  Top = 335
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 602
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 480
    Height = 602
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 324
      Top = 569
      Width = 70
      Height = 22
      Caption = #20445#23384
      TabOrder = 8
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 399
      Top = 569
      Width = 70
      Height = 22
      Caption = #21462#28040
      TabOrder = 9
      OnClick = BtnExitClick
    end
    object EditID: TcxButtonEdit
      Left = 81
      Top = 36
      Hint = 'T.P_ID'
      HelpType = htKeyword
      HelpKeyword = 'NU'
      ParentFont = False
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 15
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 0
      Width = 121
    end
    object EditStock: TcxComboBox
      Left = 81
      Top = 61
      Hint = 'T.P_Stock'
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 10
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 15
      Properties.OnEditValueChanged = EditStockPropertiesEditValueChanged
      TabOrder = 1
      Width = 185
    end
    object EditMemo: TcxMemo
      Left = 81
      Top = 136
      Hint = 'T.P_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      TabOrder = 6
      Height = 35
      Width = 331
    end
    object EditType: TcxComboBox
      Left = 329
      Top = 61
      Hint = 'T.P_Type'
      ParentFont = False
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'D=D'#12289#34955#35013
        'S=S'#12289#25955#35013)
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 125
    end
    object EditName: TcxTextEdit
      Left = 81
      Top = 86
      Hint = 'T.P_Name'
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 3
      Width = 185
    end
    object wPage: TcxPageControl
      Left = 11
      Top = 183
      Width = 428
      Height = 288
      ActivePage = Sheet1
      ParentColor = False
      ShowFrame = True
      Style = 9
      TabOrder = 7
      TabSlants.Kind = skCutCorner
      ClientRectBottom = 287
      ClientRectLeft = 1
      ClientRectRight = 427
      ClientRectTop = 19
      object Sheet1: TcxTabSheet
        Caption = #22269#26631#21442#25968
        ImageIndex = 0
        object Label1: TLabel
          Left = 9
          Top = 290
          Width = 72
          Height = 12
          Caption = '3'#22825#25239#21387#24378#24230':'
          Transparent = True
        end
        object Label2: TLabel
          Left = 9
          Top = 257
          Width = 72
          Height = 12
          Caption = '3'#22825#25239#25240#24378#24230':'
          Transparent = True
        end
        object Label3: TLabel
          Left = 12
          Top = 117
          Width = 54
          Height = 12
          Caption = #30897' '#21547' '#37327':'
          Transparent = True
        end
        object Label4: TLabel
          Left = 165
          Top = 39
          Width = 54
          Height = 12
          Caption = #19981' '#28342' '#29289':'
          Transparent = True
        end
        object Label5: TLabel
          Left = 12
          Top = 143
          Width = 54
          Height = 12
          Caption = #31264'    '#24230':'
          Transparent = True
        end
        object Label6: TLabel
          Left = 12
          Top = 91
          Width = 54
          Height = 12
          Caption = #32454'    '#24230':'
          Transparent = True
        end
        object Label7: TLabel
          Left = 13
          Top = 195
          Width = 54
          Height = 12
          Caption = #27695' '#31163' '#23376':'
          Transparent = True
        end
        object Label8: TLabel
          Left = 12
          Top = 13
          Width = 54
          Height = 12
          Caption = #27687' '#21270' '#38209':'
          Transparent = True
        end
        object Label9: TLabel
          Left = 296
          Top = 290
          Width = 78
          Height = 12
          Caption = '28'#22825#25239#21387#24378#24230':'
          Transparent = True
        end
        object Label10: TLabel
          Left = 296
          Top = 257
          Width = 78
          Height = 12
          Caption = '28'#22825#25239#25240#24378#24230':'
          Transparent = True
        end
        object Label11: TLabel
          Left = 165
          Top = 65
          Width = 54
          Height = 12
          Caption = #21021#20957#26102#38388':'
          Transparent = True
        end
        object Label12: TLabel
          Left = 165
          Top = 90
          Width = 54
          Height = 12
          Caption = #32456#20957#26102#38388':'
          Transparent = True
        end
        object Label13: TLabel
          Left = 165
          Top = 13
          Width = 54
          Height = 12
          Caption = #27604#34920#38754#31215':'
          Transparent = True
        end
        object Label14: TLabel
          Left = 165
          Top = 195
          Width = 54
          Height = 12
          Caption = #30789' '#37240' '#30416':'
          Transparent = True
        end
        object Label15: TLabel
          Left = 12
          Top = 39
          Width = 54
          Height = 12
          Caption = #19977#27687#21270#30827':'
        end
        object Label16: TLabel
          Left = 12
          Top = 65
          Width = 54
          Height = 12
          Caption = #28903' '#22833' '#37327':'
        end
        object Bevel1: TBevel
          Left = 12
          Top = 229
          Width = 434
          Height = 7
          Shape = bsBottomLine
        end
        object Label33: TLabel
          Left = 12
          Top = 168
          Width = 54
          Height = 12
          Caption = #28216' '#31163' '#38041':'
          Transparent = True
        end
        object Label35: TLabel
          Left = 165
          Top = 168
          Width = 54
          Height = 12
          Caption = #38041' '#30789' '#27604':'
          Transparent = True
        end
        object Label36: TLabel
          Left = 165
          Top = 142
          Width = 54
          Height = 12
          Caption = #20445' '#27700' '#29575':'
          Transparent = True
        end
        object Label37: TLabel
          Left = 165
          Top = 116
          Width = 54
          Height = 12
          Caption = #23433' '#23450' '#24615':'
          Transparent = True
        end
        object lbl6: TLabel
          Left = 20
          Top = 322
          Width = 60
          Height = 12
          Caption = '3'#22825#27700#21270#28909':'
          Transparent = True
        end
        object lbl7: TLabel
          Left = 309
          Top = 320
          Width = 66
          Height = 12
          Caption = '28'#22825#27700#21270#28909':'
          Transparent = True
        end
        object lbl8: TLabel
          Left = 155
          Top = 322
          Width = 60
          Height = 12
          Caption = '7'#22825#27700#21270#28909':'
          Transparent = True
        end
        object lbl10: TLabel
          Left = 153
          Top = 291
          Width = 72
          Height = 12
          Caption = '7'#22825#25239#21387#24378#24230':'
          Transparent = True
        end
        object lbl11: TLabel
          Left = 153
          Top = 256
          Width = 72
          Height = 12
          Caption = '7'#22825#25239#25240#24378#24230':'
          Transparent = True
        end
        object lbl12: TLabel
          Left = 306
          Top = 12
          Width = 54
          Height = 12
          Caption = #24178' '#32553' '#29575':'
          Transparent = True
        end
        object lbl13: TLabel
          Left = 306
          Top = 38
          Width = 54
          Height = 12
          Caption = #32784' '#30952' '#24615':'
          Transparent = True
        end
        object lbl14: TLabel
          Left = 324
          Top = 66
          Width = 35
          Height = 13
          Caption = 'C4AF:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #23435#20307
          Font.Style = []
          ParentFont = False
          Transparent = True
        end
        object lbl15: TLabel
          Left = 330
          Top = 92
          Width = 28
          Height = 13
          Caption = 'C3A:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #23435#20307
          Font.Style = []
          ParentFont = False
          Transparent = True
        end
        object lbl16: TLabel
          Left = 333
          Top = 116
          Width = 28
          Height = 13
          Caption = 'C3S:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #23435#20307
          Font.Style = []
          ParentFont = False
          Transparent = True
        end
        object lbl21: TLabel
          Left = 308
          Top = 143
          Width = 54
          Height = 12
          Caption = #38109#37240#19977#38041':'
          Transparent = True
        end
        object cxTextEdit2: TcxTextEdit
          Left = 67
          Top = 8
          Hint = 'T.P_MgO'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 0
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit3: TcxTextEdit
          Left = 68
          Top = 190
          Hint = 'T.P_CL'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 7
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit14: TcxTextEdit
          Left = 67
          Top = 86
          Hint = 'T.P_XiDu'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 3
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit16: TcxTextEdit
          Left = 67
          Top = 138
          Hint = 'T.P_ChouDu'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 5
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit15: TcxTextEdit
          Left = 220
          Top = 34
          Hint = 'T.P_BuRong'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 9
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit1: TcxTextEdit
          Left = 67
          Top = 112
          Hint = 'T.P_Jian'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 4
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit6: TcxTextEdit
          Left = 67
          Top = 34
          Hint = 'T.P_SO3'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 1
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit5: TcxTextEdit
          Left = 67
          Top = 60
          Hint = 'T.P_ShaoShi'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 2
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit13: TcxTextEdit
          Left = 220
          Top = 190
          Hint = 'T.P_KuangWu'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 15
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit7: TcxTextEdit
          Left = 220
          Top = 8
          Hint = 'T.P_BiBiao'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 8
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit4: TcxTextEdit
          Left = 220
          Top = 60
          Hint = 'T.P_ChuNing'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 10
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit8: TcxTextEdit
          Left = 220
          Top = 85
          Hint = 'T.P_ZhongNing'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 11
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit11: TcxTextEdit
          Left = 83
          Top = 254
          Hint = 'T.P_3DZhe'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 16
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 68
        end
        object cxTextEdit9: TcxTextEdit
          Left = 83
          Top = 287
          Hint = 'T.P_3DYa'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 17
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 68
        end
        object cxTextEdit12: TcxTextEdit
          Left = 375
          Top = 254
          Hint = 'T.P_28Zhe'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 18
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 73
        end
        object cxTextEdit10: TcxTextEdit
          Left = 375
          Top = 287
          Hint = 'T.P_28Ya'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 19
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 73
        end
        object cxTextEdit44: TcxTextEdit
          Left = 67
          Top = 163
          Hint = 'T.P_YLiGai'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 6
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit46: TcxTextEdit
          Left = 220
          Top = 163
          Hint = 'T.P_GaiGui'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 14
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit50: TcxTextEdit
          Left = 220
          Top = 137
          Hint = 'T.P_Water'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 13
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit51: TcxTextEdit
          Left = 220
          Top = 111
          Hint = 'T.P_AnDing'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 12
          Text = #21512#26684
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object Edt6: TcxTextEdit
          Left = 83
          Top = 319
          Hint = 'T.P_3DShui'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 20
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 68
        end
        object Edt7: TcxTextEdit
          Left = 375
          Top = 316
          Hint = 'T.P_28DShui'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 21
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 73
        end
        object Edt8: TcxTextEdit
          Left = 218
          Top = 319
          Hint = 'T.P_7DShui'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 22
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 73
        end
        object Edt12: TcxTextEdit
          Left = 218
          Top = 288
          Hint = 'T.P_7DYa'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 23
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 73
        end
        object Edt13: TcxTextEdit
          Left = 218
          Top = 253
          Hint = 'T.P_7DZhe'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 24
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 73
        end
        object Edt14: TcxTextEdit
          Left = 363
          Top = 7
          Hint = 'T.P_GanSuo'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 25
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object Edt15: TcxTextEdit
          Left = 363
          Top = 33
          Hint = 'T.P_NaiMo'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 26
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object Edt16: TcxTextEdit
          Left = 363
          Top = 59
          Hint = 'T.P_C4AF'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 27
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object Edt17: TcxTextEdit
          Left = 363
          Top = 85
          Hint = 'T.P_C3A'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 28
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object Edt18: TcxTextEdit
          Left = 363
          Top = 111
          Hint = 'T.P_C3S'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 29
          OnKeyPress = cxTextEdit2KeyPress
          Width = 76
        end
        object Edt31: TcxTextEdit
          Left = 364
          Top = 138
          Hint = 'T.P_LvSuanSG'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 30
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
      end
      object Sheet2: TcxTabSheet
        Caption = #26816#39564#21442#25968
        ImageIndex = 1
        object Label17: TLabel
          Left = 5
          Top = 311
          Width = 72
          Height = 12
          Caption = '3'#22825#25239#21387#24378#24230':'
          Transparent = True
        end
        object Label18: TLabel
          Left = 5
          Top = 259
          Width = 72
          Height = 12
          Caption = '3'#22825#25239#25240#24378#24230':'
          Transparent = True
        end
        object Label19: TLabel
          Left = 12
          Top = 117
          Width = 54
          Height = 12
          Caption = #30897' '#21547' '#37327':'
          Transparent = True
        end
        object Label20: TLabel
          Left = 165
          Top = 39
          Width = 54
          Height = 12
          Caption = #19981' '#28342' '#29289':'
          Transparent = True
        end
        object Label21: TLabel
          Left = 12
          Top = 143
          Width = 54
          Height = 12
          Caption = #31264'    '#24230':'
          Transparent = True
        end
        object Label22: TLabel
          Left = 12
          Top = 91
          Width = 54
          Height = 12
          Caption = #32454'    '#24230':'
          Transparent = True
        end
        object Label23: TLabel
          Left = 12
          Top = 195
          Width = 54
          Height = 12
          Caption = #27695' '#31163' '#23376':'
          Transparent = True
        end
        object Label24: TLabel
          Left = 12
          Top = 13
          Width = 54
          Height = 12
          Caption = #27687' '#21270' '#38209':'
          Transparent = True
        end
        object Label25: TLabel
          Left = 248
          Top = 311
          Width = 78
          Height = 12
          Caption = '28'#22825#25239#21387#24378#24230':'
          Transparent = True
        end
        object Label26: TLabel
          Left = 248
          Top = 259
          Width = 78
          Height = 12
          Caption = '28'#22825#25239#25240#24378#24230':'
          Transparent = True
        end
        object Label27: TLabel
          Left = 165
          Top = 65
          Width = 54
          Height = 12
          Caption = #21021#20957#26102#38388':'
          Transparent = True
        end
        object Label28: TLabel
          Left = 165
          Top = 91
          Width = 54
          Height = 12
          Caption = #32456#20957#26102#38388':'
          Transparent = True
        end
        object Label29: TLabel
          Left = 165
          Top = 13
          Width = 54
          Height = 12
          Caption = #27604#34920#38754#31215':'
          Transparent = True
        end
        object Label30: TLabel
          Left = 165
          Top = 117
          Width = 54
          Height = 12
          Caption = #23433' '#23450' '#24615':'
          Transparent = True
        end
        object Label31: TLabel
          Left = 12
          Top = 39
          Width = 54
          Height = 12
          Caption = #19977#27687#21270#30827':'
        end
        object Label32: TLabel
          Left = 12
          Top = 65
          Width = 54
          Height = 12
          Caption = #28903' '#22833' '#37327':'
        end
        object Bevel2: TBevel
          Left = 9
          Top = 242
          Width = 438
          Height = 7
          Shape = bsBottomLine
        end
        object Label34: TLabel
          Left = 12
          Top = 168
          Width = 54
          Height = 12
          Caption = #28216' '#31163' '#38041':'
          Transparent = True
        end
        object Label38: TLabel
          Left = 165
          Top = 195
          Width = 54
          Height = 12
          Caption = #30789' '#37240' '#30416':'
          Transparent = True
        end
        object Label39: TLabel
          Left = 165
          Top = 168
          Width = 54
          Height = 12
          Caption = #38041' '#30789' '#27604':'
          Transparent = True
        end
        object Label40: TLabel
          Left = 165
          Top = 142
          Width = 54
          Height = 12
          Caption = #20445' '#27700' '#29575':'
          Transparent = True
        end
        object Label41: TLabel
          Left = 314
          Top = 13
          Width = 54
          Height = 12
          Caption = #30707#33167#31181#31867':'
          Transparent = True
        end
        object Label42: TLabel
          Left = 314
          Top = 39
          Width = 54
          Height = 12
          Caption = #30707' '#33167' '#37327':'
        end
        object Label43: TLabel
          Left = 314
          Top = 65
          Width = 54
          Height = 12
          Caption = #28151#21512#26448#31867':'
        end
        object Label44: TLabel
          Left = 314
          Top = 91
          Width = 54
          Height = 12
          Caption = #28151#21512#26448#37327':'
          Transparent = True
        end
        object lbl1: TLabel
          Left = 314
          Top = 116
          Width = 54
          Height = 12
          Caption = #24178' '#32553' '#29575':'
          Transparent = True
        end
        object lbl2: TLabel
          Left = 314
          Top = 142
          Width = 54
          Height = 12
          Caption = #32784' '#30952' '#24615':'
          Transparent = True
        end
        object lbl3: TLabel
          Left = 332
          Top = 167
          Width = 35
          Height = 13
          Caption = 'C4AF:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #23435#20307
          Font.Style = []
          ParentFont = False
          Transparent = True
        end
        object lbl4: TLabel
          Left = 338
          Top = 194
          Width = 28
          Height = 13
          Caption = 'C3A:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #23435#20307
          Font.Style = []
          ParentFont = False
          Transparent = True
        end
        object lbl5: TLabel
          Left = 338
          Top = 220
          Width = 28
          Height = 13
          Caption = 'C3S:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #23435#20307
          Font.Style = []
          ParentFont = False
          Transparent = True
        end
        object lbl9: TLabel
          Left = 5
          Top = 279
          Width = 72
          Height = 12
          Caption = '7'#22825#25239#25240#24378#24230':'
          Transparent = True
        end
        object lbl17: TLabel
          Left = 5
          Top = 341
          Width = 72
          Height = 12
          Caption = '7'#22825#25239#21387#24378#24230':'
          Transparent = True
        end
        object lbl18: TLabel
          Left = 17
          Top = 365
          Width = 60
          Height = 12
          Caption = '3'#22825#27700#21270#28909':'
          Transparent = True
        end
        object lbl19: TLabel
          Left = 163
          Top = 365
          Width = 60
          Height = 12
          Caption = '7'#22825#27700#21270#28909':'
          Transparent = True
        end
        object lbl20: TLabel
          Left = 309
          Top = 365
          Width = 66
          Height = 12
          Caption = '28'#22825#27700#21270#28909':'
          Transparent = True
        end
        object lbl22: TLabel
          Left = 12
          Top = 222
          Width = 54
          Height = 12
          Caption = #38109#37240#19977#38041':'
          Transparent = True
        end
        object cxTextEdit17: TcxTextEdit
          Left = 67
          Top = 8
          Hint = 'E.R_MgO'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 0
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit18: TcxTextEdit
          Left = 67
          Top = 188
          Hint = 'E.R_CL'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 7
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit19: TcxTextEdit
          Left = 67
          Top = 86
          Hint = 'E.R_XiDu'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 3
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit20: TcxTextEdit
          Left = 67
          Top = 138
          Hint = 'E.R_ChouDu'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 5
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit21: TcxTextEdit
          Left = 220
          Top = 34
          Hint = 'E.R_BuRong'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 9
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit22: TcxTextEdit
          Left = 67
          Top = 112
          Hint = 'E.R_Jian'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 4
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit23: TcxTextEdit
          Left = 67
          Top = 34
          Hint = 'E.R_SO3'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 1
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit24: TcxTextEdit
          Left = 67
          Top = 60
          Hint = 'E.R_ShaoShi'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 2
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit25: TcxTextEdit
          Left = 220
          Top = 112
          Hint = 'E.R_AnDing'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 12
          Text = #21512#26684
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit26: TcxTextEdit
          Left = 220
          Top = 8
          Hint = 'E.R_BiBiao'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 8
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit27: TcxTextEdit
          Left = 220
          Top = 86
          Hint = 'E.R_ZhongNing'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 11
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit28: TcxTextEdit
          Left = 220
          Top = 60
          Hint = 'E.R_ChuNing'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 10
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit29: TcxTextEdit
          Left = 80
          Top = 255
          Hint = 'E.R_3DZhe1'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 16
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit30: TcxTextEdit
          Left = 80
          Top = 300
          Hint = 'E.R_3DYa1'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 19
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit31: TcxTextEdit
          Left = 328
          Top = 255
          Hint = 'E.R_28Zhe1'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 25
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit32: TcxTextEdit
          Left = 328
          Top = 300
          Hint = 'E.R_28Ya1'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 28
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit33: TcxTextEdit
          Left = 367
          Top = 255
          Hint = 'E.R_28Zhe2'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 26
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit34: TcxTextEdit
          Left = 406
          Top = 255
          Hint = 'E.R_28Zhe3'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 27
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit35: TcxTextEdit
          Left = 367
          Top = 300
          Hint = 'E.R_28Ya2'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 29
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit36: TcxTextEdit
          Left = 406
          Top = 300
          Hint = 'E.R_28Ya3'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 30
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit37: TcxTextEdit
          Left = 119
          Top = 255
          Hint = 'E.R_3DZhe2'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 17
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit38: TcxTextEdit
          Left = 119
          Top = 300
          Hint = 'E.R_3DYa2'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 20
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit39: TcxTextEdit
          Left = 159
          Top = 255
          Hint = 'E.R_3DZhe3'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 18
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit40: TcxTextEdit
          Left = 159
          Top = 300
          Hint = 'E.R_3DYa3'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 21
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit41: TcxTextEdit
          Left = 80
          Top = 317
          Hint = 'E.R_3DYa4'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 22
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit42: TcxTextEdit
          Left = 119
          Top = 317
          Hint = 'E.R_3DYa5'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 23
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit43: TcxTextEdit
          Left = 159
          Top = 317
          Hint = 'E.R_3DYa6'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bRight, bBottom]
          TabOrder = 24
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit47: TcxTextEdit
          Left = 328
          Top = 317
          Hint = 'E.R_28Ya4'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 31
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit48: TcxTextEdit
          Left = 367
          Top = 317
          Hint = 'E.R_28Ya5'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bRight, bBottom]
          TabOrder = 32
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit49: TcxTextEdit
          Left = 406
          Top = 317
          Hint = 'E.R_28Ya6'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bRight, bBottom]
          TabOrder = 33
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object cxTextEdit45: TcxTextEdit
          Left = 67
          Top = 163
          Hint = 'E.R_YLiGai'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 6
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit52: TcxTextEdit
          Left = 220
          Top = 190
          Hint = 'E.R_KuangWu'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 15
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit53: TcxTextEdit
          Left = 220
          Top = 163
          Hint = 'E.R_GaiGui'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 14
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit54: TcxTextEdit
          Left = 220
          Top = 137
          Hint = 'E.R_Water'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 13
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit55: TcxTextEdit
          Left = 372
          Top = 8
          Hint = 'E.R_SGType'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 34
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit56: TcxTextEdit
          Left = 372
          Top = 34
          Hint = 'E.R_SGValue'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 35
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit57: TcxTextEdit
          Left = 372
          Top = 60
          Hint = 'E.R_HHCType'
          ParentFont = False
          Properties.MaxLength = 32
          TabOrder = 36
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit58: TcxTextEdit
          Left = 372
          Top = 86
          Hint = 'E.R_HHCValue'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 37
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object Edt1: TcxTextEdit
          Left = 371
          Top = 111
          Hint = 'E.R_GanSuo'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 38
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object Edt2: TcxTextEdit
          Left = 371
          Top = 137
          Hint = 'E.R_NaiMo'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 39
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object Edt3: TcxTextEdit
          Left = 371
          Top = 163
          Hint = 'E.R_C4AF'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 40
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object Edt4: TcxTextEdit
          Left = 371
          Top = 190
          Hint = 'E.R_C3A'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 41
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object Edt5: TcxTextEdit
          Left = 371
          Top = 218
          Hint = 'E.R_C3S'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 42
          OnKeyPress = cxTextEdit2KeyPress
          Width = 76
        end
        object Edt9: TcxTextEdit
          Left = 80
          Top = 276
          Hint = 'E.R_7DZhe1'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 43
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt10: TcxTextEdit
          Left = 119
          Top = 276
          Hint = 'E.R_7DZhe2'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 44
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt11: TcxTextEdit
          Left = 159
          Top = 276
          Hint = 'E.R_7DZhe3'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 45
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt19: TcxTextEdit
          Left = 80
          Top = 338
          Hint = 'E.R_7DYa1'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 46
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt20: TcxTextEdit
          Left = 119
          Top = 338
          Hint = 'E.R_7DYa2'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 47
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt21: TcxTextEdit
          Left = 159
          Top = 338
          Hint = 'E.R_7DYa3'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 48
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt22: TcxTextEdit
          Left = 198
          Top = 338
          Hint = 'E.R_7DYa4'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 49
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt23: TcxTextEdit
          Left = 237
          Top = 338
          Hint = 'E.R_7DYa5'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 50
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt24: TcxTextEdit
          Left = 276
          Top = 338
          Hint = 'E.R_7DYa6'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 51
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt25: TcxTextEdit
          Left = 80
          Top = 362
          Hint = 'E.R_3DShui1'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 52
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt26: TcxTextEdit
          Left = 119
          Top = 362
          Hint = 'E.R_3DShui2'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 53
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt27: TcxTextEdit
          Left = 226
          Top = 362
          Hint = 'E.R_7DShui1'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 54
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt28: TcxTextEdit
          Left = 265
          Top = 362
          Hint = 'E.R_7DShui2'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 55
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt29: TcxTextEdit
          Left = 372
          Top = 361
          Hint = 'E.R_28DShui1'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bBottom]
          TabOrder = 56
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt30: TcxTextEdit
          Left = 411
          Top = 361
          Hint = 'E.R_28DShui2'
          ParentFont = False
          Properties.MaxLength = 20
          Style.Edges = [bLeft, bTop, bRight, bBottom]
          TabOrder = 57
          OnKeyPress = cxTextEdit2KeyPress
          Width = 42
        end
        object Edt32: TcxTextEdit
          Left = 68
          Top = 218
          Hint = 'E.R_LvSuanSG'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 58
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
      end
    end
    object EditQLevel: TcxTextEdit
      Left = 329
      Top = 86
      Hint = 'T.P_QLevel'
      ParentFont = False
      Properties.MaxLength = 20
      TabOrder = 4
      Width = 125
    end
    object cbb_GuoBiaoParam: TcxComboBox
      Left = 81
      Top = 111
      ParentFont = False
      Properties.DropDownRows = 10
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 15
      Properties.OnEditValueChanged = cbb_GuoBiaoParamPropertiesEditValueChanged
      TabOrder = 5
      Width = 185
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #21697#31181#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Group6: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item12: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #29289#26009#21517#31216':'
            Control = EditStock
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item2: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #27700#27877#31867#22411':'
            Control = EditType
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item3: TdxLayoutItem
            Caption = #21697#31181#31561#32423':'
            Control = EditName
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item4: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #24378#24230#31561#32423':'
            Control = EditQLevel
            ControlOptions.ShowBorder = False
          end
        end
        object dxlytmLayoutControl1Item5: TdxLayoutItem
          Caption = #22269#26631#21442#25968':'
          Control = cbb_GuoBiaoParam
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item8: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Item25: TdxLayoutItem
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = 'cxPageControl1'
        ShowCaption = False
        Control = wPage
        ControlOptions.AutoColor = True
        ControlOptions.ShowBorder = False
      end
      object dxLayoutControl1Group5: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avBottom
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item10: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button3'
          ShowCaption = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item11: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button4'
          ShowCaption = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
