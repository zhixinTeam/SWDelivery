inherited fFormCustomerInitEdit: TfFormCustomerInitEdit
  Left = 696
  Top = 310
  Caption = #23458#25143#26399#21021#35843#25972
  ClientHeight = 176
  ClientWidth = 377
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 377
    Height = 176
    inherited BtnOK: TButton
      Left = 231
      Top = 143
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 301
      Top = 143
      TabOrder = 5
    end
    object Edt_InitMoney: TcxTextEdit [2]
      Left = 87
      Top = 86
      ParentFont = False
      Properties.ReadOnly = False
      TabOrder = 2
      OnKeyPress = Edt_InitMoneyKeyPress
      Width = 142
    end
    object cxlbl1: TcxLabel [3]
      Left = 23
      Top = 61
      AutoSize = False
      ParentFont = False
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 176
      AnchorY = 71
    end
    object Edt_CusId: TcxTextEdit [4]
      Left = 23
      Top = 111
      ParentFont = False
      Properties.ReadOnly = False
      TabOrder = 3
      OnKeyPress = Edt_InitMoneyKeyPress
      Width = 267
    end
    object edt_CusName: TcxTextEdit [5]
      Left = 87
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 0
      OnKeyPress = Edt_InitMoneyKeyPress
      Width = 267
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #35814#32454#20449#24687
        object dxlytm_Cus: TdxLayoutItem
          Caption = #23458#25143#21517#31216#65306
          Control = edt_CusName
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item3: TdxLayoutItem
          ShowCaption = False
          Control = cxlbl1
          ControlOptions.ShowBorder = False
        end
        object dxlytm_InitMoney: TdxLayoutItem
          Caption = #26399#21021#37329#39069#65306
          Control = Edt_InitMoney
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item31: TdxLayoutItem
          Visible = False
          Control = Edt_CusId
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
