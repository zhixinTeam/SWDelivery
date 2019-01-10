inherited fFormCtlCusbd: TfFormCtlCusbd
  Left = 564
  Top = 384
  Caption = #31649#29702#23458#25143#32465#23450
  ClientHeight = 266
  ClientWidth = 500
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 500
    Height = 266
    inherited BtnOK: TButton
      Left = 354
      Top = 233
      Caption = #21024#38500
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 424
      Top = 233
      TabOrder = 4
    end
    object EditCustom: TcxComboBox [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = cbbEditCustomPropertiesEditValueChanged
      TabOrder = 0
      Width = 325
    end
    object ListCustom: TcxListView [3]
      Left = 23
      Top = 71
      Width = 421
      Height = 150
      Columns = <
        item
          Caption = #24207#21495
        end
        item
          Caption = #23458#25143#32534#21495
          Width = 70
        end
        item
          Caption = #23458#25143#21517#31216
          Width = 70
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 2
      ViewStyle = vsReport
    end
    object btn1: TButton [4]
      Left = 411
      Top = 36
      Width = 65
      Height = 22
      Caption = #26597#25214
      TabOrder = 1
      OnClick = btn1Click
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxlytmLayout1Item3: TdxLayoutItem
            Caption = #23458#25143#21517#31216':'
            Control = EditCustom
            ControlOptions.ShowBorder = False
          end
          object dxlytmLayout1Item32: TdxLayoutItem
            Control = btn1
            ControlOptions.ShowBorder = False
          end
        end
        object dxlytmLayout1Item31: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avBottom
          Control = ListCustom
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
