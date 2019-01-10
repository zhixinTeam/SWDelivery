inherited fFrameQueryOrderHD: TfFrameQueryOrderHD
  Width = 919
  Height = 462
  inherited ToolBar1: TToolBar
    Width = 919
    OnClick = ToolBar1Click
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
    Top = 137
    Width = 919
    Height = 325
    PopupMenu = pmPMenu1
    inherited cxView1: TcxGridDBTableView
      OnKeyPress = nil
      OnCustomDrawCell = cxView1CustomDrawCell
      OnFocusedRecordChanged = nil
    end
    object cxView_Mx: TcxGridDBTableView [1]
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 919
    Height = 70
    object Edt_Customer: TcxButtonEdit [0]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = Edt_EditCustomerPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = Edt_CustomerKeyPress
      Width = 175
    end
    object Edt_Stock: TcxButtonEdit [1]
      Left = 319
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = Edt_EditCustomerPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = Edt_StockKeyPress
      Width = 155
    end
    object Edt_Date: TcxButtonEdit [2]
      Left = 513
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = Edt_DatePropertiesButtonClick
      TabOrder = 2
      Width = 185
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxlytm_1: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = Edt_Customer
          ControlOptions.ShowBorder = False
        end
        object dxlytm_2: TdxLayoutItem
          Caption = #29289#26009#31867#22411':'
          Control = Edt_Stock
          ControlOptions.ShowBorder = False
        end
        object dxlytm_Date: TdxLayoutItem
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
    Top = 129
    Width = 919
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 919
    inherited TitleBar: TcxLabel
      Caption = #37319#36141#21333#25454#26680#23545
      Style.IsFontAssigned = True
      Width = 919
      AnchorX = 460
      AnchorY = 11
    end
  end
  inherited DataSource1: TDataSource
    AutoEdit = False
  end
  object pmPMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 4
    Top = 232
    object N1: TMenuItem
      Tag = 10
      Caption = #26631#35760#20026' ['#24050#26680#23545']'
      OnClick = N1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Caption = #21462#28040#26631#35760
      OnClick = N2Click
    end
  end
end
