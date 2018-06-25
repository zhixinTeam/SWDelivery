inherited fFrameQuerySaleTotal: TfFrameQuerySaleTotal
  Width = 991
  Height = 636
  Font.Charset = GB2312_CHARSET
  Font.Height = -12
  Font.Name = #23435#20307
  ParentFont = False
  ExplicitWidth = 991
  ExplicitHeight = 636
  inherited PanelWork: TUniContainerPanel
    Width = 991
    Height = 636
    ExplicitWidth = 991
    ExplicitHeight = 636
    inherited UniToolBar1: TUniToolBar
      Width = 991
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      ExplicitWidth = 991
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
      Width = 991
      ExplicitLeft = 3
      ExplicitWidth = 991
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
        OnKeyPress = EditTruckKeyPress
      end
      object Label3: TUniLabel
        Left = 224
        Top = 17
        Width = 54
        Height = 12
        Hint = ''
        Caption = #26085#26399#31579#36873':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 3
      end
      object EditDate: TUniEdit
        Left = 285
        Top = 12
        Width = 185
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 4
        EmptyText = #26597#25214
        ReadOnly = True
        OnKeyPress = EditTruckKeyPress
      end
      object BtnDateFilter: TUniBitBtn
        Left = 472
        Top = 12
        Width = 25
        Height = 22
        Hint = ''
        Caption = '...'
        TabOrder = 5
        OnClick = BtnDateFilterClick
      end
      object Radio1: TUniRadioButton
        Left = 595
        Top = 14
        Width = 75
        Height = 17
        Hint = ''
        Checked = True
        Caption = #21516#23458#25143
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 6
      end
      object Radio2: TUniRadioButton
        Left = 665
        Top = 14
        Width = 75
        Height = 17
        Hint = ''
        Caption = #21516#21697#31181
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 7
      end
      object Radio3: TUniRadioButton
        Left = 735
        Top = 14
        Width = 105
        Height = 17
        Hint = ''
        Caption = #21516#23458#25143#21516#21697#31181
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 8
      end
      object Label1: TUniLabel
        Left = 535
        Top = 17
        Width = 54
        Height = 12
        Hint = ''
        Caption = #23458#25143#21517#31216':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 9
      end
    end
    inherited DBGridMain: TUniDBGrid
      Width = 991
      Height = 534
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
      Caption = #26102#38388#27573#26597#35810
      OnClick = MenuItemN1Click
    end
  end
end
