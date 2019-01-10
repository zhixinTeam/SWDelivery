inherited fFormInputBoxEx: TfFormInputBoxEx
  ClientHeight = 117
  ClientWidth = 314
  Caption = #26085#26399#31579#36873
  ExplicitWidth = 320
  ExplicitHeight = 146
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 150
    Top = 84
    ModalResult = 1
    TabOrder = 1
    OnClick = nil
    ExplicitLeft = 150
    ExplicitTop = 84
  end
  inherited BtnExit: TUniButton
    Left = 231
    Top = 86
    TabOrder = 2
    ExplicitLeft = 231
    ExplicitTop = 86
  end
  inherited PanelWork: TUniSimplePanel
    Width = 298
    Height = 70
    TabOrder = 0
    ExplicitWidth = 298
    ExplicitHeight = 70
    object Label1: TUniLabel
      Left = 12
      Top = 15
      Width = 28
      Height = 13
      Hint = ''
      Caption = #25552#31034':'
      TabOrder = 1
    end
    object undt1: TUniEdit
      Left = 12
      Top = 34
      Width = 283
      Hint = ''
      MaxLength = 50
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 2
    end
  end
end
