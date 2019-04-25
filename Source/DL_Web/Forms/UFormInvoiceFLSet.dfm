inherited fFormInvoiceFLSet: TfFormInvoiceFLSet
  ClientHeight = 315
  ClientWidth = 387
  Caption = #36820#21033#20215#24046
  ExplicitWidth = 393
  ExplicitHeight = 344
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 221
    Top = 281
    ExplicitLeft = 221
    ExplicitTop = 281
  end
  inherited BtnExit: TUniButton
    Left = 304
    Top = 281
    ExplicitLeft = 304
    ExplicitTop = 281
  end
  inherited PanelWork: TUniSimplePanel
    Width = 371
    Height = 265
    ExplicitWidth = 371
    ExplicitHeight = 265
    object Label1: TUniLabel
      Left = 7
      Top = 55
      Width = 52
      Height = 13
      Hint = ''
      Caption = #23458#25143#21517#31216':'
      TabOrder = 1
    end
    object Label2: TUniLabel
      Left = 7
      Top = 90
      Width = 52
      Height = 13
      Hint = ''
      Caption = #21697#31181#21517#31216':'
      TabOrder = 2
    end
    object UniLabel1: TUniLabel
      Left = 7
      Top = 20
      Width = 52
      Height = 13
      Hint = ''
      Caption = #21608#26399#21517#31216':'
      TabOrder = 3
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
      Anchors = [akLeft, akTop, akRight
      TabOrder = 4
      ReadOnly = True
    end
    object UniLabel2: TUniLabel
      Left = 7
      Top = 140
      Width = 52
      Height = 13
      Hint = ''
      Caption = #25552#36135#24635#37327':'
      TabOrder = 5
    end
    object EditCustomer: TUniEdit
      Left = 68
      Top = 50
      Width = 295
      Hint = ''
      MaxLength = 50
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight
      TabOrder = 6
      ReadOnly = True
    end
    object EditStock: TUniEdit
      Left = 68
      Top = 85
      Width = 295
      Hint = ''
      MaxLength = 50
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight
      TabOrder = 7
      ReadOnly = True
    end
    object EditValue: TUniEdit
      Left = 68
      Top = 135
      Width = 110
      Hint = ''
      MaxLength = 50
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight
      TabOrder = 8
      ReadOnly = True
    end
    object EditPrice: TUniEdit
      Left = 253
      Top = 135
      Width = 110
      Hint = ''
      MaxLength = 50
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight
      TabOrder = 9
      ReadOnly = True
    end
    object UniLabel3: TUniLabel
      Left = 195
      Top = 140
      Width = 52
      Height = 13
      Hint = ''
      Caption = #25552#36135#21333#20215':'
      TabOrder = 10
    end
    object UniLabel4: TUniLabel
      Left = 7
      Top = 172
      Width = 52
      Height = 13
      Hint = ''
      Caption = #21407#36820#21033#20215':'
      TabOrder = 11
    end
    object EditFL: TUniEdit
      Left = 68
      Top = 168
      Width = 110
      Hint = ''
      MaxLength = 50
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight
      TabOrder = 12
      ReadOnly = True
    end
    object EditFLNew: TUniEdit
      Left = 253
      Top = 168
      Width = 110
      Hint = ''
      MaxLength = 50
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight
      TabOrder = 13
    end
    object UniLabel5: TUniLabel
      Left = 195
      Top = 172
      Width = 52
      Height = 13
      Hint = ''
      Caption = #26032#36820#21033#20215':'
      TabOrder = 14
    end
    object Panel2: TUniSimplePanel
      Left = 7
      Top = 122
      Width = 355
      Height = 1
      Hint = ''
      ParentColor = False
      Border = True
      TabOrder = 15
    end
    object UnLbl1: TUniLabel
      Left = 7
      Top = 204
      Width = 52
      Height = 13
      Hint = ''
      Caption = #21407#36816#36153#20215':'
      TabOrder = 16
    end
    object unEdt_YunFei: TUniEdit
      Left = 68
      Top = 231
      Width = 110
      Hint = ''
      MaxLength = 50
      Text = ''
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      Anchors = [akLeft, akTop, akRight
      TabOrder = 17
    end
    object UnLbl2: TUniLabel
      Left = 7
      Top = 235
      Width = 52
      Height = 13
      Hint = ''
      Caption = #26032#36820#36816#20215':'
      TabOrder = 18
    end
    object UnLbl3: TUniLabel
      Left = 69
      Top = 205
      Width = 6
      Height = 13
      Hint = ''
      Caption = '0'
      TabOrder = 19
    end
    object UnLbl4: TUniLabel
      Left = 197
      Top = 235
      Width = 128
      Height = 13
      Hint = ''
      Caption = '('#21407#20215#26684'-'#26032#20215#26684'='#36820#21033#20215')'
      TabOrder = 20
    end
  end
end
