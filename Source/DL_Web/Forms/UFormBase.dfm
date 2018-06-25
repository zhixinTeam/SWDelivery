object fFormBase: TfFormBase
  Left = 0
  Top = 0
  ClientHeight = 170
  ClientWidth = 302
  Caption = ''
  BorderStyle = bsSingle
  OldCreateOrder = False
  BorderIcons = [biSystemMenu]
  MonitoredKeys.Keys = <>
  OnCreate = UniFormCreate
  OnDestroy = UniFormDestroy
  DesignSize = (
    302
    170)
  PixelsPerInch = 96
  TextHeight = 13
  object BtnOK: TUniButton
    Left = 136
    Top = 136
    Width = 75
    Height = 25
    Hint = ''
    Caption = #30830#23450
    Anchors = [akRight, akBottom]
    TabOrder = 0
    Default = True
    OnClick = BtnOKClick
  end
  object BtnExit: TUniButton
    Left = 219
    Top = 136
    Width = 75
    Height = 25
    Hint = ''
    Caption = #21462#28040
    Cancel = True
    ModalResult = 2
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  object PanelWork: TUniSimplePanel
    Left = 8
    Top = 8
    Width = 286
    Height = 120
    Hint = ''
    ParentColor = False
    Border = True
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
  end
end
