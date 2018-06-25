object TfFormSaleXLPlan: TTfFormSaleXLPlan
  Left = 543
  Top = 235
  BorderStyle = bsDialog
  Caption = 'TfFormSaleXLPlan'
  ClientHeight = 448
  ClientWidth = 697
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object lbl1: TLabel
    Left = 479
    Top = 17
    Width = 60
    Height = 12
    Caption = #29983#25928#26085#26399#65306
  end
  object lbl2: TLabel
    Left = 433
    Top = 73
    Width = 108
    Height = 12
    Caption = #24403#21069#21697#31181#38480#37327#21544#25968#65306
  end
  object lbl3: TLabel
    Left = 433
    Top = 113
    Width = 108
    Height = 12
    Caption = #24403#21069#23458#25143#38480#37327#21544#25968#65306
  end
  object lst_Stock: TcxListBox
    Left = 8
    Top = 5
    Width = 153
    Height = 438
    ItemHeight = 16
    MultiSelect = True
    ParentFont = False
    Style.Font.Charset = GB2312_CHARSET
    Style.Font.Color = clBlack
    Style.Font.Height = -16
    Style.Font.Name = #23435#20307
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 0
  end
  object lst_CusName: TcxListBox
    Left = 168
    Top = 4
    Width = 241
    Height = 438
    ItemHeight = 15
    MultiSelect = True
    ParentFont = False
    Style.Font.Charset = GB2312_CHARSET
    Style.Font.Color = clBlack
    Style.Font.Height = -15
    Style.Font.Name = #23435#20307
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 1
  end
  object Edt_StockNum: TcxTextEdit
    Left = 541
    Top = 70
    Hint = 'T.L_CusName'
    ParentFont = False
    TabOrder = 2
    Width = 132
  end
  object btn_Save: TButton
    Left = 584
    Top = 149
    Width = 89
    Height = 27
    Caption = #20445#23384
    TabOrder = 3
    OnClick = btn_SaveClick
  end
  object Edt_CusNum: TcxTextEdit
    Left = 541
    Top = 110
    Hint = 'T.L_CusName'
    ParentFont = False
    TabOrder = 4
    Width = 132
  end
  object DateEdt_Date: TcxDateEdit
    Left = 537
    Top = 12
    ParentFont = False
    Properties.SaveTime = False
    Properties.ShowTime = False
    TabOrder = 5
    Width = 136
  end
end
