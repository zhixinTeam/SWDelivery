inherited fFrameHYData: TfFrameHYData
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
      ExplicitWidth = 991
      object Label2: TUniLabel
        Left = 162
        Top = 18
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
        Left = 220
        Top = 13
        Width = 122
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
        Left = 559
        Top = 18
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
        Left = 617
        Top = 13
        Width = 160
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
        Left = 779
        Top = 13
        Width = 25
        Height = 22
        Hint = ''
        Caption = '...'
        TabOrder = 5
        OnClick = BtnDateFilterClick
      end
      object Label4: TUniLabel
        Left = 12
        Top = 18
        Width = 54
        Height = 12
        Hint = ''
        Caption = #36710#29260#21495#30721':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 6
      end
      object EditTruck: TUniEdit
        Left = 70
        Top = 13
        Width = 83
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 7
        EmptyText = #26597#25214
        OnKeyPress = EditTruckKeyPress
      end
      object UniLabel1: TUniLabel
        Left = 350
        Top = 18
        Width = 48
        Height = 12
        Hint = ''
        Caption = #29289#26009#21517#31216
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 8
      end
      object cbb_Stock: TUniComboBox
        Left = 404
        Top = 13
        Width = 145
        Hint = ''
        Text = ''
        TabOrder = 9
        OnChange = cbb_StockChange
      end
    end
    inherited DBGridMain: TUniDBGrid
      Width = 991
      Height = 540
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
    object MenuItemN1: TUniMenuItem
      Caption = #25171#21360#21270#39564#21333
      OnClick = MenuItemN1Click
    end
    object unmntmN31: TUniMenuItem
      Caption = #25171#21360#21270#39564#21333'('#20165'3'#22825#25968#25454')'
      OnClick = unmntmN31Click
    end
    object N1: TUniMenuItem
      Caption = '-'
    end
    object N2: TUniMenuItem
      Caption = #20462#25913#24320#21333#23458#25143#21517#31216
      OnClick = N2Click
    end
  end
end
