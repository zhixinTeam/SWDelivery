inherited fFrameQuerySyncOrderForNC: TfFrameQuerySyncOrderForNC
  Width = 1047
  Height = 498
  inherited ToolBar1: TToolBar
    Width = 1047
    inherited BtnAdd: TToolButton
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 153
    Width = 1047
    Height = 345
    PopupMenu = pmPMenu1
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 1047
    Height = 86
    object cxLabel1: TcxLabel [0]
      Left = 511
      Top = 36
      Caption = '   '#35746#21333#29366#24577': '
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Edges = [bBottom]
      Transparent = True
    end
    object Radio1: TcxRadioButton [1]
      Left = 598
      Top = 36
      Width = 90
      Height = 17
      Caption = #24453#21516#27493
      ParentColor = False
      TabOrder = 3
      OnClick = Radio1Click
    end
    object Radio2: TcxRadioButton [2]
      Left = 693
      Top = 36
      Width = 90
      Height = 17
      Caption = #21516#27493#22833#36133
      Checked = True
      ParentColor = False
      TabOrder = 4
      TabStop = True
      OnClick = Radio1Click
    end
    object Radio3: TcxRadioButton [3]
      Left = 788
      Top = 36
      Width = 90
      Height = 17
      Caption = #21516#27493#25104#21151
      ParentColor = False
      TabOrder = 5
      OnClick = Radio3Click
    end
    object EditDate: TcxButtonEdit [4]
      Left = 321
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 0
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 1
      Width = 185
    end
    object EditCustomer: TcxButtonEdit [5]
      Left = 111
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
    object btn1: TcxButton [6]
      Left = 884
      Top = 36
      Width = 123
      Height = 25
      Caption = #36827#20837#31163#32447#27169#24335
      TabOrder = 6
      OnClick = btn1Click
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item6: TdxLayoutItem
          Caption = #23458#25143#21517#25110#21333#21495#65306
          Control = EditCustomer
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #26085#26399#65306
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Control = Radio1
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Control = Radio2
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Control = Radio3
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item7: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
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
    Top = 145
    Width = 1047
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 1047
    inherited TitleBar: TcxLabel
      Caption = 'NC'#35746#21333#21516#27493#24773#20917
      Style.IsFontAssigned = True
      Width = 1047
      AnchorX = 524
      AnchorY = 11
    end
  end
  object pmPMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 5
    Top = 233
    object mniN1: TMenuItem
      Caption = #20877#27425#21516#27493
      OnClick = mniN1Click
    end
  end
end
