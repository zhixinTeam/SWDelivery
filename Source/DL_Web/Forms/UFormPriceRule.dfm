inherited fFormPriceRule: TfFormPriceRule
  ClientHeight = 476
  ClientWidth = 440
  Caption = #20215#26684#31574#30053
  OnClose = UniFormClose
  ExplicitWidth = 446
  ExplicitHeight = 505
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 274
    Top = 442
    Visible = False
    ExplicitLeft = 141
    ExplicitTop = 109
  end
  inherited BtnExit: TUniButton
    Left = 357
    Top = 442
    Caption = #20851#38381
    ExplicitLeft = 224
    ExplicitTop = 109
  end
  inherited PanelWork: TUniSimplePanel
    Width = 424
    Height = 426
    ExplicitWidth = 291
    ExplicitHeight = 93
    object EditStock: TUniComboBox
      Left = 70
      Top = 12
      Width = 243
      Hint = ''
      Style = csDropDownList
      Text = ''
      TabOrder = 1
    end
    object UniLabel1: TUniLabel
      Left = 12
      Top = 17
      Width = 52
      Height = 13
      Hint = ''
      Caption = #27700#27877#21517#31216':'
      TabOrder = 2
    end
    object UniLabel2: TUniLabel
      Left = 12
      Top = 47
      Width = 52
      Height = 13
      Hint = ''
      Caption = #20215#26684#21306#38388':'
      TabOrder = 3
    end
    object EditLow: TUniEdit
      Left = 70
      Top = 42
      Width = 107
      Hint = ''
      Text = '0'
      TabOrder = 4
    end
    object UniLabel3: TUniLabel
      Left = 189
      Top = 47
      Width = 4
      Height = 13
      Hint = ''
      Caption = '-'
      TabOrder = 5
    end
    object EditHigh: TUniEdit
      Left = 206
      Top = 42
      Width = 107
      Hint = ''
      Text = '0'
      TabOrder = 6
    end
    object BtnDel: TUniButton
      Left = 332
      Top = 42
      Width = 65
      Height = 22
      Hint = ''
      Caption = #21024#38500
      TabOrder = 7
      OnClick = BtnDelClick
    end
    object DBGrid1: TUniDBGrid
      Left = 0
      Top = 80
      Width = 424
      Height = 346
      Hint = ''
      DataSource = DataSource1
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgAutoRefreshRow]
      LoadMask.Message = 'Loading data...'
      Align = alBottom
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 8
      Columns = <
        item
          FieldName = 'R_StockName'
          Title.Caption = #27700#27877#21517#31216
          Width = 165
        end
        item
          FieldName = 'R_Low'
          Title.Caption = #20215#26684#19979#38480
          Width = 80
          Tag = 1
        end
        item
          FieldName = 'R_High'
          Title.Caption = #20215#26684#19978#38480
          Width = 80
          Tag = 2
        end>
    end
    object BtnAdd: TUniButton
      Left = 332
      Top = 12
      Width = 65
      Height = 22
      Hint = ''
      Caption = #20445#23384
      TabOrder = 9
      OnClick = BtnAddClick
    end
  end
  object DataSource1: TDataSource
    DataSet = ClientDS
    Left = 96
    Top = 232
  end
  object ClientDS: TClientDataSet
    Aggregates = <>
    ObjectView = False
    Params = <>
    Left = 40
    Top = 232
  end
end
