inherited fFramePrinterJS: TfFramePrinterJS
  inherited ToolBar1: TToolBar
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 132
    Height = 235
    PopupMenu = pm1
  end
  inherited dxLayout1: TdxLayoutControl
    Height = 65
    Visible = False
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupDetail1: TdxLayoutGroup
        Visible = False
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 124
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #25171#21360#26426#25442#32440#25552#37266
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
  object pm1: TPopupMenu
    Left = 6
    Top = 236
    object N1: TMenuItem
      Caption = #37325#32622#35745#25968
      OnClick = N1Click
    end
  end
end
