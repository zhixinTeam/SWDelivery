inherited fFormInvoiceZZAll: TfFormInvoiceZZAll
  ClientHeight = 410
  ClientWidth = 406
  Caption = #38144#21806#25166#24080
  ExplicitWidth = 412
  ExplicitHeight = 439
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 240
    Top = 376
    Caption = #24320#22987
    ExplicitLeft = 240
    ExplicitTop = 376
  end
  inherited BtnExit: TUniButton
    Left = 323
    Top = 376
    ExplicitLeft = 323
    ExplicitTop = 376
  end
  inherited PanelWork: TUniSimplePanel
    Width = 390
    Height = 360
    ExplicitWidth = 390
    ExplicitHeight = 360
    object UniLabel1: TUniLabel
      Left = 16
      Top = 20
      Width = 52
      Height = 13
      Hint = ''
      Caption = #32467#31639#21608#26399':'
      TabOrder = 1
    end
    object EditWeek: TUniEdit
      Left = 82
      Top = 16
      Width = 275
      Hint = ''
      Text = ''
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      ReadOnly = True
    end
    object UniLabel2: TUniLabel
      Left = 16
      Top = 44
      Width = 52
      Height = 13
      Hint = ''
      Caption = #25552#31034#20449#24687':'
      TabOrder = 3
    end
    object EditMemo: TUniMemo
      Left = 16
      Top = 64
      Width = 364
      Height = 286
      Hint = ''
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 4
    end
    object BtnWeekFilter: TUniBitBtn
      Left = 358
      Top = 16
      Width = 22
      Height = 22
      Hint = #36873#25321#32467#31639#21608#26399
      ShowHint = True
      ParentShowHint = False
      Caption = '...'
      TabOrder = 5
      OnClick = BtnWeekFilterClick
    end
  end
  object PanelHide1: TUniHiddenPanel
    Left = 8
    Top = 374
    Width = 160
    Height = 32
    Hint = ''
    Visible = True
    object BtnRun: TUniButton
      Left = 3
      Top = 4
      Width = 75
      Height = 25
      Hint = ''
      Caption = #38544#34255#25191#34892
      TabOrder = 1
      Default = True
      ScreenMask.Enabled = True
      ScreenMask.Message = #25166#24080#20013','#35831#31245#21518
      ScreenMask.Target = PanelWork
      OnClick = BtnRunClick
    end
  end
end
