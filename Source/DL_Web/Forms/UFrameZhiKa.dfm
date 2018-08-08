inherited fFrameZhiKa: TfFrameZhiKa
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
      object Label1: TUniLabel
        Left = 12
        Top = 17
        Width = 54
        Height = 12
        Hint = ''
        Caption = #32440#21345#32534#21495':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
      end
      object EditID: TUniEdit
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
        OnKeyPress = EditIDKeyPress
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
      object EditCus: TUniEdit
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
        OnKeyPress = EditIDKeyPress
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
        OnKeyPress = EditIDKeyPress
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
    object MenuItem9: TUniMenuItem
      Caption = #32440#21345#23457#26680
      OnClick = MenuItem9Click
    end
    object MenuItem1: TUniMenuItem
      Caption = #25171#21360#32440#21345
    end
    object MenuItemN1: TUniMenuItem
      Caption = '-'
    end
    object MenuItemN5: TUniMenuItem
      Caption = '**'#32440#21345#25805#20316'**'
      Enabled = False
    end
    object MenuItem3: TUniMenuItem
      Tag = 10
      Caption = #20923#32467#32440#21345
      OnClick = MenuItem2Click
    end
    object MenuItem4: TUniMenuItem
      Tag = 20
      Caption = #35299#38500#20923#32467
      OnClick = MenuItem2Click
    end
    object MenuItem5: TUniMenuItem
      Caption = #38480#21046#25552#36135
      OnClick = MenuItem5Click
    end
    object MenuItemN4: TUniMenuItem
      Caption = '-'
    end
    object MenuItem2: TUniMenuItem
      Tag = 10
      Caption = '**'#26597#35810#36873#39033'**'
      Enabled = False
      OnClick = MenuItem2Click
    end
    object MenuItem6: TUniMenuItem
      Tag = 10
      Caption = #20923#32467#32440#21345
      OnClick = MenuItem6Click
    end
    object MenuItem7: TUniMenuItem
      Tag = 20
      Caption = #26080#25928#32440#21345
      OnClick = MenuItem6Click
    end
    object MenuItem8: TUniMenuItem
      Tag = 30
      Caption = #26597#35810#20840#37096
      OnClick = MenuItem6Click
    end
  end
end
