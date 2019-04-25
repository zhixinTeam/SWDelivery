inherited fFrameSalePlan: TfFrameSalePlan
  Width = 946
  Height = 601
  ExplicitWidth = 946
  ExplicitHeight = 601
  inherited PanelWork: TUniContainerPanel
    Width = 946
    Height = 601
    ExplicitWidth = 946
    ExplicitHeight = 601
    inherited UniToolBar1: TUniToolBar
      Width = 946
      ExplicitWidth = 946
      inherited BtnAdd: TUniToolButton
        OnClick = BtnAddClick
      end
      inherited BtnEdit: TUniToolButton
        OnClick = BtnEditClick
        ExplicitLeft = 81
        ExplicitTop = 1
      end
      inherited BtnDel: TUniToolButton
        OnClick = BtnDelClick
      end
    end
    inherited PanelQuick: TUniSimplePanel
      Width = 946
      ExplicitWidth = 946
      object UnLblLabel1: TUniLabel
        Left = 12
        Top = 17
        Width = 54
        Height = 12
        Hint = ''
        Caption = #21697#31181#21517#31216':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
      end
      object EditStock: TUniEdit
        Left = 70
        Top = 12
        Width = 83
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 2
        EmptyText = #26597#25214
        OnKeyPress = EditStockKeyPress
      end
      object UnLblLabel2: TUniLabel
        Left = 165
        Top = 17
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
        Left = 223
        Top = 12
        Width = 133
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 4
        EmptyText = #26597#25214
        OnKeyPress = EditStockKeyPress
      end
    end
    inherited DBGridMain: TUniDBGrid
      Width = 1
      Height = 505
      Visible = False
      Align = alLeft
      Anchors = [akLeft, akTop, akBottom
    end
    object unpgcntrl1: TUniPageControl
      Left = 1
      Top = 96
      Width = 945
      Height = 505
      Hint = ''
      ActivePage = unSht_1
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom
      TabOrder = 4
      OnChange = unpgcntrl1Change
      object unSht_1: TUniTabSheet
        Hint = ''
        Caption = #21697#31181#38144#21806#35745#21010'    '
        object unDB_Stock: TUniDBGrid
          Left = 0
          Top = 0
          Width = 937
          Height = 477
          Hint = ''
          DataSource = DataSource1
          Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgAutoRefreshRow
          LoadMask.Message = 'Loading data...'
          Align = alClient
          Anchors = [akLeft, akTop, akRight, akBottom
          TabOrder = 0
        end
      end
      object unSht_2: TUniTabSheet
        Hint = ''
        Caption = #21697#31181#12289#23458#25143#38144#21806#35745#21010'     '
        object unDB_StockCus: TUniDBGrid
          Left = 0
          Top = 0
          Width = 937
          Height = 477
          Hint = ''
          DataSource = Ds_Mx
          Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgAutoRefreshRow
          LoadMask.Message = 'Loading data...'
          Align = alClient
          Anchors = [akLeft, akTop, akRight, akBottom
          TabOrder = 0
        end
      end
    end
  end
  inherited frxRprt1: TfrxReport
    Datasets = <>
    Variables = <>
    Style = <>
  end
  object Ds_Mx: TDataSource
    DataSet = Ds_StockCus
    Left = 248
    Top = 232
  end
  object Ds_StockCus: TClientDataSet
    Aggregates = <>
    ObjectView = False
    Params = <>
    Left = 192
    Top = 232
  end
end
