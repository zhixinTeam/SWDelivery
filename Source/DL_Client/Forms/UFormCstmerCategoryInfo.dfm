object TfFormCstmerCategoryInfo: TTfFormCstmerCategoryInfo
  Left = 606
  Top = 268
  BorderStyle = bsDialog
  Caption = #23458#25143#31867#21035#35774#32622
  ClientHeight = 383
  ClientWidth = 572
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayout1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 572
    Height = 383
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object lbl1: TLabel
      Left = 266
      Top = 63
      Width = 283
      Height = 12
      AutoSize = False
      Caption = '       '
      Color = clWindow
      ParentColor = False
    end
    object InfoTv1: TcxTreeView
      Left = 23
      Top = 36
      Width = 138
      Height = 273
      Hint = #28857#20987#31354#30333#21306#22495#12289#21487#21462#28040#36873#25321#29238#33410#28857
      Align = alClient
      DragMode = dmAutomatic
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
      OnClick = InfoTv1Click
      OnDblClick = InfoTv1DblClick
      HideSelection = False
      Images = FDM.ImageBar
      ReadOnly = True
      OnChange = InfoTv1Change
    end
    object EditText: TcxTextEdit
      Left = 324
      Top = 105
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 5
      Width = 121
    end
    object EditMemo: TcxMemo
      Left = 324
      Top = 130
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 6
      Height = 62
      Width = 225
    end
    object BtnAdd: TButton
      Left = 353
      Top = 36
      Width = 62
      Height = 22
      Caption = #28155#21152
      TabOrder = 1
      OnClick = BtnAddClick
    end
    object BtnDel: TButton
      Left = 420
      Top = 36
      Width = 62
      Height = 22
      Caption = #21024#38500
      TabOrder = 2
      OnClick = BtnDelClick
    end
    object BtnSave: TButton
      Left = 487
      Top = 36
      Width = 62
      Height = 22
      Caption = #20445#23384
      TabOrder = 3
      OnClick = BtnSaveClick
    end
    object Edt_Mark: TcxTextEdit
      Left = 324
      Top = 80
      TabStop = False
      ParentFont = False
      Properties.MaxLength = 25
      TabOrder = 4
      Width = 225
    end
    object dxLayoutGroup1: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      object dxLayoutGroup2: TdxLayoutGroup
        AutoAligns = [aaVertical]
        AlignHorz = ahClient
        Caption = #31867#21035#20998#31867
        object dxLayoutItem1: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #26641#29366#21015#34920
          ShowCaption = False
          Control = InfoTv1
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayout1Group3: TdxLayoutGroup
        AutoAligns = []
        AlignHorz = ahRight
        AlignVert = avClient
        Caption = #32534#36753#20449#24687
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item7: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            Caption = 'Button1'
            ShowCaption = False
            Control = BtnAdd
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            Caption = 'Button2'
            ShowCaption = False
            Control = BtnDel
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            Caption = 'Button3'
            ShowCaption = False
            Control = BtnSave
            ControlOptions.ShowBorder = False
          end
        end
        object dxlytmLayout1Item1: TdxLayoutItem
          Control = lbl1
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #31867#21035#26631#35782':'
          Control = Edt_Mark
          ControlOptions.FixedSize = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #31867#21035#21517#31216':'
          Control = EditText
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
