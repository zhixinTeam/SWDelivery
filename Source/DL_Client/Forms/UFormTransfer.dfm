inherited fFormTransfer: TfFormTransfer
  Left = 1081
  Top = 255
  Caption = #20498#26009#31649#29702
  ClientHeight = 292
  ClientWidth = 422
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 422
    Height = 292
    Font.Height = -13
    ParentFont = False
    inherited BtnOK: TButton
      Left = 275
      Top = 258
      TabOrder = 8
    end
    inherited BtnExit: TButton
      Left = 345
      Top = 258
      TabOrder = 9
    end
    object EditMate: TcxTextEdit [2]
      Left = 83
      Top = 89
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 2
      Width = 96
    end
    object EditMID: TcxComboBox [3]
      Left = 83
      Top = 64
      ParentFont = False
      Properties.MaxLength = 0
      Properties.OnChange = EditMIDPropertiesChange
      TabOrder = 1
      Width = 121
    end
    object EditDC: TcxComboBox [4]
      Left = 83
      Top = 114
      ParentFont = False
      Properties.MaxLength = 0
      Properties.OnChange = EditDCPropertiesChange
      TabOrder = 3
      Width = 121
    end
    object EditDR: TcxComboBox [5]
      Left = 83
      Top = 164
      ParentFont = False
      Properties.MaxLength = 0
      Properties.OnChange = EditDCPropertiesChange
      TabOrder = 5
      Width = 121
    end
    object EditTruck: TcxButtonEdit [6]
      Left = 83
      Top = 39
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 0
      TabOrder = 0
      OnKeyPress = EditTruckKeyPress
      Width = 121
    end
    object cbbDstAddr: TcxComboBox [7]
      Left = 83
      Top = 189
      ParentFont = False
      Properties.DropDownRows = 15
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 22
      Properties.MaxLength = 0
      TabOrder = 6
      Width = 249
    end
    object cbbSrcAddr: TcxComboBox [8]
      Left = 83
      Top = 139
      ParentFont = False
      Properties.DropDownRows = 15
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 20
      Properties.Items.Strings = (
        #27902#38451
        #27014#26519
        #23433#22622
        #38108#24029
        #20964#21439)
      Properties.MaxLength = 0
      TabOrder = 4
      Width = 363
    end
    object Edt_Num: TcxTextEdit [9]
      Left = 83
      Top = 214
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 7
      Width = 314
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21407#26009#32534#21495':'
          Control = EditMID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #21407#26009#21517#31216':'
          Control = EditMate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #20498#20986#32534#21495':'
          Control = EditDC
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item101: TdxLayoutItem
          Caption = #20498#20986#22320#28857':'
          Control = cbbSrcAddr
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #20498#20837#32534#21495':'
          Control = EditDR
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item10: TdxLayoutItem
          Caption = #20498#20837#22320#28857':'
          Control = cbbDstAddr
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item6: TdxLayoutItem
          Caption = #21544'    '#25968':'
          Visible = False
          Control = Edt_Num
          ControlOptions.ShowBorder = False
        end
      end
    end
    object TdxLayoutGroup
    end
  end
  object chk1: TCheckBox
    Left = 12
    Top = 261
    Width = 97
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #27492#21345#20026#22266#23450#21345
    Color = clWhite
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
  end
  object chk2: TCheckBox
    Left = 108
    Top = 261
    Width = 69
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #21378#20869#20498#26009
    Color = clWhite
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 2
  end
  object chk3: TCheckBox
    Left = 180
    Top = 261
    Width = 69
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #20498#26009#38144#21806
    Color = clWhite
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 3
    OnClick = chk3Click
  end
end
