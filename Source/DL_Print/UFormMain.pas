{*******************************************************************************
  作者: dmzn@163.com 2012-4-21
  描述: 远程打印服务程序
*******************************************************************************}
unit UFormMain;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  IdContext, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, Printers,
  IdGlobal, UMgrRemotePrint, SyncObjs, UTrayIcon, StdCtrls, ExtCtrls,
  ComCtrls;

type
  TfFormMain = class(TForm)
    GroupBox1: TGroupBox;
    MemoLog: TMemo;
    StatusBar1: TStatusBar;
    CheckSrv: TCheckBox;
    EditPort: TLabeledEdit;
    IdTCPServer1: TIdTCPServer;
    CheckAuto: TCheckBox;
    CheckLoged: TCheckBox;
    Timer1: TTimer;
    BtnConn: TButton;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckSrvClick(Sender: TObject);
    procedure CheckLogedClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure BtnConnClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
  private
    { Private declarations }
    FTrayIcon: TTrayIcon;
    {*状态栏图标*}
    FIsBusy: Boolean;
    FBillList: TStrings;
    FSyncLock: TCriticalSection;
    //同步锁
    procedure ShowLog(const nStr: string);
    //显示日志
    procedure DoExecute(const nContext: TIdContext);
    //执行动作
    procedure PrintBill(var nBase: TRPDataBase;var nBuf: TIdBytes;nCtx: TIdContext);
    //打印单据
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}
uses
  IniFiles, Registry, ULibFun, UDataModule, UDataReport, USysLoger, UFormConn,
  DB, USysDB, UFormCtrl;

var
  gPath: string;               //程序路径

resourcestring
  sHint               = '提示';
  sConfig             = 'Config.Ini';
  sForm               = 'FormInfo.Ini';
  sDB                 = 'DBConn.Ini';
  sAutoStartKey       = 'RemotePrinter';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '打印服务主单元', nEvent);
end;

//------------------------------------------------------------------------------
procedure TfFormMain.FormCreate(Sender: TObject);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);
  
  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogEvent := ShowLog;

  FTrayIcon := TTrayIcon.Create(Self);
  FTrayIcon.Hint := Caption;
  FTrayIcon.Visible := True;

  FIsBusy := False;
  FBillList := TStringList.Create;
  FSyncLock := TCriticalSection.Create;
  //new item 

  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    EditPort.Text := nIni.ReadString('Config', 'Port', '8000');
    Timer1.Enabled := nIni.ReadBool('Config', 'Enabled', False);

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    CheckAuto.Checked := nReg.ValueExists(sAutoStartKey);
  finally
    nIni.Free;
    nReg.Free;
  end;

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //数据库连接
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    //nIni.WriteString('Config', 'Port', EditPort.Text);
    nIni.WriteBool('Config', 'Enabled', CheckSrv.Enabled);

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    if CheckAuto.Checked then
      nReg.WriteString(sAutoStartKey, Application.ExeName)
    else if nReg.ValueExists(sAutoStartKey) then
      nReg.DeleteValue(sAutoStartKey);
    //xxxxx
  finally
    nIni.Free;
    nReg.Free;
  end;

  FBillList.Free;
  FSyncLock.Free;
  //lock
end;

procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  CheckSrv.Checked := True;
end;

procedure TfFormMain.CheckSrvClick(Sender: TObject);
begin
  if not IdTCPServer1.Active then
    IdTCPServer1.DefaultPort := StrToInt(EditPort.Text);
  IdTCPServer1.Active := CheckSrv.Checked;

  BtnConn.Enabled := not CheckSrv.Checked;
  EditPort.Enabled := not CheckSrv.Checked;

  FSyncLock.Enter;
  try
    FBillList.Clear;
    Timer2.Enabled := CheckSrv.Checked;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TfFormMain.CheckLogedClick(Sender: TObject);
begin
  gSysLoger.LogSync := CheckLoged.Checked;
end;

procedure TfFormMain.ShowLog(const nStr: string);
var nIdx: Integer;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Insert(0, nStr);
    if MemoLog.Lines.Count > 100 then
     for nIdx:=MemoLog.Lines.Count - 1 downto 50 do
      MemoLog.Lines.Delete(nIdx);
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

//Desc: 测试nConnStr是否有效
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

//Desc: 数据库配置
procedure TfFormMain.BtnConnClick(Sender: TObject);
begin
  if ShowConnectDBSetupForm(ConnCallBack) then
  begin
    FDM.ADOConn.Close;
    FDM.ADOConn.ConnectionString := BuildConnectDBStr;
    //数据库连接
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormMain.IdTCPServer1Execute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
      AContext.Connection.Socket.InputBuffer.Clear;
    end;
  end;
end;

procedure TfFormMain.DoExecute(const nContext: TIdContext);
var nBuf: TIdBytes;
    nBase: TRPDataBase;
begin
  with nContext.Connection do
  begin
    Socket.ReadBytes(nBuf, cSizeRPBase, False);
    BytesToRaw(nBuf, nBase, cSizeRPBase);

    case nBase.FCommand of
     cRPCmd_PrintBill :
      begin
        PrintBill(nBase, nBuf, nContext);
        //print
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-1
//Parm: 交货单号;提示;数据对象;打印机
//Desc: 打印nBill交货单号
function UPDateBillPrinterNum(const nPrinter: string): Boolean;
var nStr: string;
begin
  nStr := ' UPDate Sys_PrintTotle Set P_CurrNum=P_CurrNum+1 Where P_PrinterName='''+nPrinter+'''';
  FDM.ExecuteSQL(nStr);
end;

//Date: 2012-4-1
//Parm: 交货单号;提示;数据对象;打印机
//Desc: 打印nBill交货单号
function PrintBillReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''; const nMoney: string = '0'; const nPrintStd: Boolean = False): Boolean;
var nStr: string;
    nDS: TDataSet;
begin
  nHint := '';
  Result := False;

  if not nPrintStd then
  begin
    nStr := 'Select *,%s As L_ValidMoney, (Case When L_PrintNum>0 then ''补'' else '''' end) AS IsBuDan '+
            'From %s Left Join Sys_PoundLog on P_Bill=L_ID Where L_ID=''%s''';
    {$IFDEF SetStdValue}
    nStr := nStr + ' Union ' + 
              ' Select S_Bill.R_ID, L_ID, L_Card, L_ZhiKa, L_Order, L_Project, L_Area, L_CusID, L_CusName,L_CusPY,L_SaleID,L_SaleMan,L_Type,L_StockNo,L_StockName,  ' +
              ' L_StdValue AS L_Value,L_Price,L_ZKMoney,L_YunFei,L_Truck,L_Status,L_NextStatus,L_InTime,L_InMan,L_PValue,L_PDate,L_PMan, L_StdValue+L_PValue  L_MValue, ' +
              ' L_MDate,L_MMan,L_LadeTime,L_LadeMan,L_LadeLine,L_LineName,L_DaiTotal,L_DaiNormal,L_DaiBuCha,L_OutFact,L_OutMan,L_PrintGLF,L_Lading,L_IsVIP,L_Seal,L_HYDan, ' +
              ' L_PrintHY,L_Audit,L_Man,L_Date,L_EmptyOut,L_DelMan,L_DelDate,L_ICCardNo,L_SnapTruck,L_SendFactory,L_IsSample,L_StdValue, Sys_PoundLog.*,%s As L_ValidMoney ' +
              ', (Case When L_PrintNum>0 then ''补'' else '''' end) AS IsBuDan ' +
              ' From S_Bill Left Join Sys_PoundLog on P_Bill=L_ID Where L_ID=''%s'' And L_StdValue>0  ';
    {$ENDIF}

    nStr := Format(nStr, [nMoney, sTable_Bill, nBill, nMoney, nBill]);
                                                      //
    nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
  end
  else
  begin
    nStr := ' Select S_Bill.R_ID, L_ID, L_Card, L_ZhiKa, L_Order, L_Project, L_Area, L_CusID, L_CusName,L_CusPY,L_SaleID,L_SaleMan,L_Type,L_StockNo,L_StockName,  ' +
              ' L_StdValue AS L_Value,L_Price,L_ZKMoney,L_YunFei,L_Truck,L_Status,L_NextStatus,L_InTime,L_InMan,L_PValue,L_PDate,L_PMan, L_StdValue+L_PValue  L_MValue, ' +
              ' L_MDate,L_MMan,L_LadeTime,L_LadeMan,L_LadeLine,L_LineName,L_DaiTotal,L_DaiNormal,L_DaiBuCha,L_OutFact,L_OutMan,L_PrintGLF,L_Lading,L_IsVIP,L_Seal,L_HYDan, ' +
              ' L_PrintHY,L_Audit,L_Man,L_Date,L_EmptyOut,L_DelMan,L_DelDate,L_ICCardNo,L_SnapTruck,L_SendFactory,L_IsSample,L_StdValue, Sys_PoundLog.*,%s As L_ValidMoney ' +
              ', (Case When L_PrintNum>0 then ''补'' else '''' end) AS IsBuDan ' +
              ' From S_Bill Left Join Sys_PoundLog on P_Bill=L_ID Where L_ID=''%s'' And L_StdValue>0  ';
    nStr := Format(nStr, [nMoney, nBill]);

    nDS := FDM.SQLQuery(nStr, FDM.Qry_1);
  end;
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nHint := '交货单[ %s ] 已无效!!';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

  nStr := gPath + 'Report\LadingBill.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件';
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  {$IFDEF SetStdValue}
  if nPrintStd then
    FDR.Dataset1.DataSet := FDM.Qry_1;
  {$ENDIF}
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
  if Result then UPDateBillPrinterNum(nPrinter);

  {$IFDEF PrintGLF}
  if nDS.FieldByName('L_PrintGLF').AsString <> 'Y' then Exit;

  nStr := gPath + 'Report\BillLoad.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件: ' + nStr;
    Exit;
  end;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  {$ENDIF}
end;

//Date: 2012-4-1
//Parm: 采购单号;提示;数据对象;打印机
//Desc: 打印nOrder采购单号
function PrintOrderReport(const nOrder: string; var nHint: string;
 const nPrinter: string = ''; const nMoney: string = '0'): Boolean;
var nStr: string;
    nDS: TDataSet;
begin
  nHint := '';
  Result := False;
  
  nStr := 'Select *,(Case when D_PrintNum>0 THEN ''补'' ELSE '''' END) AS IsBuDan '+
          'From %s oo Inner Join %s od on oo.O_ID=od.D_OID Where D_ID=''%s''';
  nStr := Format(nStr, [sTable_Order, sTable_OrderDtl, nOrder]);

  nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nHint := '采购单 %s 已无效!!';
    nHint := Format(nHint, [nOrder]);
    Exit;
  end;

  nStr := gPath + 'Report\PurchaseOrder.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件: ' + nStr;
    Exit;
  end;
  
  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

function PrintDuanDaoOrderReport(const nOrder: string; var nHint: string;
 const nPrinter: string = ''; const nMoney: string = '0'): Boolean;
var nStr: string;
    nDS: TDataSet;
begin
  nHint := '';
  Result := False;

  nStr := ' Select B_Id, a.T_ID ,B_SrcAddr+B_DestAddr KHName, a.T_StockName, c.T_PValue, c.T_MValue, '+
          '      c.T_Value, a.T_InTime, a.T_OutFact, a.T_Truck '+
          ' From %s a                                '+
          ' Left Join %s b On B_ID=a.T_PID           '+
          ' Left Join %s  c On B_ID=c.T_PID          '+
          ' Where B_IsNei=''N'' And c.T_ID=''%s''';

  nStr := Format(nStr, [sTable_TransferSW, sTable_TransBase, sTable_Transfer, nOrder]);

  nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nHint := '短倒单[ %s  已无效!!';
    nHint := Format(nHint, [nOrder]);
    Exit;
  end;

  nStr := gPath + 'Report\DuanDaoOrder.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件: ' + nStr;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 获取nStock品种的报表文件
function GetReportFileByStock(const nStock: string): string;
begin
  Result := GetPinYinOfStr(nStock);

  if Pos('dj', Result) > 0 then
    Result := gPath + 'Report\HuaYan42_DJ.fr3'
  else if Pos('gsysl', Result) > 0 then
    Result := gPath + 'Report\HuaYan_gsl.fr3'
  else if Pos('kzf', Result) > 0 then
    Result := gPath + 'Report\HuaYan_kzf.fr3'
  else if Pos('qz', Result) > 0 then
    Result := gPath + 'Report\HuaYan_qz.fr3'
  else if Pos('32', Result) > 0 then
    Result := gPath + 'Report\HuaYan32.fr3'
  else if Pos('42', Result) > 0 then
    Result := gPath + 'Report\HuaYan42.fr3'
  else if Pos('52', Result) > 0 then
    Result := gPath + 'Report\HuaYan42.fr3'

  else if Pos('dlsn', Result) > 0 then
    Result := gPath + 'Report\HuaYan_DaoLu.fr3'
  else if Pos('zrsn', Result) > 0 then
    Result := gPath + 'Report\HuaYan_ZhongRe.fr3'
  else Result := '';
end;

//Desc: 打印标识为nHID的化验单
function PrintHuaYanReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr,nSR: string;
begin
  nHint := '';
  Result := False;

  {$IFDEF ChkPopedomPrintHYD}
  nStr:= 'Select L_ID, L_CusName, C_InstantPrintHYD From $Bill '+
         'Left   Join $Customer On L_CusID=C_ID '+
         'Where  L_ID=''$ID'' And C_InstantPrintHYD=''Y''';

  nStr:= MacroValue(nStr, [MI('$Bill', sTable_Bill),
          MI('$Customer', sTable_Customer), MI('$ID', nBill)]);
  //xxxxx

  if FDM.SQLQuery(nStr, FDM.SqlTemp).RecordCount < 1 then
  begin
    nHint := '提货单[ %s ]没有提前随车打印化验单的特权';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;
  {$ENDIF}
  //****************************************************************************
  nSR := 'Select * From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,C_Name,(case when H_PrintNum>0 THEN ''补'' ELSE '''' END) AS IsBuDan From $HY hy ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_Reporter=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nBill)]);
  //xxxxx

  if FDM.SQLQuery(nStr, FDM.SqlTemp).RecordCount < 1 then
  begin
    nHint := '提货单[ %s ]没有对应的化验单';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

  nStr := FDM.SqlTemp.FieldByName('P_Stock').AsString;
  nStr := GetReportFileByStock(nStr);

  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件: ' + nStr;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 打印标识为nID的合格证
function PrintHeGeReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr,nSR, nBatchNO, nStockNo, nStockName: string;
    nField: TField;
begin
  nHint := '';
  Result := False;

  //*******************  出厂不需要打印合格证
  nSR := ' Select * From %s Where L_ID=''%s''  ';
  nSR := Format(nSR, [sTable_Bill, nBill]);
  with FDM.QuerySQL(nSR) do
  begin
    if RecordCount >0 then
    begin
      nStockNo  := FieldByName('L_StockNo').AsString;
      nStockName:= FieldByName('L_StockName').AsString;
    end;
  end;

  nSR := ' Select * From %s Where D_Name=''NoPrintHGZ'' And D_ParamB=''%s''  ';
  nSR := Format(nSR, [sTable_SysDict, nStockNo]);
  with FDM.QuerySQL(nSR) do
  begin
    if RecordCount >0 then
    begin
      WriteLog(Format('%s 无需打印合格证: %s', [nStockName, nBill]));
      Exit;
    end;
  end;


  {$IFDEF HeGeZhengSimpleData}
//  nSR  := 'Select * from %s b ' +
//          ' Left Join %s sp On sp.P_Stock=b.L_StockName ' +
//          'Where b.L_ID=''%s'' And b.L_HYDan=''%s'' ';
//  nStr := Format(nSR, [sTable_Bill, sTable_StockParam, nBill, nBatchNO);
  nSR  := 'Select * From  %s  Where L_ID=''%s''  ';
  nStr := Format(nSR, [sTable_Bill, nBill]);
  {$ELSE}
  nSR := 'Select R_SerialNo,P_Stock,P_Name,P_QLevel From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam);

  nStr := 'Select hy.*,sr.*,C_Name From $HY hy ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_Reporter=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nBill));
  //xxxxx
  {$ENDIF}

  if FDM.SQLQuery(nStr, FDM.SqlTemp).RecordCount < 1 then
  begin
    nHint := '提货单[ %s 没有对应的合格证';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

//  with FDM.SqlTemp do
//  begin
//    nField := FindField('L_PrintHY');
//    if Assigned(nField) and (nField.AsString <> sFlag_Yes) then
//    begin
//      nHint := '交货单[ %s 无需打印合格证.';
//      nHint := Format(nHint, [nBill);
//      Exit;
//    end;
//  end;

  nStr := gPath + 'Report\HeGeZheng.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件: ' + nStr;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := nPrinter;
  
  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//------------------------------------------------------------------------------
//Desc: 打印单据
procedure TfFormMain.PrintBill(var nBase: TRPDataBase; var nBuf: TIdBytes;
  nCtx: TIdContext);
var nStr: WideString;
begin
  nCtx.Connection.Socket.ReadBytes(nBuf, nBase.FDataLen, False);
  nStr := Trim(BytesToString(nBuf));

  FSyncLock.Enter;
  try
    FBillList.Add(nStr);
  finally
    FSyncLock.Leave;
  end;

  WriteLog(Format('添加打印交货单: %s', [nStr]));
  //loged
end;

procedure TfFormMain.Timer2Timer(Sender: TObject);
var nPos: Integer;
    nBill,nHint,nPrinter,nHYPrinter,nMoney, nType: string;
begin
  if not FIsBusy then
  begin
    FSyncLock.Enter;
    try
      if FBillList.Count < 1 then Exit;
      nBill := FBillList[0];
      FBillList.Delete(0);
    finally
      FSyncLock.Leave;
    end;

    //bill #9 printer #8 money #7 CardType #6 HYPrinter
    nPos := Pos(#6, nBill);
    if nPos > 1 then
    begin
      nHYPrinter := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nHYPrinter, 1, nPos);
    end else nHYPrinter := '';

    nPos := Pos(#7, nBill);
    if nPos > 1 then
    begin
      nType := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nType, 1, nPos);
    end else nType := '';

    nPos := Pos(#8, nBill);
    if nPos > 1 then
    begin
      nMoney := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nMoney, 1, nPos);

      if not IsNumber(nMoney, True) then
        nMoney := '0';
      //xxxxx
    end else nMoney := '0';

    nPos := Pos(#9, nBill);
    if nPos > 1 then
    begin
      nPrinter := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nPrinter, 1, nPos);
    end else nPrinter := '';

    WriteLog('开始打印: ' + nBill);
    try
      FIsBusy := True;
      //set flag
      
      if nType = 'P' then
      begin
        PrintOrderReport(nBill, nHint, nPrinter);
        if nHint <> '' then WriteLog(nHint);
      end else
      if nType = 'D' then
      begin
        PrintDuanDaoOrderReport(nBill, nHint, nPrinter);
        if nHint <> '' then WriteLog(nHint);
      end else
      begin
        PrintBillReport(nBill, nHint, nPrinter, nMoney);
        if nHint <> '' then WriteLog(nHint);
        {$IFDEF SetStdValue}
        //Sleep(500);
        //PrintBillReport(nBill, nHint, nPrinter, nMoney, True);
        //if nHint <> '' then WriteLog(nHint);
        {$ENDIF}


        {$IFDEF PrintHuaYanDan}
        PrintHuaYanReport(nBill, nHint, nHYPrinter);
        if nHint <> '' then WriteLog(nHint);
        {$ENDIF}

        {$IFDEF PrintHeGeZheng}
        PrintHeGeReport(nBill, nHint, nHYPrinter);
        if nHint <> '' then WriteLog(nHint);
        {$ENDIF}
      end;
    except
      on E: Exception do
        WriteLog(E.Message);
      //xxxxx
    end;

    FIsBusy := False;
    WriteLog('打印结束.');
  end;
end;

procedure TfFormMain.GroupBox1Click(Sender: TObject);
var nn:string;
begin
  //PrintBillReport('TH180929026', nn, '', '');
  //PrintBillReport('TH180929026', nn, '', '', True);
end;

end.
