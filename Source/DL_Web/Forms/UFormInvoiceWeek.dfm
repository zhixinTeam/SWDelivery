inherited fFormInvoiceWeek: TfFormInvoiceWeek
  ClientHeight = 244
  ClientWidth = 387
  Caption = #32467#31639#21608#26399
  ExplicitWidth = 393
  ExplicitHeight = 269
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 221
    Top = 210
    ExplicitLeft = 221
    ExplicitTop = 210
  end
  inherited BtnExit: TUniButton
    Left = 304
    Top = 210
    ExplicitLeft = 304
    ExplicitTop = 210
  end
  inherited PanelWork: TUniSimplePanel
    Width = 371
    Height = 194
    ExplicitWidth = 371
    ExplicitHeight = 194
    object EditStart: TUniDateTimePicker
      Left = 68
      Top = 50
      Width = 295
      Hint = ''
      DateTime = 43224.000000000000000000
      DateFormat = 'yyyy-MM-dd'
      TimeFormat = 'HH:mm:ss'
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
    end
    object Label1: TUniLabel
      Left = 7
      Top = 55
      Width = 52
      Height = 13
      Hint = ''
      Caption = #24320#22987#26085#26399':'
      TabOrder = 2
    end
    object Label2: TUniLabel
      Left = 7
      Top = 90
      Width = 52
      Height = 13
      Hint = ''
      Caption = #32467#26463#26085#26399':'
      TabOrder = 3
    end
    object EditEnd: TUniDateTimePicker
      Left = 68
      Top = 85
      Width = 295
      Hint = ''
      DateTime = 43224.000000000000000000
      DateFormat = 'yyyy-MM-dd'
      TimeFormat = 'HH:mm:ss'
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
    end
    object UniLabel1: TUniLabel
      Left = 7
      Top = 20
      Width = 52
      Height = 13
      Hint = ''
      Caption = #21608#26399#21517#31216':'
      TabOrder = 5
    end
    object EditName: TUniEdit
      Left = 68
      Top = 15
      Width = 295
      Hint = ''
      MaxLength = 50
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 6
    end
    object UniLabel2: TUniLabel
      Left = 7
      Top = 125
      Width = 52
      Height = 13
      Hint = ''
      Caption = #22791#27880#20449#24687':'
      TabOrder = 7
    end
    object EditMemo: TUniMemo
      Left = 68
      Top = 125
      Width = 295
      Height = 56
      Hint = ''
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 8
    end
  end
end
