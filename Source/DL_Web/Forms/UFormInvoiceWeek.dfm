inherited fFormInvoiceWeek: TfFormInvoiceWeek
  ClientHeight = 308
  ClientWidth = 387
  Caption = #32467#31639#21608#26399
  ExplicitWidth = 393
  ExplicitHeight = 337
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 223
    Top = 274
    ExplicitLeft = 223
    ExplicitTop = 274
  end
  inherited BtnExit: TUniButton
    Left = 304
    Top = 274
    ExplicitLeft = 304
    ExplicitTop = 274
  end
  inherited PanelWork: TUniSimplePanel
    Width = 371
    Height = 258
    ExplicitWidth = 371
    ExplicitHeight = 258
    object EditStart: TUniDateTimePicker
      Left = 68
      Top = 137
      Width = 181
      Hint = ''
      DateTime = 43224.000000000000000000
      DateFormat = 'yyyy-MM-dd'
      TimeFormat = 'HH:mm:ss'
      Kind = tUniDateTime
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      OnExit = EditEndExit
    end
    object Label1: TUniLabel
      Left = 7
      Top = 142
      Width = 52
      Height = 13
      Hint = ''
      Caption = #24320#22987#26085#26399':'
      TabOrder = 2
    end
    object Label2: TUniLabel
      Left = 7
      Top = 172
      Width = 52
      Height = 13
      Hint = ''
      Caption = #32467#26463#26085#26399':'
      TabOrder = 3
    end
    object EditEnd: TUniDateTimePicker
      Left = 68
      Top = 168
      Width = 181
      Hint = ''
      DateTime = 43224.000000000000000000
      DateFormat = 'yyyy-MM-dd'
      TimeFormat = 'HH:mm:ss'
      Kind = tUniDateTime
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      OnExit = EditEndExit
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
      Top = 200
      Width = 52
      Height = 13
      Hint = ''
      Caption = #22791#27880#20449#24687':'
      TabOrder = 7
    end
    object EditMemo: TUniMemo
      Left = 68
      Top = 200
      Width = 295
      Height = 50
      Hint = ''
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 8
    end
    object cbb_Stock: TUniComboBox
      Left = 68
      Top = 106
      Width = 295
      Hint = ''
      Text = ''
      TabOrder = 9
    end
    object UnLbl1: TUniLabel
      Left = 7
      Top = 109
      Width = 54
      Height = 12
      Hint = ''
      Caption = #29289#26009#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 10
    end
    object cbb_EditCus: TUniComboBox
      Left = 68
      Top = 75
      Width = 295
      Hint = ''
      Enabled = False
      Style = csDropDownList
      MaxLength = 35
      Text = ''
      Anchors = [akLeft, akTop, akRight]
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 11
    end
    object UnLbl2: TUniLabel
      Left = 5
      Top = 80
      Width = 54
      Height = 12
      Hint = ''
      Caption = #23458#25143#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 12
    end
    object cbb_EditSaleMan: TUniComboBox
      Left = 68
      Top = 46
      Width = 173
      Hint = ''
      Enabled = False
      Style = csDropDownList
      Text = ''
      Anchors = [akLeft, akTop, akRight]
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 13
      OnChange = cbb_EditSaleManChange
    end
    object UnLbl3: TUniLabel
      Left = 7
      Top = 51
      Width = 54
      Height = 12
      Hint = ''
      Caption = #19994#21153#20154#21592':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 14
    end
    object Chk_1: TUniCheckBox
      Left = 247
      Top = 47
      Width = 116
      Height = 17
      Hint = ''
      Caption = #20165#36873#25321#30340#23458#25143
      TabOrder = 15
      OnClick = Chk_1Click
    end
  end
end
