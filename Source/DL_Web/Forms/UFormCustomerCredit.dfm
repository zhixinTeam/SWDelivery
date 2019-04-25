inherited fFormCustomerCredit: TfFormCustomerCredit
  ClientHeight = 283
  ClientWidth = 463
  Caption = #20449#29992#21464#21160
  ExplicitWidth = 469
  ExplicitHeight = 312
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 297
    Top = 249
    TabOrder = 1
    ExplicitLeft = 297
    ExplicitTop = 249
  end
  inherited BtnExit: TUniButton
    Left = 380
    Top = 249
    TabOrder = 2
    ExplicitLeft = 380
    ExplicitTop = 249
  end
  inherited PanelWork: TUniSimplePanel
    Width = 447
    Height = 233
    TabOrder = 0
    ExplicitWidth = 447
    ExplicitHeight = 233
    object Label1: TUniLabel
      Left = 8
      Top = 56
      Width = 54
      Height = 12
      Hint = ''
      Caption = #23458#25143#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 4
    end
    object Label2: TUniLabel
      Left = 8
      Top = 20
      Width = 54
      Height = 12
      Hint = ''
      Caption = #19994#21153#20154#21592':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 2
    end
    object EditSaleMan: TUniComboBox
      Left = 68
      Top = 15
      Width = 368
      Hint = ''
      Style = csDropDownList
      Text = ''
      Anchors = [akLeft, akTop, akRight
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 1
      OnChange = EditSaleManChange
    end
    object EditCus: TUniComboBox
      Left = 68
      Top = 50
      Width = 368
      Hint = ''
      Style = csDropDownList
      MaxLength = 35
      Text = ''
      Anchors = [akLeft, akTop, akRight
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 3
    end
    object Label3: TUniLabel
      Left = 8
      Top = 92
      Width = 54
      Height = 12
      Hint = ''
      Caption = #20449#29992#37329#39069':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 6
    end
    object EditCredit: TUniEdit
      Left = 68
      Top = 87
      Width = 200
      Hint = ''
      Text = '0'
      TabOrder = 5
    end
    object Label4: TUniLabel
      Left = 280
      Top = 92
      Width = 144
      Height = 12
      Hint = ''
      Caption = #27880':'#37329#39069#20026#36127#34920#31034#20943#23567#39069#24230'.'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 7
    end
    object Label5: TUniLabel
      Left = 8
      Top = 128
      Width = 54
      Height = 12
      Hint = ''
      Caption = #26377#25928#26085#26399':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 9
    end
    object EditEnd: TUniDateTimePicker
      Left = 68
      Top = 123
      Width = 200
      Hint = ''
      DateTime = 43227.681968877320000000
      DateFormat = 'yyyy-MM-dd'
      TimeFormat = 'HH:mm:ss'
      Kind = tUniDateTime
      TabOrder = 8
    end
    object Label6: TUniLabel
      Left = 280
      Top = 128
      Width = 144
      Height = 12
      Hint = ''
      Caption = #27880':'#20026#26368#21518#19968#27425#25480#20449#26102#26377#25928'.'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 10
    end
    object Label7: TUniLabel
      Left = 8
      Top = 164
      Width = 54
      Height = 12
      Hint = ''
      Caption = #22791#27880#20449#24687':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 12
    end
    object EditMemo: TUniEdit
      Left = 68
      Top = 159
      Width = 368
      Hint = ''
      Text = ''
      Anchors = [akLeft, akTop, akRight
      TabOrder = 11
    end
    object unlbl1: TUniLabel
      Left = 20
      Top = 200
      Width = 42
      Height = 12
      Hint = ''
      Caption = #23457#26680#20154':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 13
    end
    object cbb_VarMan: TUniComboBox
      Left = 68
      Top = 196
      Width = 125
      Hint = ''
      Text = ''
      Anchors = [akLeft, akTop, akRight
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 14
      OnChange = EditSaleManChange
    end
  end
end
