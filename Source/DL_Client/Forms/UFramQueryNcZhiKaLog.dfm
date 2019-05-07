inherited fFrameQueryNcZhiKaLog: TfFrameQueryNcZhiKaLog
  Width = 932
  Height = 455
  inherited ToolBar1: TToolBar
    Width = 932
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
    Top = 141
    Width = 932
    Height = 314
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 932
    Height = 74
    object Edt_NcOrder: TcxButtonEdit [0]
      Left = 87
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCusPropertiesButtonClick
      TabOrder = 0
      Width = 160
    end
    object EditCus: TcxButtonEdit [1]
      Left = 316
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCusPropertiesButtonClick
      TabOrder = 1
      Width = 180
    end
    object EditDate: TcxButtonEdit [2]
      Left = 541
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 2
      Width = 176
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = 'NC'#35746#21333#21495#65306
          Control = Edt_NcOrder
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#21517#31216#65306
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #26085#26399#65306
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        Visible = False
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 133
    Width = 932
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 932
    inherited TitleBar: TcxLabel
      Caption = 'NC'#35746#21333#21516#27493#28040#24687#26085#24535
      Style.IsFontAssigned = True
      Width = 932
      AnchorX = 466
      AnchorY = 11
    end
  end
end
