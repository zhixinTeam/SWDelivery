object Form1: TForm1
  Left = 289
  Top = 185
  Width = 928
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 920
    Height = 41
    Align = alTop
    TabOrder = 0
    object Button1: TButton
      Left = 210
      Top = 11
      Width = 75
      Height = 25
      Caption = 'print'
      TabOrder = 0
      OnClick = Button2Click
    end
    object CheckBox1: TCheckBox
      Left = 465
      Top = 15
      Width = 97
      Height = 17
      Caption = 'connected'
      TabOrder = 1
      OnClick = CheckBox1Click
    end
    object ComComboBox1: TComComboBox
      Left = 374
      Top = 14
      Width = 89
      Height = 20
      ComPort = ComPort1
      Style = csDropDownList
      ItemHeight = 12
      ItemIndex = -1
      TabOrder = 2
    end
    object Button2: TButton
      Left = 570
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Button2'
      TabOrder = 3
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 650
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Button3'
      TabOrder = 4
      OnClick = Button3Click
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 41
    Width = 920
    Height = 412
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Edit1: TEdit
    Left = 11
    Top = 13
    Width = 92
    Height = 23
    TabOrder = 2
    Text = '15689'
  end
  object Edit2: TEdit
    Left = 110
    Top = 13
    Width = 92
    Height = 23
    TabOrder = 3
    Text = 'zt001'
  end
  object ComPort1: TComPort
    BaudRate = br9600
    Port = 'COM17'
    Parity.Bits = prNone
    StopBits = sbTwoStopBits
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    Timeouts.ReadTotalMultiplier = 20
    Timeouts.ReadTotalConstant = 2000
    OnRxBuf = ComPort1RxBuf
    Left = 646
    Top = 66
  end
  object IdTCPClient1: TIdTCPClient
    ConnectTimeout = 0
    Host = '192.168.130.93'
    IPVersion = Id_IPv4
    Port = 8000
    ReadTimeout = -1
    Left = 550
    Top = 116
  end
  object TcpClient1: TTcpClient
    BlockMode = bmNonBlocking
    RemoteHost = '192.168.130.93'
    RemotePort = '8000'
    OnReceive = TcpClient1Receive
    Left = 146
    Top = 124
  end
end
