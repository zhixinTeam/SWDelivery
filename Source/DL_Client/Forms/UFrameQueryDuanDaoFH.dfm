inherited fFrameQueryDuanDaoFH: TfFrameQueryDuanDaoFH
  Width = 853
  Height = 474
  inherited ToolBar1: TToolBar
    Width = 853
    inherited BtnAdd: TToolButton
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 153
    Width = 853
    Height = 321
    PopupMenu = pmPMenu1
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 853
    Height = 86
    object Edt_Bill: TcxButtonEdit [0]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 0
      Properties.OnButtonClick = Edt_BillPropertiesButtonClick
      TabOrder = 0
      Width = 115
    end
    object Edt_Truck: TcxButtonEdit [1]
      Left = 247
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 0
      Properties.OnButtonClick = Edt_BillPropertiesButtonClick
      TabOrder = 1
      Width = 115
    end
    object Edt_Keys: TcxButtonEdit [2]
      Left = 413
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 0
      Properties.OnButtonClick = Edt_BillPropertiesButtonClick
      TabOrder = 2
      Width = 115
    end
    object Edt_Date: TcxButtonEdit [3]
      Left = 567
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 0
      Properties.ReadOnly = True
      Properties.OnButtonClick = Edt_DatePropertiesButtonClick
      TabOrder = 3
      Width = 185
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxlytm_1: TdxLayoutItem
          Caption = #30701#20498#21333#21495':'
          Control = Edt_Bill
          ControlOptions.ShowBorder = False
        end
        object dxlytm_2: TdxLayoutItem
          Caption = #36710#29260#21495':'
          Control = Edt_Truck
          ControlOptions.ShowBorder = False
        end
        object dxlytm_3: TdxLayoutItem
          Caption = #20851#38190#23383':'
          Control = Edt_Keys
          ControlOptions.ShowBorder = False
        end
        object dxlytm_4: TdxLayoutItem
          Caption = #26085#26399':'
          Control = Edt_Date
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        Visible = False
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 145
    Width = 853
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 853
    inherited TitleBar: TcxLabel
      Caption = #30701#20498#25918#26009#26126#32454
      Style.IsFontAssigned = True
      Width = 853
      AnchorX = 427
      AnchorY = 11
    end
  end
  object pmPMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 4
    Top = 240
    object N1: TMenuItem
      Tag = 10
      Caption = #25171#21360#31080#21333
      OnClick = N1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
end
