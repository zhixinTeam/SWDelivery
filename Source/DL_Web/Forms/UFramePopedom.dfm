object fFramePopedom: TfFramePopedom
  Left = 0
  Top = 0
  Width = 814
  Height = 590
  OnCreate = UniFrameCreate
  OnDestroy = UniFrameDestroy
  TabOrder = 0
  AutoScroll = True
  object PanelWork: TUniContainerPanel
    Left = 0
    Top = 0
    Width = 814
    Height = 590
    Hint = ''
    ParentColor = False
    Align = alClient
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object UniToolBar1: TUniToolBar
      Left = 0
      Top = 0
      Width = 814
      Height = 46
      Hint = ''
      ButtonHeight = 42
      ButtonWidth = 87
      Images = UniMainModule.ImageListBar
      ShowCaptions = True
      Anchors = [akLeft, akTop, akRight]
      Align = alTop
      TabOrder = 1
      ParentColor = False
      Color = clBtnFace
      object BtnAdd: TUniToolButton
        Left = 0
        Top = 0
        Hint = ''
        ImageIndex = 0
        Caption = #28155#21152#32452
        TabOrder = 1
        OnClick = BtnAddClick
      end
      object BtnEdit: TUniToolButton
        Left = 87
        Top = 0
        Hint = ''
        ImageIndex = 1
        Caption = #20462#25913#32452
        TabOrder = 2
        OnClick = BtnEditClick
      end
      object BtnDel: TUniToolButton
        Left = 174
        Top = 0
        Hint = ''
        ImageIndex = 2
        Caption = #21024#38500#32452
        TabOrder = 3
        OnClick = BtnDelClick
      end
      object UniToolButton4: TUniToolButton
        Left = 261
        Top = 0
        Width = 8
        Hint = ''
        Style = tbsSeparator
        Caption = 'UniToolButton4'
        TabOrder = 4
      end
      object BtnAddUser: TUniToolButton
        Left = 269
        Top = 0
        Hint = ''
        ImageIndex = 0
        Caption = #28155#21152#29992#25143
        ScreenMask.Message = #27491#22312#35835#21462
        ScreenMask.Target = PanelWork
        TabOrder = 5
        OnClick = BtnAddUserClick
      end
      object BtnEditUser: TUniToolButton
        Left = 356
        Top = 0
        Hint = ''
        ImageIndex = 1
        Caption = #20462#25913#29992#25143
        TabOrder = 6
        OnClick = BtnEditUserClick
      end
      object BtnDelUser: TUniToolButton
        Left = 443
        Top = 0
        Hint = ''
        ImageIndex = 2
        Caption = #21024#38500#29992#25143
        TabOrder = 7
        OnClick = BtnDelUserClick
      end
      object UniToolButton11: TUniToolButton
        Left = 530
        Top = 0
        Width = 8
        Hint = ''
        Style = tbsSeparator
        Caption = 'UniToolButton11'
        TabOrder = 9
      end
      object BtnApply: TUniToolButton
        Left = 538
        Top = 0
        Width = 87
        Hint = ''
        ImageIndex = 8
        Style = tbsDropDown
        DropdownMenu = PMenu2
        Caption = #25480#26435
        TabOrder = 8
        OnClick = BtnApplyClick
        ExplicitLeft = 536
        ExplicitTop = -2
      end
      object BtnExit: TUniToolButton
        Left = 625
        Top = 0
        Hint = ''
        ImageIndex = 7
        Caption = #36864#20986
        TabOrder = 10
        OnClick = BtnExitClick
        ExplicitLeft = 631
        ExplicitTop = -2
      end
    end
    object UniSplitter1: TUniSplitter
      Left = 256
      Top = 46
      Width = 6
      Height = 544
      Hint = ''
      Align = alLeft
      ParentColor = False
      Color = clBtnFace
    end
    object UniSimplePanel1: TUniSimplePanel
      Left = 262
      Top = 46
      Width = 552
      Height = 544
      Hint = ''
      ParentColor = False
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 3
      object Grid1: TUniStringGrid
        Left = 0
        Top = 0
        Width = 552
        Height = 544
        Hint = ''
        Options = [goVertLine, goHorzLine]
        ShowColumnTitles = True
        Columns = <>
        OnClick = Grid1Click
        OnMouseDown = Grid1MouseDown
        Align = alClient
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 1
      end
    end
    object UniSimplePanel2: TUniSimplePanel
      Left = 0
      Top = 46
      Width = 256
      Height = 544
      Hint = ''
      ParentColor = False
      Align = alLeft
      Anchors = [akLeft, akTop, akBottom]
      TabOrder = 4
      object TreeGroup: TUniTreeView
        Left = 0
        Top = 24
        Width = 256
        Height = 520
        Hint = ''
        Items.FontData = {0100000000}
        AutoExpand = True
        Align = alClient
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 1
        Color = clWindow
        OnClick = TreeGroupClick
      end
      object LabelHint: TUniLabel
        Left = 0
        Top = 0
        Width = 256
        Height = 24
        Hint = ''
        Alignment = taCenter
        AutoSize = False
        Caption = 'title'
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
      end
    end
  end
  object PMenu1: TUniPopupMenu
    Left = 56
    Top = 120
    object N1: TUniMenuItem
      Tag = 10
      Caption = #20840#37096#36873#20013
      OnClick = N1Click
    end
    object N2: TUniMenuItem
      Tag = 20
      Caption = #20840#37096#21462#28040
      OnClick = N1Click
    end
    object N3: TUniMenuItem
      Tag = 30
      Caption = #20840#37096#21453#36873
      OnClick = N1Click
    end
    object N4: TUniMenuItem
      Caption = '-'
    end
    object N5: TUniMenuItem
      Tag = 10
      Caption = #21015#20840#37096#36873#20013
      OnClick = N5Click
    end
    object N6: TUniMenuItem
      Tag = 20
      Caption = #21015#20840#37096#21462#28040
      OnClick = N5Click
    end
    object N7: TUniMenuItem
      Tag = 30
      Caption = #21015#20840#37096#21453#36873
      OnClick = N5Click
    end
  end
  object PMenu2: TUniPopupMenu
    Left = 104
    Top = 120
    object N8: TUniMenuItem
      Caption = #31435#21363#29983#25928
      OnClick = N8Click
    end
  end
end
