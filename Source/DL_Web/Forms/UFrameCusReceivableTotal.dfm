inherited fFrameCusReceivableTotal: TfFrameCusReceivableTotal
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
      object Label3: TUniLabel
        Left = 20
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
        Left = 81
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
        Left = 268
        Top = 12
        Width = 25
        Height = 22
        Hint = ''
        Caption = '...'
        TabOrder = 3
        OnClick = BtnDateFilterClick
      end
    end
    inherited DBGridMain: TUniDBGrid
      Columns = <
        item
          Width = 64
          Font.Charset = GB2312_CHARSET
          Font.Height = -12
          Font.Name = #23435#20307
        end>
    end
    object UniHiddenPanel1: TUniHiddenPanel
      Left = 26
      Top = 336
      Width = 160
      Height = 56
      Hint = ''
      Visible = True
      object BtnLoad: TUniButton
        Left = 24
        Top = 16
        Width = 75
        Height = 25
        Hint = ''
        Caption = 'Load Data'
        TabOrder = 1
        ScreenMask.Enabled = True
        ScreenMask.Message = #27491#22312#29983#25104#25253#34920','#35831#31245#21518
        ScreenMask.Target = DBGridMain
        OnClick = BtnLoadClick
      end
    end
  end
  inherited frxRprt1: TfrxReport
    Datasets = <>
    Variables = <>
    Style = <>
  end
end
