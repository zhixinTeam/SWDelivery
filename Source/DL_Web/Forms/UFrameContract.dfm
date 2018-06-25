inherited fFrameContract: TfFrameContract
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
        Top = 16
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
      object EditID: TUniEdit
        Left = 72
        Top = 12
        Width = 145
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
        Left = 248
        Top = 16
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
        Left = 306
        Top = 12
        Width = 145
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
    object MenuItem1: TUniMenuItem
      Caption = #26597#30475#21464#20215#35760#24405
    end
    object MenuItemN1: TUniMenuItem
      Caption = '-'
    end
    object MenuItem2: TUniMenuItem
      Tag = 10
      Caption = #20923#32467#24403#21069#21512#21516
      OnClick = MenuItem2Click
    end
    object MenuItem3: TUniMenuItem
      Tag = 20
      Caption = #35299#20923#24403#21069#21512#21516
      OnClick = MenuItem2Click
    end
    object MenuItemN4: TUniMenuItem
      Caption = '-'
    end
    object MenuItem4: TUniMenuItem
      Caption = #26597#30475#20840#37096#21512#21516
      OnClick = MenuItem2Click
    end
  end
end
