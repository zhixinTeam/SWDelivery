inherited fFormCreditDetailVerify: TfFormCreditDetailVerify
  ClientHeight = 260
  ClientWidth = 431
  Caption = #20449#29992#23457#26680
  BorderStyle = bsSizeable
  ExplicitWidth = 447
  ExplicitHeight = 299
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 266
    Top = 226
    Caption = #19981#20104#25209#20934
    ExplicitLeft = 266
    ExplicitTop = 226
  end
  inherited BtnExit: TUniButton
    Left = 348
    Top = 226
    Caption = #20851#38381
    ExplicitLeft = 348
    ExplicitTop = 226
  end
  inherited PanelWork: TUniSimplePanel
    Width = 415
    Height = 210
    ExplicitWidth = 415
    ExplicitHeight = 210
    object UnLbl_1: TUniLabel
      Left = 12
      Top = 15
      Width = 54
      Height = 12
      Hint = ''
      Caption = #23458#25143#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 1
    end
    object UnLbl1: TUniLabel
      Left = 12
      Top = 47
      Width = 54
      Height = 12
      Hint = ''
      Caption = #30003#35831#37329#39069':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 2
    end
    object UnLbl2: TUniLabel
      Left = 12
      Top = 79
      Width = 54
      Height = 12
      Hint = ''
      Caption = #26377#25928#26399#33267':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 3
    end
    object UnLbl3: TUniLabel
      Left = 12
      Top = 111
      Width = 54
      Height = 12
      Hint = ''
      Caption = #23457#25209#24847#35265':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 4
    end
    object UnMMo_1: TUniMemo
      Left = 72
      Top = 115
      Width = 332
      Height = 54
      Hint = ''
      Lines.Strings = (
        #21516#24847#30003#35831#39069#24230)
      TabOrder = 5
    end
    object UnLbl_CusName: TUniLabel
      Left = 72
      Top = 16
      Width = 154
      Height = 12
      Hint = ''
      Caption = '                      '
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = [fsBold
      TabOrder = 6
    end
    object UnLbl_Money: TUniLabel
      Left = 72
      Top = 47
      Width = 216
      Height = 15
      Hint = ''
      Caption = '                        '
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Color = clHighlight
      Font.Height = -15
      Font.Name = #23435#20307
      Font.Style = [fsBold
      TabOrder = 7
    end
    object UnLbl_Date: TUniLabel
      Left = 74
      Top = 80
      Width = 84
      Height = 12
      Hint = ''
      Caption = '              '
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 8
    end
    object UnLbl4: TUniLabel
      Left = 18
      Top = 183
      Width = 48
      Height = 12
      Hint = ''
      Caption = ' '#23457#26680#20154':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 9
    end
    object cbb_NextVarMan: TUniComboBox
      Left = 72
      Top = 179
      Width = 144
      Hint = ''
      Text = ''
      Anchors = [akLeft, akTop, akRight
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 10
    end
    object UnLbl5: TUniLabel
      Left = 217
      Top = 183
      Width = 192
      Height = 12
      Hint = ''
      Caption = #65288#22914#39069#24230#36807#22823#21487#32487#32493#25253#21576#19978#32423#39046#23548#65289
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 11
    end
  end
  object btn1: TUniButton
    Left = 184
    Top = 226
    Width = 75
    Height = 25
    Hint = ''
    Caption = #25209#20934#30003#35831
    Anchors = [akRight, akBottom
    TabOrder = 3
    Default = True
    OnClick = BtnOKClick
  end
end
