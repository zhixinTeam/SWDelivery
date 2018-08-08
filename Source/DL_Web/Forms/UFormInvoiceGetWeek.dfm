inherited fFormInvoiceGetWeek: TfFormInvoiceGetWeek
  ClientHeight = 140
  ClientWidth = 344
  Caption = #21608#26399' - '#36873#25321
  ExplicitWidth = 350
  ExplicitHeight = 169
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 180
    Top = 107
    TabOrder = 2
    ExplicitLeft = 180
    ExplicitTop = 107
  end
  inherited BtnExit: TUniButton
    Left = 261
    Top = 106
    ExplicitLeft = 261
    ExplicitTop = 106
  end
  inherited PanelWork: TUniSimplePanel
    Width = 328
    Height = 90
    TabOrder = 0
    ExplicitWidth = 328
    ExplicitHeight = 90
    object EditYear: TUniComboBox
      Left = 76
      Top = 15
      Width = 230
      Hint = ''
      Style = csDropDownList
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 1
      OnChange = EditYearChange
    end
    object UniLabel8: TUniLabel
      Left = 16
      Top = 20
      Width = 54
      Height = 12
      Hint = ''
      Caption = #25152#22312#24180#20221':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 2
    end
    object UniLabel9: TUniLabel
      Left = 16
      Top = 56
      Width = 54
      Height = 12
      Hint = ''
      Caption = #21608#26399#21015#34920':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 4
    end
    object EditWeek: TUniComboBox
      Left = 76
      Top = 51
      Width = 230
      Hint = ''
      ShowHint = True
      ParentShowHint = False
      Style = csDropDownList
      MaxLength = 35
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 3
    end
  end
end
