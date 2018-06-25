inherited fFormGetCustomer: TfFormGetCustomer
  ClientHeight = 336
  ClientWidth = 558
  Caption = #26597#25214#23458#25143
  BorderStyle = bsSizeable
  ExplicitWidth = 566
  ExplicitHeight = 363
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 392
    Top = 302
    ExplicitLeft = 392
    ExplicitTop = 302
  end
  inherited BtnExit: TUniButton
    Left = 475
    Top = 302
    ExplicitLeft = 475
    ExplicitTop = 302
  end
  inherited PanelWork: TUniSimplePanel
    Width = 542
    Height = 286
    ExplicitWidth = 542
    ExplicitHeight = 286
    object DBGrid1: TUniDBGrid
      Left = 0
      Top = 45
      Width = 542
      Height = 241
      Hint = ''
      DataSource = DataSource1
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgAutoRefreshRow]
      LoadMask.Message = 'Loading data...'
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 1
      Columns = <
        item
          FieldName = 'R_ID'
          Title.Caption = #35760#24405#32534#21495
          Width = 85
          Tag = 1
        end
        item
          FieldName = 'S_ID'
          Title.Caption = #19994#21153#21592#21495
          Width = 85
          Tag = 2
        end
        item
          FieldName = 'S_Name'
          Title.Caption = #19994#21153#21592#21517
          Width = 85
          Tag = 3
        end
        item
          FieldName = 'C_ID'
          Title.Caption = #23458#25143#32534#21495
          Width = 85
          Tag = 4
        end
        item
          FieldName = 'C_Name'
          Title.Caption = #23458#25143#21517#31216
          Width = 150
          Tag = 5
        end>
    end
    object PanelTop: TUniSimplePanel
      Left = 0
      Top = 0
      Width = 542
      Height = 45
      Hint = ''
      ParentColor = False
      Border = True
      Align = alTop
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      object Label2: TUniLabel
        Left = 8
        Top = 20
        Width = 54
        Height = 12
        Hint = ''
        Caption = #23458#25143#21517#31216':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
      end
      object EditCustomer: TUniEdit
        Left = 70
        Top = 15
        Width = 201
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 2
        OnKeyPress = EditCustomerKeyPress
      end
      object Btn1: TUniButton
        Tag = 20
        Left = 280
        Top = 15
        Width = 75
        Height = 22
        Hint = ''
        Caption = #26597#35810
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 3
        OnClick = Btn1Click
      end
    end
  end
  object ClientDS1: TClientDataSet
    Aggregates = <>
    ObjectView = False
    Params = <>
    Left = 40
    Top = 232
  end
  object DataSource1: TDataSource
    DataSet = ClientDS1
    Left = 96
    Top = 232
  end
end
