inherited fFrameCusAccount: TfFrameCusAccount
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
        Visible = False
      end
      inherited BtnEdit: TUniToolButton
        Visible = False
      end
      inherited BtnDel: TUniToolButton
        Visible = False
      end
      inherited UniToolButton4: TUniToolButton
        Visible = False
      end
    end
    inherited PanelQuick: TUniSimplePanel
      object Label1: TUniLabel
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
    end
    inherited DBGridMain: TUniDBGrid
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
    Left = 40
    Top = 184
    object MenuItem1: TUniMenuItem
      Tag = 10
      Caption = #38750#27491#24335#23458#25143
      OnClick = MenuItem1Click
    end
    object MenuItem2: TUniMenuItem
      Tag = 20
      Caption = #26597#35810#20840#37096#23458#25143
      OnClick = MenuItem1Click
    end
    object MenuItemN2: TUniMenuItem
      Caption = '-'
    end
    object MenuItem3: TUniMenuItem
      Caption = #26657#27491#23458#25143#36164#37329
      OnClick = MenuItem3Click
    end
  end
end
