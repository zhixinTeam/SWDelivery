inherited fFramePurOrderImport: TfFramePurOrderImport
  inherited ToolBar1: TToolBar
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
    Top = 145
    Height = 222
  end
  inherited dxLayout1: TdxLayoutControl
    Height = 78
    object Edt_Name: TcxButtonEdit [0]
      Left = 87
      Top = 38
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 0
      OnClick = Edt_NameClick
      Width = 170
    end
    object btn1: TButton [1]
      Left = 262
      Top = 36
      Width = 75
      Height = 22
      Caption = #23548#20837
      TabOrder = 1
      OnClick = btn1Click
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxlytmLayout1Item1: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avBottom
          Caption = #23548#20837#25991#20214#65306
          Control = Edt_Name
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item11: TdxLayoutItem
          Control = btn1
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        Visible = False
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 137
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #21407#26448#26009#21333#25454#23548#20837
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
  object dlgOpen1: TOpenDialog
    Left = 64
    Top = 202
  end
  object Qry_1: TADOQuery
    Connection = FDM.ADOConn
    Parameters = <>
    Left = 6
    Top = 234
  end
end
