inherited fFormPrinterJs: TfFormPrinterJs
  Caption = #28155#21152#25171#21360#26426
  ClientHeight = 138
  ClientWidth = 365
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 365
    Height = 138
    inherited BtnOK: TButton
      Left = 219
      Top = 105
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 289
      Top = 105
      TabOrder = 4
    end
    object edt_Edit1: TcxTextEdit [2]
      Left = 99
      Top = 36
      ParentFont = False
      TabOrder = 0
      Width = 125
    end
    object edt_Edit11: TcxTextEdit [3]
      Left = 99
      Top = 61
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -13
      Style.Font.Name = #23435#20307
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      TabOrder = 1
      Text = '65'
      Width = 70
    end
    object edt_Edit12: TcxTextEdit [4]
      Left = 262
      Top = 61
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -13
      Style.Font.Name = #23435#20307
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      TabOrder = 2
      Text = '3'
      Width = 70
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxlytmLayout1Item3: TdxLayoutItem
          Caption = #25171#21360#26426#21517#31216#65306
          Control = edt_Edit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxlytmLayout1Item31: TdxLayoutItem
            Caption = #21487#25171#21360#24635#25968#65306
            Control = edt_Edit11
            ControlOptions.ShowBorder = False
          end
          object dxlytmLayout1Item32: TdxLayoutItem
            Caption = #21097#20313#24352#25968#25552#37266#65306
            Control = edt_Edit12
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
