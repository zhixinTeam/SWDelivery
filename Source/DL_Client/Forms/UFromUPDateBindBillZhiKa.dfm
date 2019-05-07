inherited fFormUPDateBindBillZhika: TfFormUPDateBindBillZhika
  Left = 710
  Top = 282
  Caption = #20462#25913#38144#21806#21333
  ClientHeight = 306
  ClientWidth = 529
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 529
    Height = 306
    inherited BtnOK: TButton
      Left = 383
      Top = 273
      TabOrder = 12
    end
    inherited BtnExit: TButton
      Left = 453
      Top = 273
      TabOrder = 13
    end
    object Edt_NCOrder: TcxButtonEdit [2]
      Left = 87
      Top = 36
      Hint = 'D.L_ZhiKa'
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 0
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditCustomerPropertiesButtonClick
      TabOrder = 0
      Width = 165
    end
    object edt_PValue: TcxTextEdit [3]
      Left = 87
      Top = 187
      Hint = 'D.L_PValue'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = #23435#20307
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 9
      Width = 100
    end
    object edt_MValue: TcxTextEdit [4]
      Left = 256
      Top = 187
      Hint = 'D.L_MValue'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = #23435#20307
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 10
      Width = 100
    end
    object EditMemo: TcxMemo [5]
      Left = 87
      Top = 213
      Hint = 'D.L_DelReson'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.Edges = [bBottom]
      TabOrder = 11
      Height = 45
      Width = 394
    end
    object edt_StockName: TcxTextEdit [6]
      Left = 256
      Top = 111
      Hint = 'D.L_StockName'
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      Width = 237
    end
    object edt_StockNo: TcxTextEdit [7]
      Left = 87
      Top = 111
      Hint = 'D.L_StockNo'
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      Width = 100
    end
    object edt_CusName: TcxTextEdit [8]
      Left = 87
      Top = 86
      Hint = 'D.L_CusName'
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      Width = 280
    end
    object edt_CusId: TcxTextEdit [9]
      Left = 87
      Top = 61
      Hint = 'D.L_CusId'
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 166
    end
    object edt_Truck: TcxTextEdit [10]
      Left = 87
      Top = 162
      Hint = 'D.L_Truck'
      ParentFont = False
      TabOrder = 8
      Width = 166
    end
    object edt_YunFei: TcxTextEdit [11]
      Left = 256
      Top = 136
      Hint = 'D.L_YunFei'
      ParentFont = False
      Properties.ReadOnly = True
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = #23435#20307
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 7
      Width = 100
    end
    object edt_Price: TcxTextEdit [12]
      Left = 87
      Top = 136
      Hint = 'D.L_Price'
      ParentFont = False
      Properties.ReadOnly = True
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = #23435#20307
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 6
      Width = 100
    end
    object edt_Bill: TcxTextEdit [13]
      Left = 322
      Top = 61
      Hint = 'D.L_ID'
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 166
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = 'NC'#35746#21333#21495':'
          Control = Edt_NCOrder
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Group6: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Item10: TdxLayoutItem
                AutoAligns = [aaVertical]
                Caption = #23458#25143#32534#21495#65306
                Control = edt_CusId
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item14: TdxLayoutItem
                Caption = #25552#36135#21333#21495#65306
                Control = edt_Bill
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Item8: TdxLayoutItem
              Caption = #23458#25143#21517#31216#65306
              Control = edt_CusName
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item7: TdxLayoutItem
              Caption = #21697#31181#32534#21495#65306
              Control = edt_StockNo
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item5: TdxLayoutItem
              Caption = #21697#31181#21517#31216#65306
              Control = edt_StockName
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group5: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Group8: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Item12: TdxLayoutItem
                Caption = #27700#27877#21333#20215#65306
                Control = edt_Price
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item11: TdxLayoutItem
                Caption = #36816#36153#21333#20215#65306
                Control = edt_YunFei
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Item4: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #36710#29260#21495#30721#65306
              Control = edt_Truck
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Group7: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Item6: TdxLayoutItem
                Caption = #36710#36742#30382#37325#65306
                Control = edt_PValue
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item9: TdxLayoutItem
                Caption = #36710#36742#27611#37325#65306
                Control = edt_MValue
                ControlOptions.ShowBorder = False
              end
            end
          end
        end
        object dxLayout1Item13: TdxLayoutItem
          Caption = #22791#27880':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
