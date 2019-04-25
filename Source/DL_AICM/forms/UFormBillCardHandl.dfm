object FormBillCardHandl: TFormBillCardHandl
  Left = 447
  Top = 86
  BorderStyle = bsNone
  Caption = #33258#21161#30003#35831#21150#21345
  ClientHeight = 831
  ClientWidth = 977
  Color = clMenuHighlight
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #24494#36719#38597#40657
  Font.Style = [
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    977
    831)
  PixelsPerInch = 96
  TextHeight = 17
  object lbl1: TLabel
    Left = 13
    Top = 15
    Width = 110
    Height = 31
    Caption = #26597#25214#23458#25143' :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = #24494#36719#38597#40657
    Font.Style = [fsBold
    ParentFont = False
  end
  object lbl2: TLabel
    Left = 178
    Top = 517
    Width = 243
    Height = 38
    Caption = '                           '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -29
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentFont = False
  end
  object lbl3: TLabel
    Left = 178
    Top = 570
    Width = 243
    Height = 38
    Caption = '                           '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -29
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentFont = False
  end
  object lbl4: TLabel
    Left = 25
    Top = 622
    Width = 132
    Height = 38
    Caption = #36873#25321#32440#21345' :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -29
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentFont = False
  end
  object lbl5: TLabel
    Left = 25
    Top = 679
    Width = 132
    Height = 38
    Caption = #39592#26009#21697#31181' :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -29
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentFont = False
  end
  object lbl6: TLabel
    Left = 498
    Top = 622
    Width = 132
    Height = 38
    Caption = #24320#21333#21544#25968' :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -29
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentFont = False
  end
  object lbl7: TLabel
    Left = 498
    Top = 679
    Width = 132
    Height = 38
    Caption = #36710#29260#21495#30721' :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -29
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentFont = False
  end
  object lbl8: TLabel
    Left = 25
    Top = 567
    Width = 132
    Height = 38
    Caption = #23458#25143#21517#31216' :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -29
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentFont = False
  end
  object lbl9: TLabel
    Left = 25
    Top = 514
    Width = 132
    Height = 38
    Caption = #23458#25143#32534#21495' :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -29
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentFont = False
  end
  object lbl10: TLabel
    Left = 815
    Top = 627
    Width = 102
    Height = 28
    Caption = '                 '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -21
    Font.Name = #24494#36719#38597#40657
    Font.Style = [fsBold
    ParentFont = False
  end
  object dbgrd1: TDBGrid
    Left = 8
    Top = 57
    Width = 889
    Height = 433
    Anchors = [akLeft, akTop, akRight
    Ctl3D = False
    DataSource = Ds_Mx1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -21
    TitleFont.Name = #24494#36719#38597#40657
    TitleFont.Style = [
    OnCellClick = dbgrd1CellClick
    Columns = <
      item
        Expanded = False
        FieldName = 'C_ID'
        Title.Caption = #23458#25143#32534#21495
        Width = 205
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'C_Name'
        Title.Caption = #23458#25143#21517#31216
        Width = 561
        Visible = True
      end>
  end
  object edt1: TEdit
    Left = 142
    Top = 14
    Width = 251
    Height = 33
    BevelEdges = [beBottom
    BevelKind = bkFlat
    BevelOuter = bvRaised
    BiDiMode = bdLeftToRight
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentBiDiMode = False
    ParentFont = False
    TabOrder = 1
    OnKeyPress = edt1KeyPress
  end
  object btn1: TButton
    Left = 416
    Top = 14
    Width = 137
    Height = 35
    Caption = #26597#25214
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = #24494#36719#38597#40657
    Font.Style = [fsBold
    ParentFont = False
    TabOrder = 2
    OnClick = btn1Click
  end
  object cbb_ZK: TcxComboBox
    Left = 173
    Top = 625
    ParentFont = False
    Properties.DropDownListStyle = lsFixedList
    Properties.DropDownRows = 6
    Properties.ItemHeight = 25
    Properties.Items.Strings = (
      'C=C'#12289#26222#36890
      'Z=Z'#12289#26632#21488
      'V=V'#12289'VIP'
      'S=S'#12289#33337#36816)
    Properties.OnEditValueChanged = cbb_ZKPropertiesEditValueChanged
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.Color = clBtnFace
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -27
    Style.Font.Name = #23435#20307
    Style.Font.Style = [
    Style.TextColor = clWindowText
    Style.ButtonStyle = btsDefault
    Style.PopupBorderStyle = epbsSingle
    Style.IsFontAssigned = True
    StyleDisabled.BorderColor = clMenuHighlight
    StyleDisabled.BorderStyle = ebsSingle
    StyleDisabled.Color = clCream
    StyleDisabled.ButtonStyle = btsDefault
    TabOrder = 3
    Width = 314
  end
  object cbb_Stocks: TcxComboBox
    Left = 173
    Top = 682
    ParentFont = False
    Properties.DropDownListStyle = lsFixedList
    Properties.DropDownRows = 6
    Properties.ItemHeight = 25
    Properties.Items.Strings = (
      'C=C'#12289#26222#36890
      'Z=Z'#12289#26632#21488
      'V=V'#12289'VIP'
      'S=S'#12289#33337#36816)
    Properties.OnEditValueChanged = cbb_StocksPropertiesEditValueChanged
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.Color = clBtnFace
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -27
    Style.Font.Name = #23435#20307
    Style.Font.Style = [
    Style.TextColor = clWindowText
    Style.ButtonStyle = btsDefault
    Style.PopupBorderStyle = epbsSingle
    Style.IsFontAssigned = True
    StyleDisabled.BorderColor = clMenuHighlight
    StyleDisabled.BorderStyle = ebsSingle
    StyleDisabled.Color = clCream
    StyleDisabled.ButtonStyle = btsDefault
    TabOrder = 4
    Width = 314
  end
  object edt_Value: TcxTextEdit
    Left = 642
    Top = 625
    ParentFont = False
    Properties.ReadOnly = False
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -27
    Style.Font.Name = #23435#20307
    Style.Font.Style = [
    Style.IsFontAssigned = True
    TabOrder = 5
    OnKeyPress = edt_ValueKeyPress
    Width = 157
  end
  object btnOK: TButton
    Left = 405
    Top = 739
    Width = 260
    Height = 49
    Caption = #30830#35748#26080#35823#24182#21150#21345
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentFont = False
    TabOrder = 6
    OnClick = btnOKClick
  end
  object btnBtnExit: TButton
    Left = 677
    Top = 739
    Width = 116
    Height = 49
    Caption = #21462#28040
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = #24494#36719#38597#40657
    Font.Style = [
    ParentFont = False
    TabOrder = 7
    OnClick = btnBtnExitClick
  end
  object cbb_TruckNo: TcxComboBox
    Left = 643
    Top = 682
    ParentFont = False
    Properties.ItemHeight = 25
    Properties.Items.Strings = (
      #28189'D'
      #28189'C'
      #28189'K'
      #28189'A'
      #24029
      #36149)
    Properties.OnEditValueChanged = cbb_StocksPropertiesEditValueChanged
    Style.BorderColor = clWindowFrame
    Style.BorderStyle = ebsSingle
    Style.Color = clBtnFace
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -27
    Style.Font.Name = #23435#20307
    Style.Font.Style = [
    Style.TextColor = clWindowText
    Style.ButtonStyle = btsDefault
    Style.PopupBorderStyle = epbsSingle
    Style.IsFontAssigned = True
    StyleDisabled.BorderColor = clMenuHighlight
    StyleDisabled.BorderStyle = ebsSingle
    StyleDisabled.Color = clCream
    StyleDisabled.ButtonStyle = btsDefault
    TabOrder = 8
    Text = #28189'D'
    Width = 156
  end
  object Ds_Mx1: TDataSource
    DataSet = CltDs_1
    Left = 64
    Top = 128
  end
  object Qry_1: TADOQuery
    DataSource = Ds_Mx1
    Parameters = <>
    Left = 104
    Top = 128
  end
  object CltDs_1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dtstprvdr1'
    Left = 184
    Top = 128
  end
  object dtstprvdr1: TDataSetProvider
    DataSet = Qry_1
    Left = 224
    Top = 128
  end
end
