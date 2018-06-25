inherited fFrameTruckQuery: TfFrameTruckQuery
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
        Caption = #36710#29260#21495#30721':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
      end
      object EditTruck: TUniEdit
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
        OnKeyPress = EditTruckKeyPress
      end
      object Label2: TUniLabel
        Left = 224
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
        Left = 284
        Top = 12
        Width = 125
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 4
        EmptyText = #26597#25214
        OnKeyPress = EditTruckKeyPress
      end
      object Label3: TUniLabel
        Left = 435
        Top = 17
        Width = 54
        Height = 12
        Hint = ''
        Caption = #26085#26399#31579#36873':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 5
      end
      object EditDate: TUniEdit
        Left = 495
        Top = 12
        Width = 185
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 6
        EmptyText = #26597#25214
        ReadOnly = True
        OnKeyPress = EditTruckKeyPress
      end
      object BtnDateFilter: TUniBitBtn
        Left = 682
        Top = 12
        Width = 25
        Height = 22
        Hint = ''
        Caption = '...'
        TabOrder = 7
        OnClick = BtnDateFilterClick
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
  object PMenu1: TUniPopupMenu
    Left = 42
    Top = 182
    object MenuItemN1: TUniMenuItem
      Tag = 10
      Caption = #26174#31034#20840#37096
      OnClick = MenuItemN1Click
    end
    object MenuItemN2: TUniMenuItem
      Caption = '-'
    end
    object MenuItemN3: TUniMenuItem
      Tag = 20
      Caption = #26410#20986#21378#36710#36742
      OnClick = MenuItemN1Click
    end
    object MenuItemN4: TUniMenuItem
      Tag = 30
      Caption = #24050#20986#21378#36710#36742
      OnClick = MenuItemN1Click
    end
  end
end
