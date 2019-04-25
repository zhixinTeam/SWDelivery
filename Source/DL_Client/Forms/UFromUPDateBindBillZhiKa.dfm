inherited fFormUPDateBindBillZhika: TfFormUPDateBindBillZhika
  Left = 1123
  Top = 307
  Caption = 'fFormUPDateBindBillZhika'
  ClientHeight = 213
  ClientWidth = 594
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 594
    Height = 213
    inherited BtnOK: TButton
      Left = 448
      Top = 180
      TabOrder = 11
    end
    inherited BtnExit: TButton
      Left = 518
      Top = 180
      TabOrder = 12
    end
    object Edt_NCOrder: TcxButtonEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 0
      Properties.OnButtonClick = EditCustomerPropertiesButtonClick
      TabOrder = 0
      Width = 165
    end
    object cxlbl_NewCus: TcxLabel [3]
      Left = 298
      Top = 61
      AutoSize = False
      Caption = #23458#25143#21517#31216':'
      ParentFont = False
      Height = 16
      Width = 270
    end
    object cxlbl_ZhiKa: TcxLabel [4]
      Left = 23
      Top = 82
      AutoSize = False
      Caption = #21407#32440#21345':'
      ParentFont = False
      Height = 16
      Width = 270
    end
    object cxlbl_NewPrice: TcxLabel [5]
      Left = 298
      Top = 124
      AutoSize = False
      Caption = #27700#27877#21333#20215':'
      ParentFont = False
      Height = 16
      Width = 270
    end
    object cxlbl_NewStock: TcxLabel [6]
      Left = 298
      Top = 103
      AutoSize = False
      Caption = #29289#26009#21697#31181':'
      ParentFont = False
      Height = 16
      Width = 270
    end
    object cxlbll_Cus: TcxLabel [7]
      Left = 23
      Top = 61
      AutoSize = False
      Caption = #23458#25143#21517#31216':'
      ParentFont = False
      Height = 16
      Width = 270
    end
    object cxlbl_NewZhiKa: TcxLabel [8]
      Left = 298
      Top = 82
      AutoSize = False
      Caption = #26032#32440#21345':'
      ParentFont = False
      Height = 16
      Width = 270
    end
    object cxlbll_Stock: TcxLabel [9]
      Left = 23
      Top = 103
      AutoSize = False
      Caption = #29289#26009#21697#31181':'
      ParentFont = False
      Height = 16
      Width = 270
    end
    object cxlbll_Price: TcxLabel [10]
      Left = 23
      Top = 124
      AutoSize = False
      Caption = #27700#27877#21333#20215':'
      ParentFont = False
      Height = 16
      Width = 270
    end
    object cxlbl_YF: TcxLabel [11]
      Left = 23
      Top = 145
      AutoSize = False
      Caption = #36816#36153#21333#20215':'
      ParentFont = False
      Height = 16
      Width = 270
    end
    object cxlbl_NewYF: TcxLabel [12]
      Left = 298
      Top = 145
      AutoSize = False
      Caption = #36816#36153#21333#20215':'
      ParentFont = False
      Height = 16
      Width = 270
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #35746#21333#32534#21495':'
          Control = Edt_NCOrder
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item8: TdxLayoutItem
            ShowCaption = False
            Control = cxlbll_Cus
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item4: TdxLayoutItem
            Caption = 'cxLabel1'
            ShowCaption = False
            Control = cxlbl_NewCus
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            ShowCaption = False
            Control = cxlbl_ZhiKa
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            ShowCaption = False
            Control = cxlbl_NewZhiKa
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item10: TdxLayoutItem
            ShowCaption = False
            Control = cxlbll_Stock
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item7: TdxLayoutItem
            ShowCaption = False
            Control = cxlbl_NewStock
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group6: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item11: TdxLayoutItem
              ShowCaption = False
              Control = cxlbll_Price
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item6: TdxLayoutItem
              ShowCaption = False
              Control = cxlbl_NewPrice
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group7: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item12: TdxLayoutItem
              ShowCaption = False
              Control = cxlbl_YF
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item13: TdxLayoutItem
              ShowCaption = False
              Control = cxlbl_NewYF
              ControlOptions.ShowBorder = False
            end
          end
        end
      end
    end
  end
end
