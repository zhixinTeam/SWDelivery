inherited fFormZKFreeze: TfFormZKFreeze
  ClientHeight = 466
  ClientWidth = 450
  Caption = #25353#21697#31181#20923#32467
  ExplicitWidth = 456
  ExplicitHeight = 495
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 284
    Top = 432
    TabOrder = 1
    ExplicitLeft = 284
    ExplicitTop = 432
  end
  inherited BtnExit: TUniButton
    Left = 367
    Top = 432
    TabOrder = 2
    ExplicitLeft = 367
    ExplicitTop = 432
  end
  inherited PanelWork: TUniSimplePanel
    Width = 434
    Height = 416
    TabOrder = 0
    ExplicitWidth = 434
    ExplicitHeight = 416
    object Panel1: TUniSimplePanel
      Left = 0
      Top = 311
      Width = 434
      Height = 105
      Hint = ''
      ParentColor = False
      Align = alBottom
      Anchors = [akLeft, akRight, akBottom]
      TabOrder = 2
      object Check1: TUniCheckBox
        Tag = 10
        Left = 12
        Top = 12
        Width = 145
        Height = 17
        Hint = ''
        Caption = #20840#36873'/'#20840#19981#36873'('#34955#35013')'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
        OnClick = Check1Click
      end
      object Check2: TUniCheckBox
        Tag = 20
        Left = 223
        Top = 12
        Width = 145
        Height = 17
        Hint = ''
        Caption = #20840#36873'/'#20840#19981#36873'('#25955#35013')'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 2
        OnClick = Check1Click
      end
      object Radio1: TUniRadioButton
        Left = 12
        Top = 50
        Width = 233
        Height = 17
        Hint = ''
        Checked = True
        Caption = #20923#32467#21253#21547#35813#21697#31181#30340#25152#26377#32440#21345'.'
        TabOrder = 3
      end
      object Radio2: TUniRadioButton
        Left = 12
        Top = 75
        Width = 233
        Height = 17
        Hint = ''
        Caption = #35299#38500#20923#32467#21253#21547#35813#21697#31181#30340#32440#21345'.'
        TabOrder = 4
      end
    end
    object Grid1: TUniStringGrid
      Left = 0
      Top = 0
      Width = 434
      Height = 311
      Hint = #21452#20987#32534#36753
      ShowHint = True
      ParentShowHint = False
      FixedCols = 0
      FixedRows = 0
      Options = [goVertLine, goHorzLine, goEditing, goAlwaysShowEditor, goFixedColClick]
      ShowColumnTitles = True
      Columns = <
        item
          Title.Caption = #27700#27877#32534#21495
          Width = 80
        end
        item
          Title.Caption = #21253#35013#31867#22411
          Width = 80
        end
        item
          Title.Caption = #27700#27877#21517#31216
          Width = 180
        end
        item
          Title.Caption = #36873#20013
          Width = 80
        end
        item
          Title.Caption = #21253#35013#31867#22411
          Width = 0
        end>
      OnClick = Grid1Click
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
    end
  end
end
