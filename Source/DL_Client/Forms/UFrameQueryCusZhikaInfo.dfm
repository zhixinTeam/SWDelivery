inherited fFrameQueryCusZhiKa: TfFrameQueryCusZhiKa
  Width = 864
  Height = 490
  inherited ToolBar1: TToolBar
    Width = 864
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
    Top = 150
    Width = 864
    Height = 340
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 864
    Height = 83
    object Edt_CName: TcxButtonEdit [0]
      Left = 255
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = Edt_CNamePropertiesButtonClick
      Properties.OnChange = Edt_CNamePropertiesChange
      TabOrder = 1
      OnKeyPress = Edt_CNameKeyPress
      Width = 230
    end
    object Edt_CID: TcxButtonEdit [1]
      Left = 87
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = Edt_CNamePropertiesButtonClick
      Properties.OnChange = Edt_CNamePropertiesChange
      TabOrder = 0
      OnKeyPress = Edt_CNameKeyPress
      Width = 123
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#32534#21495#65306
          Control = Edt_CID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #23458#25143#65306
          Control = Edt_CName
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        Visible = False
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 142
    Width = 864
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 864
    inherited TitleBar: TcxLabel
      Caption = #23458#25143#32440#21345'('#35746#21333')'#37327#26597#35810
      Style.IsFontAssigned = True
      Width = 864
      AnchorX = 432
      AnchorY = 11
    end
  end
end
