inherited fFormPurchaseOrder: TfFormPurchaseOrder
  Left = 841
  Top = 258
  ClientHeight = 412
  ClientWidth = 477
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 477
    Height = 412
    AutoControlTabOrders = False
    inherited BtnOK: TButton
      Left = 331
      Top = 379
      Caption = #24320#21333
      TabOrder = 8
    end
    inherited BtnExit: TButton
      Left = 401
      Top = 379
      TabOrder = 10
    end
    object EditValue: TcxTextEdit [2]
      Left = 279
      Top = 245
      ParentFont = False
      TabOrder = 7
      Text = '0.00'
      OnKeyPress = EditLadingKeyPress
      Width = 138
    end
    object EditMate: TcxTextEdit [3]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditID: TcxTextEdit [4]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = True
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditProvider: TcxTextEdit [5]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditSalesMan: TcxTextEdit [6]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditProject: TcxTextEdit [7]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditArea: TcxTextEdit [8]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditTruck: TcxButtonEdit [9]
      Left = 81
      Top = 245
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 6
      OnKeyPress = EditLadingKeyPress
      Width = 135
    end
    object EditCardType: TcxComboBox [10]
      Left = 81
      Top = 270
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.Items.Strings = (
        'L=L'#12289#20020#26102#21345
        'G=G'#12289#38271#26399#21345)
      TabOrder = 13
      Width = 121
    end
    object cxLabel1: TcxLabel [11]
      Left = 221
      Top = 270
      Caption = #27880':'#20020#26102#21345#20986#21378#26102#22238#25910';'#22266#23450#21345#20986#21378#26102#19981#22238#25910
      ParentFont = False
    end
    object Edt_PValue: TcxTextEdit [12]
      Left = 81
      Top = 320
      ParentFont = False
      TabOrder = 16
      OnKeyPress = Edt_PValueKeyPress
      Width = 125
    end
    object Edt_MValue: TcxTextEdit [13]
      Left = 81
      Top = 295
      ParentFont = False
      TabOrder = 15
      OnKeyPress = Edt_PValueKeyPress
      Width = 135
    end
    object Edt_MMan: TcxTextEdit [14]
      Left = 279
      Top = 291
      ParentFont = False
      TabOrder = 17
      Width = 135
    end
    object Edt_PMan: TcxTextEdit [15]
      Left = 279
      Top = 316
      ParentFont = False
      TabOrder = 18
      Width = 135
    end
    object Edt_Man: TcxTextEdit [16]
      Left = 81
      Top = 345
      ParentFont = False
      TabOrder = 19
      Width = 135
    end
    object edt_YsJz: TcxTextEdit [17]
      Left = 81
      Top = 220
      ParentFont = False
      TabOrder = 20
      Text = '0.00'
      OnKeyPress = Edt_PValueKeyPress
      Width = 135
    end
    object cxlbl1: TcxLabel [18]
      Left = 221
      Top = 220
      Caption = #27880':'#36135#28304#21333#20301#20986#20855#30340#20928#37325
      ParentFont = False
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxGroupLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #30003#35831#21333#21495':'
            Control = EditID
            ControlOptions.ShowBorder = False
          end
          object dxlytmLayout1Item3: TdxLayoutItem
            Caption = #20379' '#24212' '#21830':'
            Control = EditProvider
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21407' '#26448' '#26009':'
            Control = EditMate
            ControlOptions.ShowBorder = False
          end
        end
        object dxlytmLayout1Item6: TdxLayoutItem
          Caption = #19994' '#21153' '#21592':'
          Control = EditSalesMan
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item8: TdxLayoutItem
          Caption = #25152#23646#21306#22495':'
          Control = EditArea
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item7: TdxLayoutItem
          Caption = #39033#30446#21517#31216':'
          Control = EditProject
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #25552#21333#20449#24687
        object dxlytgrphyjz: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxlytmYSJZ: TdxLayoutItem
            Caption = #21407#22987#20928#37325':'
            Control = edt_YsJz
            ControlOptions.ShowBorder = False
          end
          object dxlytmHYJz: TdxLayoutItem
            Control = cxlbl1
            ControlOptions.ShowBorder = False
          end
        end
        object dxlytgrpYSJZ: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxlytmLayout1Item12: TdxLayoutItem
              Caption = #25552#36135#36710#36742':'
              Control = EditTruck
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item3: TdxLayoutItem
              Caption = #21345#29255#31867#22411':'
              Control = EditCardType
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item62: TdxLayoutItem
              Caption = #36710#36742#27611#37325':'
              Control = Edt_MValue
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item61: TdxLayoutItem
              Caption = #36710#36742#30382#37325':'
              Control = Edt_PValue
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item65: TdxLayoutItem
              Caption = #24320' '#21333' '#20154':'
              Control = Edt_Man
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Item8: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21150#29702#21544#25968':'
              Control = EditValue
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item4: TdxLayoutItem
              Caption = 'cxLabel1'
              ShowCaption = False
              Control = cxLabel1
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item63: TdxLayoutItem
              Caption = #27611#37325#21496#30917':'
              Control = Edt_MMan
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item64: TdxLayoutItem
              Caption = #30382#37325#21496#30917':'
              Control = Edt_PMan
              ControlOptions.ShowBorder = False
            end
          end
        end
      end
    end
  end
end
