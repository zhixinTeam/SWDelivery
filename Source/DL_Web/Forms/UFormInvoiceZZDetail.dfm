inherited fFormInvoiceZZDetail: TfFormInvoiceZZDetail
  ClientHeight = 447
  ClientWidth = 861
  Caption = #25166#24080#26126#32454#65288#21457#36135#35760#24405#65289
  BorderStyle = bsSizeable
  ExplicitWidth = 877
  ExplicitHeight = 486
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 695
    Top = 413
    ExplicitLeft = 695
    ExplicitTop = 413
  end
  inherited BtnExit: TUniButton
    Left = 778
    Top = 413
    Caption = #20851#38381
    ExplicitLeft = 778
    ExplicitTop = 413
  end
  inherited PanelWork: TUniSimplePanel
    Width = 845
    Height = 397
    ExplicitWidth = 845
    ExplicitHeight = 397
    object DBGrid1: TUniDBGrid
      Left = 0
      Top = 0
      Width = 845
      Height = 397
      Hint = ''
      RowEditor = True
      DataSource = DataSource1
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgRowSelect, dgCheckSelect, dgConfirmDelete, dgMultiSelect, dgAutoRefreshRow]
      LoadMask.Message = 'Loading data...'
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Height = -13
      ParentFont = False
      TabOrder = 1
      Summary.Enabled = True
      Summary.GrandTotal = True
      OnCellClick = DBGrid1CellClick
    end
  end
  object Chk_All: TUniCheckBox
    Left = 16
    Top = 418
    Width = 97
    Height = 17
    Hint = ''
    Checked = True
    Caption = #20840#36873'/'#21462#28040#20840#36873
    Anchors = [akLeft, akBottom]
    TabOrder = 3
    OnClick = Chk_AllClick
  end
  object UnLblChk: TUniLabel
    Left = 150
    Top = 420
    Width = 69
    Height = 13
    Hint = ''
    Caption = #24050#36873#25321#65306'0 '#21544
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  object UnLblTotal: TUniLabel
    Left = 366
    Top = 420
    Width = 57
    Height = 13
    Hint = ''
    Caption = #24635#25968#65306'0 '#21544
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object ClientDS1: TClientDataSet
    Aggregates = <>
    ObjectView = False
    Params = <>
    Left = 32
    Top = 136
  end
  object DataSource1: TDataSource
    DataSet = ClientDS1
    Left = 88
    Top = 136
  end
end
