inherited fFormBill: TfFormBill
  Left = 703
  Top = 201
  ClientHeight = 502
  ClientWidth = 483
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 483
    Height = 502
    AutoControlTabOrders = False
    inherited BtnOK: TButton
      Left = 337
      Top = 469
      Caption = #24320#21333
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 407
      Top = 469
      TabOrder = 9
    end
    object ListInfo: TcxMCListBox [2]
      Left = 23
      Top = 36
      Width = 351
      Height = 116
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 74
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 273
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 8
    end
    object ListBill: TcxListView [3]
      Left = 23
      Top = 342
      Width = 372
      Height = 113
      Columns = <
        item
          Caption = #27700#27877#31867#22411
          Width = 80
        end
        item
          Caption = #25552#36135#36710#36742
          Width = 70
        end
        item
          Caption = #21150#29702#37327'('#21544')'
          Width = 100
        end>
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 6
      ViewStyle = vsReport
    end
    object EditValue: TcxTextEdit [4]
      Left = 81
      Top = 317
      ParentFont = False
      TabOrder = 3
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditTruck: TcxTextEdit [5]
      Left = 264
      Top = 232
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 116
    end
    object EditStock: TcxComboBox [6]
      Left = 81
      Top = 292
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 15
      Properties.ItemHeight = 18
      Properties.OnChange = EditStockPropertiesChange
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 115
    end
    object BtnAdd: TButton [7]
      Left = 421
      Top = 292
      Width = 39
      Height = 17
      Caption = #28155#21152
      TabOrder = 4
      OnClick = BtnAddClick
    end
    object BtnDel: TButton [8]
      Left = 421
      Top = 317
      Width = 39
      Height = 18
      Caption = #21024#38500
      TabOrder = 7
      OnClick = BtnDelClick
    end
    object EditLading: TcxComboBox [9]
      Left = 81
      Top = 232
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'T=T'#12289#33258#25552
        'S=S'#12289#36865#36135
        'X=X'#12289#36816#21368)
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditFQ: TcxTextEdit [10]
      Left = 264
      Top = 207
      ParentFont = False
      Properties.MaxLength = 100
      Properties.OnEditValueChanged = EditFQPropertiesEditValueChanged
      TabOrder = 13
      Width = 120
    end
    object EditType: TcxComboBox [11]
      Left = 81
      Top = 207
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#26632#21488
        'V=V'#12289'VIP'
        'S=S'#12289#33337#36816)
      TabOrder = 14
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object PrintGLF: TcxCheckBox [12]
      Left = 11
      Top = 469
      Caption = #25171#21360#36807#36335#36153
      ParentFont = False
      TabOrder = 15
      Transparent = True
      Width = 85
    end
    object PrintHY: TcxCheckBox [13]
      Left = 101
      Top = 469
      Caption = #25171#21360#21270#39564#21333
      ParentFont = False
      TabOrder = 16
      Transparent = True
      Width = 86
    end
    object EdtICCardNo: TcxTextEdit [14]
      Left = 81
      Top = 182
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 17
      OnClick = EdtICCardNoClick
      OnKeyPress = EditLadingKeyPress
      Width = 132
    end
    object Chk_YZCP: TcxCheckBox [15]
      Left = 192
      Top = 469
      Caption = #39564#35777#36710#29260
      ParentFont = False
      State = cbsChecked
      TabOrder = 18
      Transparent = True
      OnClick = Chk_YZCPClick
      Width = 72
    end
    object Chk_IsYangPin: TcxCheckBox [16]
      Left = 269
      Top = 469
      Caption = #26679#21697
      ParentFont = False
      TabOrder = 19
      Transparent = True
      Width = 55
    end
    object cbb_Factory: TcxComboBox [17]
      Left = 81
      Top = 157
      Hint = #22914#38656#24320#20998#21378#21333#25454#12289#35831#36873#25321
      ParentFont = False
      ParentShowHint = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'T=T'#12289#33258#25552
        'S=S'#12289#36865#36135
        'X=X'#12289#36816#21368)
      ShowHint = True
      TabOrder = 20
      Width = 120
    end
    object edt_StdValue: TcxTextEdit [18]
      Left = 264
      Top = 157
      Hint = #36710#36742#36229#36733#27611#37325#19978#38480
      ParentFont = False
      ParentShowHint = False
      Properties.MaxLength = 50
      ShowHint = True
      TabOrder = 21
      OnExit = edt_StdValueExit
      OnKeyPress = edt_StdValueKeyPress
      Width = 195
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxlytm_Factory: TdxLayoutItem
            Caption = #24320#21333#24037#21378':'
            Control = cbb_Factory
            ControlOptions.ShowBorder = False
          end
          object dxlytm_Std: TdxLayoutItem
            Caption = #26631#20934#20928#37325':'
            Control = edt_StdValue
            ControlOptions.ShowBorder = False
          end
        end
        object dxlytm_ICCard: TdxLayoutItem
          Caption = #21407'IC'#21345#21495':'
          Control = EdtICCardNo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item6: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #25552#36135#36890#36947':'
            Control = EditType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #23553#31614#32534#21495':'
            Control = EditFQ
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item12: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #25552#36135#26041#24335':'
            Control = EditLading
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #25552#36135#36710#36742':'
            Control = EditTruck
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #25552#21333#26126#32454
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group8: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item7: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #27700#27877#31867#22411':'
              Control = EditStock
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item10: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Caption = 'Button1'
              ShowCaption = False
              Control = BtnAdd
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group7: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item8: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21150#29702#21544#25968':'
              Control = EditValue
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item11: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Caption = 'Button2'
              ShowCaption = False
              Control = BtnDel
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = 'New Item'
          ShowCaption = False
          Control = ListBill
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item13: TdxLayoutItem [0]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Visible = False
          Control = PrintGLF
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item14: TdxLayoutItem [1]
          ShowCaption = False
          Control = PrintHY
          ControlOptions.ShowBorder = False
        end
        object dxlytmItem15: TdxLayoutItem [2]
          Control = Chk_YZCP
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item15: TdxLayoutItem [3]
          AutoAligns = [aaVertical]
          Control = Chk_IsYangPin
          ControlOptions.ShowBorder = False
        end
      end
    end
    object TdxLayoutGroup
    end
    object TdxLayoutGroup
    end
  end
end
