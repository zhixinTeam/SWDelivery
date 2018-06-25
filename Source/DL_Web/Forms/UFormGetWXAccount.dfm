inherited fFormGetWXAccount: TfFormGetWXAccount
  ClientHeight = 311
  ClientWidth = 462
  Caption = #21830#22478#36134#25143
  BorderStyle = bsSizeable
  ExplicitWidth = 478
  ExplicitHeight = 350
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 296
    Top = 277
    TabOrder = 1
    ExplicitLeft = 288
    ExplicitTop = 449
  end
  inherited BtnExit: TUniButton
    Left = 379
    Top = 277
    TabOrder = 2
    ExplicitLeft = 371
    ExplicitTop = 449
  end
  inherited PanelWork: TUniSimplePanel
    Width = 446
    Height = 261
    TabOrder = 0
    ExplicitWidth = 438
    ExplicitHeight = 433
    object Grid1: TUniStringGrid
      Left = 0
      Top = 49
      Width = 446
      Height = 212
      Hint = ''
      ParentShowHint = False
      FixedCols = 0
      FixedRows = 0
      Options = [goVertLine, goHorzLine, goEditing, goAlwaysShowEditor, goFixedColClick]
      ShowColumnTitles = True
      Columns = <
        item
          Title.Caption = #30331#24405#24080#21495
          Width = 80
        end
        item
          Title.Caption = #37038#31665
          Width = 80
        end
        item
          Title.Caption = #25163#26426#21495#30721
          Width = 180
        end>
      OnSelectCell = Grid1SelectCell
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      ExplicitWidth = 438
      ExplicitHeight = 384
    end
    object UniSimplePanel1: TUniSimplePanel
      Left = 0
      Top = 0
      Width = 446
      Height = 49
      Hint = ''
      ParentColor = False
      Align = alTop
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      ExplicitWidth = 438
      DesignSize = (
        446
        49)
      object UniLabel1: TUniLabel
        Left = 7
        Top = 16
        Width = 56
        Height = 13
        Hint = ''
        Caption = #24080#21495'/'#25163#26426':'
        TabOrder = 1
      end
      object EditID: TUniEdit
        Left = 67
        Top = 12
        Width = 297
        Hint = ''
        Text = ''
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        OnChange = EditIDChange
        ExplicitWidth = 289
      end
      object BtnFind: TUniButton
        Left = 368
        Top = 11
        Width = 65
        Height = 25
        Hint = ''
        Caption = #26597#35810
        Anchors = [akTop, akRight]
        TabOrder = 3
        ScreenMask.Enabled = True
        ScreenMask.Message = #35835#21462#21830#22478#36134#25143#21015#34920
        ScreenMask.Target = Grid1
        OnClick = EditIDChange
        ExplicitLeft = 360
      end
    end
  end
  object UniTimer1: TUniTimer
    Interval = 100
    RunOnce = True
    ClientEvent.Strings = (
      'function(sender)'
      '{'
      ' '
      '}')
    OnTimer = UniTimer1Timer
    Left = 32
    Top = 88
  end
end
