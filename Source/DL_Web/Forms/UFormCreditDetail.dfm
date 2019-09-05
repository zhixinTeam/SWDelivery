inherited fFormCreditDetail: TfFormCreditDetail
  ClientHeight = 447
  ClientWidth = 861
  Caption = #20449#29992#21464#21160#26126#32454
  BorderStyle = bsSizeable
  ExplicitWidth = 877
  ExplicitHeight = 486
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 695
    Top = 413
    Enabled = False
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
      DataSource = DataSource1
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgAutoRefreshRow]
      LoadMask.Message = 'Loading data...'
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 1
      OnMouseDown = DBGrid1MouseDown
    end
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
  object PMenu1: TUniPopupMenu
    Left = 34
    Top = 85
    object MenuItem1: TUniMenuItem
      Caption = #20449#29992#23457#26680
      OnClick = MenuItem1Click
    end
  end
end
