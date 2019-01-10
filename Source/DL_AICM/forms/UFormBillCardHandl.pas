unit UFormBillCardHandl;

interface

{$I Link.Inc}
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, dxSkinsCore, dxSkinsDefaultPainters, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, StdCtrls, Grids, DBGrids, DB, USysBusiness,
  ADODB, DBClient, Provider, Buttons;

type
  TFormBillCardHandl = class(TForm)
    dbgrd1: TDBGrid;
    edt1: TEdit;
    lbl1: TLabel;
    btn1: TButton;
    lbl2: TLabel;
    lbl3: TLabel;
    cbb_ZK: TcxComboBox;
    lbl4: TLabel;
    cbb_Stocks: TcxComboBox;
    lbl5: TLabel;
    edt_Value: TcxTextEdit;
    lbl6: TLabel;
    btnOK: TButton;
    btnBtnExit: TButton;
    lbl7: TLabel;
    Ds_Mx1: TDataSource;
    lbl8: TLabel;
    lbl9: TLabel;
    Qry_1: TADOQuery;
    CltDs_1: TClientDataSet;
    dtstprvdr1: TDataSetProvider;
    lbl10: TLabel;
    cbb_TruckNo: TcxComboBox;
    procedure btnBtnExitClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure dbgrd1CellClick(Column: TColumn);
    procedure cbb_ZKPropertiesEditValueChanged(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cbb_StocksPropertiesEditValueChanged(Sender: TObject);
    procedure edt_ValueKeyPress(Sender: TObject; var Key: Char);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    nSuccCard : string;
    Fbegin    : TDateTime;
  private
    procedure SearchCusInfo(nName:string);
    procedure LoadCusZhiKa(nCusId:string);
    procedure LoadCusStocks(nZkId:string);
    function  VerifyCtrl(Sender: TObject; var nHint: string): Boolean;
    procedure Writelog(nMsg: string);
    function  IsCustomerHaveTruckNo(nTruck, nCid: string): Boolean;
    //检查车牌、客户匹配关系

    function  SaveBillProxy: Boolean;
  public
    { Public declarations }
    FNewLid   : string;
  public
    procedure SetControlsClear;
  end;

type
  TBillInfo = record
    FCusID   : string;
    FCusName : string;
    FZhiKaId : string;
    FOnlyMoney: Boolean;
    FIDList  : string;
    FCard    : string;
    FTruck   : string;
    FValue   : Double;
    FPrice   : Double;
    FMoney   : Double;
  end;


  TStockItem = record
    FType: string;
    FStockNO: string;
    FStockName: string;
    FStockSeal: string;
    FPrice: Double;
    FValue: Double;
    FYfPrice: Double;
    FSelecte: Boolean;
  end;

var
  FormBillCardHandl: TFormBillCardHandl;
  gStockList: array of TStockItem;
  gBill : TBillInfo;


implementation

uses UDataModule, USysDB, UAdjustForm, ULibFun, USysConst, USysLoger, UMgrK720Reader,UBusinessPacker,UBusinessConst,
      UFormMain,UFormBase,UDataReport,NativeXml,UFormWait,DateUtils;


{$R *.dfm}


procedure TFormBillCardHandl.SetControlsClear;
var
  i : Integer;
  nComp : TComponent;
begin
  edt1.Clear;         gSysParam.FUserID := 'AICM';
  edt_Value.Text:= '';
  cbb_TruckNo.ItemIndex:= 0;
  FNewLid:= '';                         lbl2.Caption:=''; lbl3.Caption:=''; lbl10.Caption:=''; 
  cbb_ZK.Properties.Items.Clear;
  cbb_Stocks.Properties.Items.Clear;

  Qry_1.DataSource.DataSet.Close;
end;

procedure TFormBillCardHandl.SearchCusInfo(nName:string);
var nStr: string;
begin
  cbb_ZK.Clear;    SetLength(gStockList, 0);    edt_Value.Text:= ''; lbl2.Caption:= '';  lbl3.Caption:= '';
  cbb_ZK.Properties.Items.Clear;
  nStr := ' Select * From S_Customer Where C_Name like ''%'+nName+'%'' OR C_PY like ''%'+nName+'%''';
  //扩展信息

  Qry_1.DataSource.DataSet:= FDM.QuerySQLx(nStr);

      edt_Value.Text:= '';  lbl10.Caption:= '';
      cbb_ZK.Properties.Items.Clear;
      cbb_Stocks.Properties.Items.Clear;
end;

procedure TFormBillCardHandl.btnBtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormBillCardHandl.btn1Click(Sender: TObject);
begin
  SearchCusInfo(Trim(edt1.Text));
end;

procedure TFormBillCardHandl.dbgrd1CellClick(Column: TColumn);
var nCId:string;
begin
  with Ds_Mx1.DataSet do
  begin
    if Active then
    if RecordCount>0 then
    begin
      edt_Value.Text:= '';  lbl10.Caption:= '';
      cbb_ZK.Properties.Items.Clear;
      cbb_Stocks.Properties.Items.Clear;

      lbl2.Caption:= FieldByName('C_ID').AsString;
      lbl3.Caption:= FieldByName('C_Name').AsString;

      gBill.FCusID:= FieldByName('C_ID').AsString;
      gBill.FCusName:= FieldByName('C_Name').AsString;
    end;
  end;

  LoadCusZhiKa(gBill.FCusID);
end;

procedure TFormBillCardHandl.LoadCusZhiKa(nCusId:string);
var nStr : string;
begin
  nStr := 'Z_ID=Select Z_ID, Z_Name From %s ' +
          'Where Z_Customer=''%s'' And Z_ValidDays>%s And ' +
          'IsNull(Z_InValid, '''')<>''%s'' And ' +
          'IsNull(Z_Freeze, '''')<>''%s'' Order By Z_ID';
  nStr := Format(nStr, [sTable_ZhiKa, nCusId, sField_SQLServer_Now, sFlag_Yes, sFlag_Yes]);

  with cbb_ZK.Properties do
  begin
    AdjustStringsItem(Items, True);
    FDM.FillStringsData(Items, nStr, 0, '.');
    AdjustStringsItem(Items, False);

    if Items.Count > 0 then
      cbb_ZK.ItemIndex := 0;

    cbb_ZK.DroppedDown:= True; 
  end;
end;

procedure TFormBillCardHandl.LoadCusStocks(nZkId:string);
var nStr : string;
    nIdx : Integer;
begin
  SetLength(gStockList, 0);
  cbb_Stocks.Properties.Items.Clear;
  nStr := 'Select * From %s Where D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, nZkId]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nStr := '';
    nIdx := 0;
    SetLength(gStockList, RecordCount);

    First;  
    while not Eof do
    with gStockList[nIdx] do
    begin
      FType := FieldByName('D_Type').AsString;
      FStockNO := FieldByName('D_StockNo').AsString;
      FStockName := FieldByName('D_StockName').AsString;
      FPrice := FieldByName('D_Price').AsFloat;
      FYfPrice := FieldByName('D_YunFei').AsFloat;

      FValue := 0;
      FSelecte := False;

      cbb_Stocks.Properties.Items.Add(gStockList[nIdx].FStockName);

      Inc(nIdx);
      Next;
    end;

    cbb_Stocks.ItemIndex:= 0;
    cbb_Stocks.DroppedDown:= True;
  end
end;

procedure TFormBillCardHandl.cbb_ZKPropertiesEditValueChanged(
  Sender: TObject);
begin
  if cbb_ZK.ItemIndex < 0 then Exit;
  edt_Value.Text:= '';
  LoadCusStocks(GetCtrlData(cbb_ZK));
end;

procedure TFormBillCardHandl.Writelog(nMsg: string);
begin
  gSysLoger.AddLog(nMsg);
end;

function TFormBillCardHandl.VerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = cbb_TruckNo then
  begin
    Result := Length(cbb_TruckNo.Text) > 5;
    if not Result then
    begin
      nHint := '车牌号长度应大于2位';
      Writelog(nHint);
      Exit;
    end;
  end;
  if Sender = edt_Value then
  begin
    Result := IsNumber(edt_Value.Text, True) and (StrToFloat(edt_Value.Text)>0);
    if not Result then
    begin
      nHint := '请填写有效的办理量';
      Writelog(nHint);
      Exit;
    end;
  end;
end;

function TFormBillCardHandl.IsCustomerHaveTruckNo(nTruck, nCid: string): Boolean;
var nStr : string;
begin
  Result:= False;
  //*************
  nStr := 'Select * From %s Where T_Truck=''%s'' And T_CID=''%s''';
  nStr := Format(nStr, [sTable_TruckCus, nTruck, nCid]);

  with FDM.QuerySQLChk(nStr) do
    Result:= (RecordCount>0)
end;

procedure TFormBillCardHandl.btnOKClick(Sender: TObject);
begin
  BtnOK.Enabled := False;
  try
    gBill.FZhiKaId:= GetCtrlData(cbb_ZK);
    gBill.FValue:= StrToFloatDef(Trim(edt_Value.Text), 0);
    gBill.FTruck:= Trim(cbb_TruckNo.Text);

    if (gBill.FValue<=0)or(gBill.FTruck='')or(cbb_Stocks.ItemIndex<0) then
    begin
      ShowMsg('请录入开单数量、车牌号及水泥品种', sHint);
      Exit;
    end;
    if Not IsCustomerHaveTruckNo(gBill.FTruck, gBill.FCusID) then
    begin
      ShowMsg('请录入正确的车牌号码', sHint);
      Exit;
    end;
    if not SaveBillProxy then Exit;
    nSuccCard:= '' ;
    Close;
  finally
    BtnOK.Enabled := True;            //PrintBillRt('TH181021311', False);
  end;
end;

function TFormBillCardHandl.SaveBillProxy: Boolean;
var
  nHint:string;
  nList,nTmp,nStocks: TStrings;
  nPrint,nInFact:Boolean;
  nBillData, nFact, nBillID:string;
  nNewCardNo, nLid:string;
  i, nidx:Integer;
  nRet: Boolean;
var nInt: Int64;
begin
  Result := False;  nLid:= '';
                                    
  if (not VerifyCtrl(cbb_TruckNo, nHint)) or
      (not VerifyCtrl(edt_Value, nHint)) then
  begin
    ShowMsg(nHint, sHint);
    Writelog(nHint);
    Exit;
  end;

  with gStockList[cbb_Stocks.ItemIndex] do
  begin
    if FPrice=0 then
    begin
      ShowMsg('获取物料价格异常！请联系工作人员',sHint);
      Writelog('获取物料价格异常！请联系工作人员');
      Exit;
    end;

    if FPrice > 0 then
    begin
      nInt := Float2PInt(gBill.FMoney / FPrice, cPrecision, False);
      if (nInt/cPrecision)<gBill.FValue then
      begin
        ShowMsg('当前资金最大开单量为：'+FloatToStr(nInt/cPrecision)+' 吨、请调整数量',sHint);
        Exit;
      end;
    end;

    gBill.FPrice:= FPrice;
  end;

  nNewCardNo := '';
  Fbegin := Now;

  try
    //连续三次读卡均失败，则回收卡片，重新发卡
    for i := 0 to 3 do
    begin
        for nIdx:=0 to 3 do
        begin
          if gMgrK720Reader.ReadCard(nNewCardNo) then Break;
          //连续三次读卡,成功则退出。
        end;
        if nNewCardNo<>'' then Break;
        gMgrK720Reader.RecycleCard;
    end;

    if nNewCardNo = '' then
    begin
        ShowDlg('卡箱异常,请查看是否有卡.', sWarn, Self.Handle);
        Exit;
    end;
  except on Ex:Exception do
      begin
        WriteLog('卡箱异常 '+Ex.Message);
        ShowDlg('卡箱异常, 请联系管理人员.', sWarn, Self.Handle);
      end;
  end;
  nNewCardNo := gMgrK720Reader.ParseCardNO(nNewCardNo);
  WriteLog(nNewCardNo);
  //解析卡片
  WriteLog('TfFormNewCard.SaveBillProxy 发卡机读卡-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');


  if FNewLid='' then
  begin
    //保存提货单
    nStocks := TStringList.Create;
    nList := TStringList.Create;
    nTmp := TStringList.Create;
    try
      LoadSysDictItem(sFlag_PrintBill, nStocks);

      nTmp.Values['Type'] := gStockList[cbb_Stocks.ItemIndex].FType;

      nTmp.Values['StockNO'] := gStockList[cbb_Stocks.ItemIndex].FStockNO;
      nTmp.Values['StockName'] := gStockList[cbb_Stocks.ItemIndex].FStockName;
      nTmp.Values['Price'] := FloatToStr(gBill.FPrice);
      nTmp.Values['YunFeiPrice'] := FloatToStr(gStockList[cbb_Stocks.ItemIndex].FYfPrice);
      nTmp.Values['Value'] := FloatToStr(gBill.FValue);

      nTmp.Values['PrintHY'] := sFlag_No;
      //****************
      nList.Add(PackerEncodeStr(nTmp.Text));

      with nList do
      begin
        Values['Bills'] := PackerEncodeStr(nList.Text);
        Values['ZhiKa'] := gBill.FZhiKaId;
        Values['Truck'] := gBill.FTruck;
        Values['Lading'] := sFlag_TiHuo;
        Values['Memo']  := EmptyStr;
        Values['IsVIP'] := 'C';
        Values['Seal']  := '';
        Values['HYDan'] := '';
      end;
      Writelog('单据内容：'+nList.Text);
      nBillData := PackerEncodeStr(nList.Text);
      FBegin := Now;
      nBillID := SaveBill(nBillData);
      if nBillID = '' then Exit;
      Writelog('TfFormNewCard.SaveBillProxy 生成提货单['+nBillID+']-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
      FBegin := Now;
      Writelog('TfFormNewCard.SaveBillProxy 保存商城订单号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    finally
      nStocks.Free;
      nList.Free;
      nTmp.Free;
    end;

    ShowMsg('提货单保存成功', sHint);
  end
  else nBillID:= FNewLid;

  if (nBillID = '') or (nNewCardNo = '') then
  begin
    Writelog('生成提货单失败、请到柜台开单');
    Exit;
  end;

  FBegin := Now;
  nRet := SaveBillCard(nBillID,nNewCardNo);
  if nRet then
  begin
    nRet := False;
    for nIdx := 0 to 3 do
    begin
      nRet := gMgrK720Reader.SendReaderCmd('FC0');
      if nRet then Break;
    end;
    //发卡
  end;
  if nRet then
  begin
    nHint := '自助申请发卡成功,卡号['+nNewCardNo+'],请收好您的卡片';
    WriteLog(nHint);
    ShowMsg(nHint,sWarn);
  end
  else begin
    gMgrK720Reader.RecycleCard;

    nHint := '自助申请卡号['+nNewCardNo+']关联订单失败，请到开票窗口重新关联。';
    WriteLog(nHint);
    ShowDlg(nHint,sHint,Self.Handle);
  end;
  writelog('TfFormNewCard.SaveBillProxy 发卡机出卡并关联磁卡号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');

  if nPrint then
    PrintBillReport(nBillID, True);           
  //print report
  {$IFDEF AICMPrintHGZ}
  PrintHeGeReport(nBillID, False);
  {$ENDIF}
  {$IFDEF SWTC}
  PrintBillRt(nBillID, False);
  // 声威开单小票
  {$ENDIF}

  if nRet then Close;
end;

procedure TFormBillCardHandl.cbb_StocksPropertiesEditValueChanged(
  Sender: TObject);
var nInt: Int64;
begin
  gBill.FZhiKaId:= GetCtrlData(cbb_ZK);
  IF gBill.FZhiKaId<>'' then
  begin
    if cbb_Stocks.ItemIndex<0 then Exit;
    gBill.FMoney := GetZhikaValidMoney(gBill.FZhiKaId, gBill.FOnlyMoney);

    with gStockList[cbb_Stocks.ItemIndex] do
    if FPrice > 0 then
    begin
      nInt := Float2PInt(gBill.FMoney / FPrice, cPrecision, False);
      lbl10.Caption := '最大：'+FloatToStr(nInt / cPrecision) + ' 吨';
    end;
  end
  else ShowMsg('请选择有效纸卡', sHint);
end;

procedure TFormBillCardHandl.edt_ValueKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (key in ['0'..'9','.',#8]) then
    key:=#0;
  if (key='.') and (Pos('.',edt_Value.Text)>0)   then
    key:=#0;
end;

procedure TFormBillCardHandl.edt1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    btn1.Click;
  end;
end;

procedure TFormBillCardHandl.FormCreate(Sender: TObject);
begin
  TStringGrid(DBGrd1).DefaultRowHeight:=30;
end;

end.
