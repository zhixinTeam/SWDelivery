inherited fFrameMsgLog: TfFrameMsgLog
  Width = 789
  Height = 487
  inherited ToolBar1: TToolBar
    Width = 789
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
    Width = 789
    Height = 350
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 789
    Height = 70
    object Edt_Date: TcxButtonEdit [0]
      Left = 223
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
      TabOrder = 1
      Width = 185
    end
    object Edt_Keys: TcxButtonEdit [1]
      Left = 69
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 0
      Properties.OnButtonClick = Edt_KeysPropertiesButtonClick
      TabOrder = 0
      Width = 115
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #20851#38190#23383':'
          Control = Edt_Keys
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
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
    Width = 789
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 789
    inherited TitleBar: TcxLabel
      Caption = #36890#30693#20107#20214#35760#24405
      Style.IsFontAssigned = True
      Width = 789
      AnchorX = 395
      AnchorY = 11
    end
  end
end
