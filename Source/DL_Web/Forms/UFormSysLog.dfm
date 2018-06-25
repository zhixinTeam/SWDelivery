inherited fFormSysLog: TfFormSysLog
  ClientHeight = 413
  ClientWidth = 655
  Caption = #31995#32479#26085#24535
  BorderStyle = bsSizeable
  ExplicitWidth = 663
  ExplicitHeight = 440
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 489
    Top = 379
    ExplicitLeft = 489
    ExplicitTop = 379
  end
  inherited BtnExit: TUniButton
    Left = 572
    Top = 379
    ExplicitLeft = 572
    ExplicitTop = 379
  end
  inherited PanelWork: TUniSimplePanel
    Width = 639
    Height = 363
    ExplicitWidth = 639
    ExplicitHeight = 363
    object DBGrid1: TUniDBGrid
      Left = 0
      Top = 47
      Width = 639
      Height = 316
      Hint = ''
      DataSource = DataSource1
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgAutoRefreshRow]
      LoadMask.Message = 'Loading data...'
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 1
    end
    object PanelTop: TUniSimplePanel
      Left = 0
      Top = 0
      Width = 639
      Height = 47
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
        Caption = #20107#20214#23545#35937':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
      end
      object EditItem: TUniEdit
        Left = 70
        Top = 15
        Width = 135
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 2
      end
      object Btn1: TUniButton
        Tag = 20
        Left = 210
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
      object Label3: TUniLabel
        Left = 320
        Top = 20
        Width = 54
        Height = 12
        Hint = ''
        Caption = #26085#26399#31579#36873':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 4
      end
      object EditDate: TUniEdit
        Left = 380
        Top = 15
        Width = 186
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 5
        EmptyText = #26597#25214
        ReadOnly = True
      end
      object BtnDateFilter: TUniBitBtn
        Left = 570
        Top = 15
        Width = 26
        Height = 22
        Hint = ''
        Caption = '...'
        TabOrder = 6
        OnClick = BtnDateFilterClick
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
