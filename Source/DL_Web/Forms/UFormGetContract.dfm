inherited fFormGetContract: TfFormGetContract
  ClientHeight = 437
  ClientWidth = 425
  Caption = #26597#25214#21512#21516
  BorderStyle = bsSizeable
  ExplicitWidth = 441
  ExplicitHeight = 476
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 259
    Top = 403
    ExplicitLeft = 259
    ExplicitTop = 403
  end
  inherited BtnExit: TUniButton
    Left = 342
    Top = 403
    ExplicitLeft = 342
    ExplicitTop = 403
  end
  inherited PanelWork: TUniSimplePanel
    Width = 409
    Height = 387
    ExplicitWidth = 409
    ExplicitHeight = 387
    object DBGrid1: TUniDBGrid
      Left = 0
      Top = 82
      Width = 409
      Height = 305
      Hint = ''
      DataSource = DataSource1
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgAutoRefreshRow]
      LoadMask.Message = 'Loading data...'
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 1
      Columns = <
        item
          FieldName = 'C_ID'
          Title.Caption = #21512#21516#32534#21495
          Width = 64
        end
        item
          FieldName = 'S_Name'
          Title.Caption = #19994#21153#21592
          Width = 64
          Tag = 1
        end
        item
          FieldName = 'C_Name'
          Title.Caption = #23458#25143#21517#31216
          Width = 64
          Tag = 2
        end
        item
          FieldName = 'C_Project'
          Title.Caption = #39033#30446#21517#31216
          Width = 64
          Tag = 3
        end>
    end
    object PanelTop: TUniSimplePanel
      Left = 0
      Top = 0
      Width = 409
      Height = 82
      Hint = ''
      ParentColor = False
      Border = True
      Align = alTop
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      object Label1: TUniLabel
        Left = 8
        Top = 20
        Width = 54
        Height = 12
        Hint = ''
        Caption = #21512#21516#32534#21495':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
      end
      object EditContract: TUniEdit
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
        OnEnter = EditContractEnter
        OnKeyPress = EditContractKeyPress
      end
      object Label2: TUniLabel
        Left = 8
        Top = 50
        Width = 54
        Height = 12
        Hint = ''
        Caption = #23458#25143#21517#31216':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 3
      end
      object EditCustomer: TUniEdit
        Left = 70
        Top = 45
        Width = 201
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 4
        OnEnter = EditCustomerEnter
        OnKeyPress = EditContractKeyPress
      end
      object Btn1: TUniButton
        Tag = 20
        Left = 280
        Top = 45
        Width = 75
        Height = 22
        Hint = ''
        Caption = #26597#35810
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 5
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
