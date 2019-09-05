{*******************************************************************************
  作者:  2018-07-15
  描述: 客户应收账款明细

  备注:
  *.客户具体某段时间的账户变动统计 期初 发生 结余
*******************************************************************************}
unit UFrameCusReceivableTotal;
{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  uniGUITypes, Data.Win.ADODB, UFrameBase, uniButton, uniBitBtn, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniPanel, uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, frxClass,
  frxExportPDF, frxDBSet;

type
  TfFrameCusReceivableTotal = class(TfFrameBase)
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    UniHiddenPanel1: TUniHiddenPanel;
    BtnLoad: TUniButton;
    procedure BtnDateFilterClick(Sender: TObject);
    procedure BtnLoadClick(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    {*时间区间*}
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //日期筛选
    procedure ArrangeColum;
    procedure AfterInitFormData; override;
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string;
     const nQuery: TADOQuery); override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  uniGUIVars, MainModule, uniGUIApplication, ULibFun, USysDB, USysConst,
  UManagerGroup, UFormDateFilter, UFormGetCustomer, USysBusiness;

procedure TfFrameCusReceivableTotal.OnCreateFrame(const nIni: TIniFile);
var nY,nM,nD: Word;
begin
  inherited;
  InitDateRange(ClassName, FStart, FEnd);

  if FStart = FEnd then
  begin
    DecodeDate(Date(), nY, nM, nD);
    if (nM = 1) and (nD = 1) then
      nY := nY - 1;
    //xxxxx

    FStart := EncodeDate(nY, 1, 1);
    FEnd := EncodeDate(nY+1, 1, 1) - 1;
  end;
end;

procedure TfFrameCusReceivableTotal.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFrameCusReceivableTotal.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
begin
  with TDateTimeHelper do
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  //xxxxx

  nDefault := False;
  BtnLoad.JSInterface.JSCall('fireEvent', ['click', BtnLoad]);
end;

procedure TfFrameCusReceivableTotal.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

//Desc: 日期筛选
procedure TfFrameCusReceivableTotal.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameCusReceivableTotal.ArrangeColum;
var nIdx : Integer;
    nstr : string;
begin
  DBGridMain.Columns.BeginUpdate;
  try
    for nIdx := 0 to DBGridMain.Columns.Count-1 do
    begin
      with DBGridMain.Columns[nIdx] do
      begin
        nstr:= FieldName;
        if (FieldName='C_InMoney')or (FieldName='C_SaleMoney')or(FieldName='C_FLMoney') then
        begin
          GroupHeader:= '发生金额';
          Title.Alignment:= taCenter;
          Alignment:= taCenter;
        end
        else if (FieldName='C_Init')or (FieldName='C_AvailableMoney') then
        begin
          Alignment:= taCenter;
          Title.Alignment:= taCenter;
        end;
      end;
    end;
  finally
    DBGridMain.Columns.EndUpdate;
  end;
end;

procedure TfFrameCusReceivableTotal.AfterInitFormData;
begin
  ArrangeColum;
end;

//------------------------------------------------------------------------------
//Desc: 加载数据
procedure TfFrameCusReceivableTotal.BtnLoadClick(Sender: TObject);
var nStr, nExWH: string;
    nInit: Int64;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  with TDateTimeHelper do
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  nList := nil;
  nQuery := nil;    nExWH:= '';
  nInit := GetTickCount; //init

  with TStringHelper,TDateTimeHelper do
  try
    ClientDS.DisableControls;
    //lock ds
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;

    nStr := 'if object_id(''tempdb..#qichu'') is not null ' +
            'begin Drop Table #qichu end ';
    nList.Add(nStr);
    //准备创建期初表

    nStr := 'Select A_CID as C_ID, CONVERT(Varchar(200), '''') As C_CusName,CONVERT(Decimal(15,2), A_InitMoney) as C_Init, CONVERT(Decimal(15,2), 0) C_InMoney,  ' +
            '	CONVERT(Decimal(15,2), 0) C_SaleMoney, CONVERT(Decimal(15,2), 0) C_FLMoney, CONVERT(Decimal(15,2), 0) C_AvailableMoney ' +
            ' into #qichu From %s ';
    nStr := Format(nStr, [sTable_CusAccount]);

    if (Not UniMainModule.FUserConfig.FIsAdmin) then
    begin
      if (FPopedom<>'')And(HasPopedom2(sPopedom_ViewMYCusData, FPopedom)) then
      begin
        nStr := nStr + ' Left Join %s On A_CID=C_ID Left Join %s On C_SaleMan=S_ID ' +
                       ' Where (S_Name='''+UniMainModule.FUserConfig.FUserID+''')';
        nStr := Format(nStr, [sTable_Customer, sTable_Salesman]);
      end;
    end;
    nList.Add(nStr);
    //期初金额

    {$IFDEF AuditingPayment}
    nExWH:= ' And M_Verify=''Y'' ';
    {$ENDIF}
    nStr := 'UPDate #qichu Set C_Init=C_Init+CusInMoney From ( ' +
            'Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney From %s ' +
            'Where M_Date<''$ST''  ' + nExWH +
            'Group  by M_CusID ) a  Where M_CusID=C_ID ';
    nStr := Format(nStr, [sTable_InOutMoney]);
    nList.Add(nStr);
    //合并入金

    nStr := 'UPDate #qichu Set C_Init=C_Init- L_Money From ( ' +
            'Select L_CusID, IsNull(Sum((L_Price+IsNull(L_YunFei, 0))*L_Value), 0) L_Money From %s ' +
            'Where L_OutFact<''$ST''  ' +
            'Group  by L_CusID ) a  Where L_CusID=C_ID ';
    nStr := Format(nStr, [sTable_Bill]);
    nList.Add(nStr);
    //合并出金 发货金额


    nStr := 'UPDate #qichu Set C_Init=C_Init- xMoney From ( ' +
            'Select S_CusID, -1*IsNull(Sum((S_Price+IsNull(S_YunFei, 0))*S_Value), 0) xMoney From %s ' +
            'Where S_Date<''$ST''  ' +
            'Group  by S_CusID ) a  Where S_CusID=C_ID ' ;
    nStr := Format(nStr, [sTable_InvSettle]);
    nList.Add(nStr);
    //合并返还


    nStr := 'UPDate #qichu Set C_InMoney=CusInMoney From (   ' +
            'Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney From %s  ' +
            'Where M_Date>=''$ST'' And M_Date<''$ED''  ' + nExWH +
            'Group  by M_CusID ) a  Where M_CusID=C_ID  ';
    nStr := Format(nStr, [sTable_InOutMoney]);
    nList.Add(nStr);
    //期初金额

    nStr := 'UPDate #qichu Set C_SaleMoney=L_Money From ( ' +
            'Select L_CusID, Sum(CONVERT(Decimal(15,2), (L_Price+ISNULL(L_YunFei,0))*L_Value)) L_Money From %s ' +
            'Where L_OutFact>=''$ST'' And L_OutFact<''$ED''  ' +
            'Group  by L_CusID ) a  Where L_CusID=C_ID  ';
    nStr := Format(nStr, [sTable_Bill]);
    nList.Add(nStr);
    //出金记录


    nStr := 'UPDate #qichu Set C_FLMoney=xMoney From ( ' +
            'Select S_CusID, Sum((ISNULL(S_Price,0)+ISNULL(S_YunFei,0))*ISNULL(S_Value, 0)*(-1)) xMoney From %s ' +
            'Where S_Date>=''$ST'' And S_Date<''$ED'' ' +
            'Group  by S_CusID ) a  Where S_CusID=C_ID ';
    nStr := Format(nStr, [sTable_InvSettle]);
    nList.Add(nStr);
    //结算返利

    nStr := 'UPDate #qichu Set C_CusName=C_Name From S_Customer a Where a.C_ID=#qichu.C_ID';
    nList.Add(nStr);
    //******
    nStr := 'UPDate #qichu Set C_AvailableMoney=C_Init+C_InMoney-C_SaleMoney-C_FLMoney';
    nList.Add(nStr);
    //计算结余

    nList.Text := MacroValue(nList.Text, [MI('$ST', Date2Str(FStart)),
                  MI('$ED', Date2Str(FEnd + 1))]);
    //xxxxx

    nQuery := LockDBQuery(FDBType);
    DBExecute(nList, nQuery);
    //生成报表

    nStr := 'Select * From #qichu order by c_id ';
    DBQuery(nStr, nQuery, ClientDS);
    //查询结果

    nStr := 'Drop Table #qichu';
    DBExecute(nStr, nQuery);
    //删除临时表
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
    ClientDS.EnableControls;

    nInit := GetTickCount - nInit;
    if nInit < 2000 then
      Sleep(2000 - nInit);
    //xxxxx
  end;
end;

initialization
  RegisterClass(TfFrameCusReceivableTotal);
end.
