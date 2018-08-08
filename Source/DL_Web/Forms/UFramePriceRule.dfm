inherited fFramePriceRule: TfFramePriceRule
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
        Caption = #23450#20215
        OnClick = BtnEditClick
      end
      inherited BtnDel: TUniToolButton
        Visible = False
      end
    end
    inherited PanelQuick: TUniSimplePanel
      object Label3: TUniLabel
        Left = 12
        Top = 17
        Width = 54
        Height = 12
        Hint = ''
        Caption = #26085#26399#31579#36873':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
      end
      object EditDate: TUniEdit
        Left = 72
        Top = 12
        Width = 185
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 2
        EmptyText = #26597#25214
        ReadOnly = True
      end
      object BtnDateFilter: TUniBitBtn
        Left = 259
        Top = 12
        Width = 25
        Height = 22
        Hint = ''
        Caption = '...'
        TabOrder = 3
        OnClick = BtnDateFilterClick
      end
      object Check1: TUniCheckBox
        Left = 305
        Top = 15
        Width = 135
        Height = 17
        Hint = ''
        Caption = #26174#31034#21382#21490#23450#20215#35760#24405
        TabOrder = 4
        OnClick = Check1Click
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
      Caption = #21482#26174#31034#35813#21697#31181
      OnClick = MenuItem1Click
    end
  end
end
