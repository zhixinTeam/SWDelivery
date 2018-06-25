inherited fFrameInvoiceDtl: TfFrameInvoiceDtl
  Width = 895
  Height = 436
  inherited ToolBar1: TToolBar
    Width = 895
    inherited BtnAdd: TToolButton
      Caption = #25166#36134
      ImageIndex = 19
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Caption = #23458#25143
      ImageIndex = 13
      Visible = False
    end
    inherited BtnDel: TToolButton
      Visible = False
    end
    inherited S1: TToolButton
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 202
    Width = 895
    Height = 234
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 895
    Height = 135
    object cxTextEdit2: TcxTextEdit [0]
      Left = 618
      Top = 93
      Hint = 'T.I_Customer'
      ParentFont = False
      TabOrder = 5
      Width = 135
    end
    object cxTextEdit4: TcxTextEdit [1]
      Left = 81
      Top = 93
      Hint = 'T.D_Stock'
      ParentFont = False
      TabOrder = 2
      Width = 135
    end
    object cxTextEdit3: TcxTextEdit [2]
      Left = 297
      Top = 93
      Hint = 'T.D_KPrice'
      ParentFont = False
      TabOrder = 3
      Width = 85
    end
    object cxTextEdit5: TcxTextEdit [3]
      Left = 457
      Top = 93
      Hint = 'T.D_Value'
      ParentFont = False
      TabOrder = 4
      Width = 98
    end
    object EditWeek: TcxButtonEdit [4]
      Left = 279
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditWeekPropertiesButtonClick
      TabOrder = 1
      Width = 278
    end
    object EditCus: TcxButtonEdit [5]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCusPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 135
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item7: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #21608#26399#31579#36873':'
          Control = EditWeek
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item6: TdxLayoutItem
          Caption = #27700#27877#21517#31216':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #21333#20215'('#20803'/'#21544'):'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #24320#31080#37327'('#21544'):'
          Control = cxTextEdit5
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 895
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 895
    inherited TitleBar: TcxLabel
      Caption = #38144#21806#32467#31639#21457#31080#26126#32454
      Style.IsFontAssigned = True
      Width = 895
      AnchorX = 448
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 4
    Top = 236
  end
  inherited DataSource1: TDataSource
    Left = 32
    Top = 236
  end
end
