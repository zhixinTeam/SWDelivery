inherited fFormZhiKaVerify: TfFormZhiKaVerify
  ClientHeight = 469
  ClientWidth = 457
  Caption = #20215#26684#23457#26680
  ExplicitWidth = 463
  ExplicitHeight = 498
  PixelsPerInch = 96
  TextHeight = 13
  inherited BtnOK: TUniButton
    Left = 291
    Top = 435
    Caption = #36890#36807
    ExplicitLeft = 244
    ExplicitTop = 373
  end
  inherited BtnExit: TUniButton
    Left = 374
    Top = 435
    ExplicitLeft = 327
    ExplicitTop = 373
  end
  inherited PanelWork: TUniSimplePanel
    Width = 441
    Height = 419
    ExplicitWidth = 394
    ExplicitHeight = 357
    object Label2: TUniLabel
      Left = 8
      Top = 20
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
    object Label1: TUniLabel
      Left = 8
      Top = 56
      Width = 54
      Height = 12
      Hint = ''
      Caption = #23458#25143#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 2
    end
    object EditZK: TUniEdit
      Left = 68
      Top = 15
      Width = 135
      Hint = ''
      Text = ''
      TabOrder = 3
      ReadOnly = True
    end
    object EditName: TUniEdit
      Left = 293
      Top = 15
      Width = 135
      Hint = ''
      Text = ''
      TabOrder = 4
      ReadOnly = True
    end
    object Label10: TUniLabel
      Left = 235
      Top = 20
      Width = 54
      Height = 12
      Hint = ''
      Caption = #32440#21345#21517#31216':'
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      TabOrder = 5
    end
    object EditCustomer: TUniEdit
      Left = 68
      Top = 51
      Width = 360
      Hint = ''
      Text = ''
      TabOrder = 6
      ReadOnly = True
    end
    object Grid1: TUniStringGrid
      Left = 8
      Top = 82
      Width = 420
      Height = 323
      Hint = ''
      ParentShowHint = False
      FixedCols = 0
      FixedRows = 0
      ColCount = 3
      Options = [goVertLine, goHorzLine, goEditing, goAlwaysShowEditor, goFixedColClick]
      ShowColumnTitles = True
      Columns = <
        item
          Title.Caption = #27700#27877#21517#31216
          Width = 174
        end
        item
          Title.Alignment = taCenter
          Title.Caption = #20215#26684#19979#38480
          Width = 80
        end
        item
          Title.Alignment = taCenter
          Title.Caption = #24403#21069#20215#26684
          Width = 80
        end
        item
          Title.Alignment = taCenter
          Title.Caption = #20215#26684#19978#38480
          Width = 80
        end>
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 7
      ParentFont = False
      Font.Charset = GB2312_CHARSET
      Font.Height = -12
      Font.Name = #23435#20307
      ExplicitWidth = 374
      ExplicitHeight = 306
    end
  end
end
