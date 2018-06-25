inherited fFrameSalesMan: TfFrameSalesMan
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
        OnClick = BtnAddClick
      end
      inherited BtnEdit: TUniToolButton
        OnClick = BtnEditClick
      end
      inherited BtnDel: TUniToolButton
        OnClick = BtnDelClick
      end
    end
    inherited PanelQuick: TUniSimplePanel
      Height = 45
      ExplicitHeight = 45
      object EditName: TUniEdit
        Left = 72
        Top = 12
        Width = 145
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
        EmptyText = #26597#25214
        OnKeyPress = EditNameKeyPress
      end
      object UniLabel1: TUniLabel
        Left = 12
        Top = 16
        Width = 60
        Height = 12
        Hint = ''
        Caption = #19994' '#21153' '#21592#65306
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 2
      end
    end
    inherited DBGridMain: TUniDBGrid
      Top = 97
      Height = 493
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
  object PMenu1: TUniPopupMenu
    Left = 40
    Top = 184
    object MenuItemN1: TUniMenuItem
      Tag = 10
      Caption = #26080#25928#20154#21592
      OnClick = MenuItemN1Click
    end
    object MenuItemN2: TUniMenuItem
      Tag = 20
      Caption = #26597#35810#20840#37096
      OnClick = MenuItemN1Click
    end
  end
end
