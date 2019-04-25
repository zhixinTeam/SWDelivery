inherited fFrameInvoiceZZ: TfFrameInvoiceZZ
  Font.Charset = GB2312_CHARSET
  Font.Height = -12
  Font.Name = #23435#20307
  ParentFont = False
  inherited PanelWork: TUniContainerPanel
    inherited UniToolBar1: TUniToolBar
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      inherited BtnAdd: TUniToolButton
        Caption = #38144#21806#25166#24080
        OnClick = BtnAddClick
      end
      inherited BtnEdit: TUniToolButton
        Caption = #20462#25913#20215#24046
        OnClick = BtnEditClick
      end
      inherited BtnDel: TUniToolButton
        Visible = False
      end
    end
    inherited PanelQuick: TUniSimplePanel
      object Label2: TUniLabel
        Left = 12
        Top = 17
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
        Left = 72
        Top = 12
        Width = 125
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 2
        EmptyText = #26597#25214
        OnKeyPress = EditCustomerKeyPress
      end
      object Label3: TUniLabel
        Left = 224
        Top = 17
        Width = 54
        Height = 12
        Hint = ''
        Caption = #21608#26399#31579#36873':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 3
      end
      object EditWeek: TUniEdit
        Left = 285
        Top = 12
        Width = 265
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 4
        EmptyText = #26597#25214
        ReadOnly = True
      end
      object BtnWeekFilter: TUniBitBtn
        Left = 552
        Top = 12
        Width = 25
        Height = 22
        Hint = ''
        Caption = '...'
        TabOrder = 5
        OnClick = BtnWeekFilterClick
      end
    end
    inherited DBGridMain: TUniDBGrid
      Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgRowSelect, dgCheckSelect, dgConfirmDelete, dgAutoRefreshRow
      OnMouseDown = DBGridMainMouseDown
      Columns = <
        item
          Width = 64
          Font.Charset = GB2312_CHARSET
          Font.Height = -12
          Font.Name = #23435#20307
        end>
    end
  end
  inherited frxRprt1: TfrxReport
    Datasets = <>
    Variables = <>
    Style = <>
  end
  object PMenu1: TUniPopupMenu
    Left = 42
    Top = 184
    object MenuItem1: TUniMenuItem
      Caption = #20462#25913#36820#21033#20215#24046
      OnClick = BtnEditClick
    end
    object N1: TUniMenuItem
      Caption = '-'
    end
    object unmntmN5: TUniMenuItem
      Caption = #26597#30475#26126#32454#21457#36135#35760#24405
      OnClick = unmntmN5Click
    end
    object unmntmN4: TUniMenuItem
      Caption = '-'
    end
    object N2: TUniMenuItem
      Caption = #26597#35810#20462#25913#35760#24405
      OnClick = N2Click
    end
    object N3: TUniMenuItem
      Caption = #26597#35810#26410#36820#23436#27605
      OnClick = N3Click
    end
  end
end
