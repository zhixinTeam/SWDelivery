inherited fFrameQueryStockOddDays: TfFrameQueryStockOddDays
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
      object EdtSearchTime: TUniDateTimePicker
        Left = 72
        Top = 12
        Width = 184
        Hint = ''
        DateTime = 43224.000000000000000000
        DateFormat = 'yyyy-MM-dd'
        TimeFormat = 'HH:mm:ss'
        TabOrder = 2
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
      end
    end
    inherited DBGridMain: TUniDBGrid
      Width = 991
      Height = 334
      Grouping.FieldName = 'L_Type'
      Grouping.FieldCaption = #31867#22411
      Grouping.Enabled = True
      Summary.Enabled = True
      Summary.GrandTotal = True
      Summary.GrandTotalAlign = taBottom
      Columns = <
        item
          Width = 64
          Font.Charset = GB2312_CHARSET
          Font.Height = -12
          Font.Name = #23435#20307
        end>
    end
    object Splitter1: TUniSplitter
      Left = 0
      Top = 630
      Width = 991
      Height = 6
      Cursor = crVSplit
      Hint = ''
      Align = alBottom
      ParentColor = False
      Color = clBtnFace
    end
    object Chart1: TUniChart
      Left = 0
      Top = 430
      Width = 991
      Height = 200
      Hint = ''
      Visible = False
      Animate = True
      Axes.AxisA.Title = #38144#37327'('#21544')'
      Title.Text.Strings = (
        #21452#20987#19978#38754#30340#25253#34920#25968#25454','#26174#31034#22270#34920'.')
      LayoutConfig.BodyPadding = '10'
      Align = alBottom
      Anchors = [akLeft, akRight, akBottom
      TitleAlign = taCenter
      object Series1: TUniLineSeries
        Title = #26376#21333#26085#32479#35745
        MarkerConfig.Shape = 'circle'
        MarkerConfig.Radius = 2
      end
    end
  end
  inherited frxRprt1: TfrxReport
    Datasets = <>
    Variables = <>
    Style = <>
  end
end
