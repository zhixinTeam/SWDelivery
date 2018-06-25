object fFormHYRecord: TfFormHYRecord
  Left = 686
  Top = 220
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 613
  ClientWidth = 469
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
    Width = 469
    Height = 613
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    AutoControlTabOrders = False
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 313
      Top = 579
      Width = 70
      Height = 23
      Caption = #20445#23384
      TabOrder = 0
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 388
      Top = 579
      Width = 70
      Height = 23
      Caption = #21462#28040
      TabOrder = 1
      OnClick = BtnExitClick
    end
    object EditID: TcxButtonEdit
      Left = 81
      Top = 36
      Hint = 'E.R_SerialNo'
      HelpType = htKeyword
      HelpKeyword = 'NU'
      ParentFont = False
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 15
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 2
      Width = 121
    end
    object EditStock: TcxComboBox
      Left = 81
      Top = 61
      Hint = 'E.R_PID'
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 15
      Properties.OnEditValueChanged = EditStockPropertiesEditValueChanged
      TabOrder = 4
      Width = 128
    end
    object wPanel: TPanel
      Left = 23
      Top = 143
      Width = 415
      Height = 262
      Align = alClient
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 3
      object Label17: TLabel
        Left = 4
        Top = 325
        Width = 72
        Height = 12
        Caption = '3'#22825#25239#21387#24378#24230':'
        Transparent = True
      end
      object Label18: TLabel
        Left = 4
        Top = 271
        Width = 72
        Height = 12
        Caption = '3'#22825#25239#25240#24378#24230':'
        Transparent = True
      end
      object Label25: TLabel
        Left = 224
        Top = 325
        Width = 78
        Height = 12
        Caption = '28'#22825#25239#21387#24378#24230':'
        Transparent = True
      end
      object Label26: TLabel
        Left = 224
        Top = 271
        Width = 78
        Height = 12
        Caption = '28'#22825#25239#25240#24378#24230':'
        Transparent = True
      end
      object Bevel2: TBevel
        Left = 0
        Top = 254
        Width = 421
        Height = 7
        Shape = bsBottomLine
      end
      object Label19: TLabel
        Left = 2
        Top = 109
        Width = 54
        Height = 12
        Caption = #30897' '#21547' '#37327':'
        Transparent = True
      end
      object Label20: TLabel
        Left = 144
        Top = 31
        Width = 54
        Height = 12
        Caption = #19981' '#28342' '#29289':'
        Transparent = True
      end
      object Label21: TLabel
        Left = 2
        Top = 135
        Width = 54
        Height = 12
        Caption = #31264'    '#24230':'
        Transparent = True
      end
      object Label22: TLabel
        Left = 2
        Top = 83
        Width = 54
        Height = 12
        Caption = #32454'    '#24230':'
        Transparent = True
      end
      object Label23: TLabel
        Left = 2
        Top = 187
        Width = 54
        Height = 12
        Caption = #27695' '#31163' '#23376':'
        Transparent = True
      end
      object Label24: TLabel
        Left = 2
        Top = 5
        Width = 54
        Height = 12
        Caption = #27687' '#21270' '#38209':'
        Transparent = True
      end
      object Label27: TLabel
        Left = 144
        Top = 57
        Width = 54
        Height = 12
        Caption = #21021#20957#26102#38388':'
        Transparent = True
      end
      object Label28: TLabel
        Left = 144
        Top = 83
        Width = 54
        Height = 12
        Caption = #32456#20957#26102#38388':'
        Transparent = True
      end
      object Label29: TLabel
        Left = 144
        Top = 5
        Width = 54
        Height = 12
        Caption = #27604#34920#38754#31215':'
        Transparent = True
      end
      object Label30: TLabel
        Left = 144
        Top = 109
        Width = 54
        Height = 12
        Caption = #23433' '#23450' '#24615':'
        Transparent = True
      end
      object Label31: TLabel
        Left = 2
        Top = 31
        Width = 54
        Height = 12
        Caption = #19977#27687#21270#30827':'
      end
      object Label32: TLabel
        Left = 2
        Top = 57
        Width = 54
        Height = 12
        Caption = #28903' '#22833' '#37327':'
      end
      object Label34: TLabel
        Left = 2
        Top = 160
        Width = 54
        Height = 12
        Caption = #28216' '#31163' '#38041':'
        Transparent = True
      end
      object Label38: TLabel
        Left = 144
        Top = 187
        Width = 54
        Height = 12
        Caption = #30789' '#37240' '#30416':'
        Transparent = True
      end
      object Label39: TLabel
        Left = 144
        Top = 160
        Width = 54
        Height = 12
        Caption = #38041' '#30789' '#27604':'
        Transparent = True
      end
      object Label40: TLabel
        Left = 144
        Top = 134
        Width = 54
        Height = 12
        Caption = #20445' '#27700' '#29575':'
        Transparent = True
      end
      object Label41: TLabel
        Left = 292
        Top = 5
        Width = 54
        Height = 12
        Caption = #30707#33167#31181#31867':'
        Transparent = True
      end
      object Label42: TLabel
        Left = 292
        Top = 31
        Width = 54
        Height = 12
        Caption = #30707' '#33167' '#37327':'
      end
      object Label43: TLabel
        Left = 292
        Top = 57
        Width = 54
        Height = 12
        Caption = #28151#21512#26448#31867':'
      end
      object Label44: TLabel
        Left = 292
        Top = 83
        Width = 54
        Height = 12
        Caption = #28151#21512#26448#37327':'
        Transparent = True
      end
      object lbl1: TLabel
        Left = 303
        Top = 108
        Width = 42
        Height = 12
        Caption = #24178#32553#29575':'
        Transparent = True
      end
      object lbl2: TLabel
        Left = 290
        Top = 134
        Width = 54
        Height = 12
        Caption = #32784' '#30952' '#24615':'
        Transparent = True
      end
      object lbl3: TLabel
        Left = 308
        Top = 160
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
        Left = 314
        Top = 187
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
        Left = 314
        Top = 213
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
        Left = 4
        Top = 291
        Width = 72
        Height = 12
        Caption = '7'#22825#25239#25240#24378#24230':'
        Transparent = True
      end
      object lbl17: TLabel
        Left = 3
        Top = 356
        Width = 72
        Height = 12
        Caption = '7'#22825#25239#21387#24378#24230':'
        Transparent = True
      end
      object lbl18: TLabel
        Left = 10
        Top = 385
        Width = 60
        Height = 12
        Caption = '3'#22825#27700#21270#28909':'
        Transparent = True
      end
      object lbl19: TLabel
        Left = 167
        Top = 385
        Width = 60
        Height = 12
        Caption = '7'#22825#27700#21270#28909':'
        Transparent = True
      end
      object lbl20: TLabel
        Left = 7
        Top = 409
        Width = 66
        Height = 12
        Caption = '28'#22825#27700#21270#28909':'
        Transparent = True
      end
      object lbl6: TLabel
        Left = 11
        Top = 214
        Width = 46
        Height = 13
        Caption = #21161#30952#21058':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object lbl7: TLabel
        Left = 140
        Top = 214
        Width = 59
        Height = 13
        Caption = #21161#30952#21058#37327':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object lbl22: TLabel
        Left = 2
        Top = 238
        Width = 54
        Height = 12
        Caption = #38109#37240#19977#38041':'
        Transparent = True
      end
      object cxTextEdit29: TcxTextEdit
        Left = 73
        Top = 266
        Hint = 'E.R_3DZhe1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 16
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit30: TcxTextEdit
        Left = 73
        Top = 314
        Hint = 'E.R_3DYa1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 19
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit31: TcxTextEdit
        Left = 303
        Top = 266
        Hint = 'E.R_28Zhe1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 25
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit32: TcxTextEdit
        Left = 303
        Top = 314
        Hint = 'E.R_28Ya1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 28
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit33: TcxTextEdit
        Left = 343
        Top = 266
        Hint = 'E.R_28Zhe2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 26
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit34: TcxTextEdit
        Left = 382
        Top = 266
        Hint = 'E.R_28Zhe3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 27
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit35: TcxTextEdit
        Left = 343
        Top = 314
        Hint = 'E.R_28Ya2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 29
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit36: TcxTextEdit
        Left = 382
        Top = 314
        Hint = 'E.R_28Ya3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 30
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit37: TcxTextEdit
        Left = 113
        Top = 266
        Hint = 'E.R_3DZhe2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 17
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit38: TcxTextEdit
        Left = 113
        Top = 314
        Hint = 'E.R_3DYa2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 20
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit39: TcxTextEdit
        Left = 153
        Top = 266
        Hint = 'E.R_3DZhe3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 18
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit40: TcxTextEdit
        Left = 153
        Top = 314
        Hint = 'E.R_3DYa3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 21
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit41: TcxTextEdit
        Left = 73
        Top = 331
        Hint = 'E.R_3DYa4'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 22
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit42: TcxTextEdit
        Left = 113
        Top = 331
        Hint = 'E.R_3DYa5'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 23
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit43: TcxTextEdit
        Left = 153
        Top = 331
        Hint = 'E.R_3DYa6'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 24
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit47: TcxTextEdit
        Left = 303
        Top = 331
        Hint = 'E.R_28Ya4'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 31
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit48: TcxTextEdit
        Left = 343
        Top = 331
        Hint = 'E.R_28Ya5'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 32
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit49: TcxTextEdit
        Left = 382
        Top = 331
        Hint = 'E.R_28Ya6'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 33
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit17: TcxTextEdit
        Left = 60
        Top = 0
        Hint = 'E.R_MgO'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 0
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit18: TcxTextEdit
        Left = 60
        Top = 180
        Hint = 'E.R_CL'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 7
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit19: TcxTextEdit
        Left = 60
        Top = 78
        Hint = 'E.R_XiDu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 3
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit20: TcxTextEdit
        Left = 60
        Top = 130
        Hint = 'E.R_ChouDu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 5
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit21: TcxTextEdit
        Left = 204
        Top = 26
        Hint = 'E.R_BuRong'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 9
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit22: TcxTextEdit
        Left = 60
        Top = 104
        Hint = 'E.R_Jian'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 4
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit23: TcxTextEdit
        Left = 60
        Top = 26
        Hint = 'E.R_SO3'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 1
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit24: TcxTextEdit
        Left = 60
        Top = 52
        Hint = 'E.R_ShaoShi'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 2
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit25: TcxTextEdit
        Left = 204
        Top = 104
        Hint = 'E.R_AnDing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 12
        Text = #21512#26684
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit26: TcxTextEdit
        Left = 204
        Top = 0
        Hint = 'E.R_BiBiao'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 8
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit27: TcxTextEdit
        Left = 204
        Top = 78
        Hint = 'E.R_ZhongNing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 11
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit28: TcxTextEdit
        Left = 204
        Top = 52
        Hint = 'E.R_ChuNing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 10
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit45: TcxTextEdit
        Left = 60
        Top = 155
        Hint = 'E.R_YLiGai'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 6
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit52: TcxTextEdit
        Left = 204
        Top = 182
        Hint = 'E.R_KuangWu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 15
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit53: TcxTextEdit
        Left = 204
        Top = 155
        Hint = 'E.R_GaiGui'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 14
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit54: TcxTextEdit
        Left = 204
        Top = 129
        Hint = 'E.R_Water'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 13
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit55: TcxTextEdit
        Left = 348
        Top = 0
        Hint = 'E.R_SGType'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 34
        Width = 75
      end
      object cxTextEdit56: TcxTextEdit
        Left = 348
        Top = 26
        Hint = 'E.R_SGValue'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 35
        Width = 75
      end
      object cxTextEdit57: TcxTextEdit
        Left = 348
        Top = 52
        Hint = 'E.R_HHCType'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 36
        Width = 75
      end
      object cxTextEdit58: TcxTextEdit
        Left = 348
        Top = 78
        Hint = 'E.R_HHCValue'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 37
        Width = 75
      end
      object Edt1: TcxTextEdit
        Left = 348
        Top = 103
        Hint = 'E.R_GanSuo'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 38
        Width = 75
      end
      object Edt2: TcxTextEdit
        Left = 348
        Top = 129
        Hint = 'E.R_NaiMo'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 39
        Width = 75
      end
      object Edt3: TcxTextEdit
        Left = 348
        Top = 155
        Hint = 'E.R_C4AF'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 40
        Width = 75
      end
      object Edt4: TcxTextEdit
        Left = 348
        Top = 182
        Hint = 'E.R_C3A'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 41
        Width = 75
      end
      object Edt5: TcxTextEdit
        Left = 348
        Top = 208
        Hint = 'E.R_C3S'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 42
        Width = 75
      end
      object Edt9: TcxTextEdit
        Left = 73
        Top = 288
        Hint = 'E.R_7DZhe1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 43
        Width = 42
      end
      object Edt10: TcxTextEdit
        Left = 112
        Top = 288
        Hint = 'E.R_7DZhe2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 44
        Width = 42
      end
      object Edt11: TcxTextEdit
        Left = 152
        Top = 288
        Hint = 'E.R_7DZhe3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 45
        Width = 42
      end
      object Edt19: TcxTextEdit
        Left = 73
        Top = 353
        Hint = 'E.R_7DYa1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 46
        Width = 42
      end
      object Edt20: TcxTextEdit
        Left = 112
        Top = 353
        Hint = 'E.R_7DYa2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 47
        Width = 42
      end
      object Edt21: TcxTextEdit
        Left = 152
        Top = 353
        Hint = 'E.R_7DYa3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 48
        Width = 42
      end
      object Edt22: TcxTextEdit
        Left = 191
        Top = 353
        Hint = 'E.R_7DYa4'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 49
        Width = 42
      end
      object Edt23: TcxTextEdit
        Left = 230
        Top = 353
        Hint = 'E.R_7DYa5'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 50
        Width = 42
      end
      object Edt24: TcxTextEdit
        Left = 269
        Top = 353
        Hint = 'E.R_7DYa6'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 51
        Width = 42
      end
      object Edt25: TcxTextEdit
        Left = 73
        Top = 382
        Hint = 'E.R_3DShui1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 52
        Width = 42
      end
      object Edt26: TcxTextEdit
        Left = 112
        Top = 382
        Hint = 'E.R_3DShui2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 53
        Width = 42
      end
      object Edt27: TcxTextEdit
        Left = 230
        Top = 382
        Hint = 'E.R_7DShui1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 54
        Width = 42
      end
      object Edt28: TcxTextEdit
        Left = 269
        Top = 382
        Hint = 'E.R_7DShui2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 55
        Width = 42
      end
      object Edt29: TcxTextEdit
        Left = 73
        Top = 405
        Hint = 'E.R_28DShui1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 56
        Width = 42
      end
      object Edt30: TcxTextEdit
        Left = 112
        Top = 405
        Hint = 'E.R_28DShui2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 57
        Width = 42
      end
      object Edt6: TcxTextEdit
        Left = 60
        Top = 208
        Hint = 'E.R_ZhuMoJi'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 58
        Width = 75
      end
      object Edt7: TcxTextEdit
        Left = 204
        Top = 208
        Hint = 'E.R_ZhuMoJiValue'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 59
        Width = 75
      end
      object Edt32: TcxTextEdit
        Left = 61
        Top = 232
        Hint = 'E.R_LvSuanSG'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 60
        Width = 75
      end
    end
    object EditDate: TcxDateEdit
      Left = 81
      Top = 86
      Hint = 'E.R_Date'
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 5
      Width = 155
    end
    object EditMan: TcxTextEdit
      Left = 287
      Top = 86
      Hint = 'E.R_Man'
      ParentFont = False
      TabOrder = 6
      Width = 120
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #29289#26009#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item12: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #25152#23646#21697#31181':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item2: TdxLayoutItem
            Caption = #21462#26679#26085#26399':'
            Control = EditDate
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item3: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #24405#20837#20154':'
            Control = EditMan
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #26816#39564#25968#25454
        object dxLayoutControl1Item4: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = 'Panel1'
          ShowCaption = False
          Control = wPanel
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
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
