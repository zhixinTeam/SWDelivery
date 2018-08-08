{*******************************************************************************
  ����:  2018-07-15
  ����: �ͻ�Ӧ���˿���ϸ

  ��ע:
  *.�ͻ�����ĳ��ʱ����˻��䶯ͳ�� �ڳ� ���� ����
*******************************************************************************}
unit UFrameCusReceivableTotal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  uniGUITypes, Data.Win.ADODB, UFrameBase, uniButton, uniBitBtn, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniPanel, uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses;

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
    {*ʱ������*}
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //����ɸѡ
    procedure ArrangeColum;
    procedure AfterInitFormData; override;
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string;
     const nQuery: TADOQuery); override;
    //�������
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
    EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
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

//Desc: ����ɸѡ
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
          GroupHeader:= '�������';
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
//Desc: ��������
procedure TfFrameCusReceivableTotal.BtnLoadClick(Sender: TObject);
var nStr: string;
    nInit: Int64;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  with TDateTimeHelper do
    EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  nList := nil;
  nQuery := nil;
  nInit := GetTickCount; //init

  with TStringHelper,TDateTimeHelper do
  try
    ClientDS.DisableControls;
    //lock ds
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;

    nStr := 'if object_id(''tempdb..#qichu'') is not null ' +
            'begin Drop Table #qichu end ';
    nList.Add(nStr);
    //׼�������ڳ���

    nStr := 'Select A_CID as C_ID, CONVERT(Varchar(200), '''') As C_CusName,CONVERT(Decimal(15,2), A_InitMoney) as C_Init, CONVERT(Decimal(15,2), 0) C_InMoney,  ' +
            '	CONVERT(Decimal(15,2), 0) C_SaleMoney, CONVERT(Decimal(15,2), 0) C_FLMoney, CONVERT(Decimal(15,2), 0) C_AvailableMoney ' +
            ' into #qichu From %s';
    nStr := Format(nStr, [sTable_CusAccount]);
    nList.Add(nStr);
    //�ڳ����

    nStr := 'UPDate #qichu Set C_Init=C_Init+CusInMoney From ( ' +
            'Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney From %s ' +
            'Where M_Date<''$ST''  ' +
            'Group  by M_CusID ) a  Where M_CusID=C_ID ';
    nStr := Format(nStr, [sTable_InOutMoney]);
    nList.Add(nStr);
    //�ϲ����

    nStr := 'UPDate #qichu Set C_Init=C_Init- L_Money From ( ' +
            'Select L_CusID, IsNull(Sum(L_Price*L_Value), 0) L_Money From %s ' +
            'Where L_OutFact<''$ST''  ' +
            'Group  by L_CusID ) a  Where L_CusID=C_ID ';
    nStr := Format(nStr, [sTable_Bill]);
    nList.Add(nStr);
    //�ϲ����� �������


    nStr := 'UPDate #qichu Set C_Init=C_Init- xMoney From ( ' +
            'Select S_CusID, IsNull(Sum(S_Price*S_Value), 0) xMoney From %s ' +
            'Where S_Date<''$ST''  ' +
            'Group  by S_CusID ) a  Where S_CusID=C_ID ' ;
    nStr := Format(nStr, [sTable_InvSettle]);
    nList.Add(nStr);
    //�ϲ�����


    nStr := 'UPDate #qichu Set C_InMoney=CusInMoney From (   ' +
            'Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney From %s  ' +
            'Where M_Date>=''$ST'' And M_Date<''$ED''  ' +
            'Group  by M_CusID ) a  Where M_CusID=C_ID  ';
    nStr := Format(nStr, [sTable_InOutMoney]);
    nList.Add(nStr);
    //�ڳ����

    nStr := 'UPDate #qichu Set C_SaleMoney=L_Money From ( ' +
            'Select L_CusID, IsNull(Sum(L_Price*L_Value), 0) L_Money From %s ' +
            'Where L_OutFact>=''$ST'' And L_OutFact<''$ED''  ' +
            'Group  by L_CusID ) a  Where L_CusID=C_ID  ';
    nStr := Format(nStr, [sTable_Bill]);
    nList.Add(nStr);
    //�����¼


    nStr := 'UPDate #qichu Set C_FLMoney=xMoney From ( ' +
            'Select S_CusID, Sum(ISNULL(S_Price,0)*ISNULL(S_Value, 0)*(-1)) xMoney From %s ' +
            'Where S_Date>=''$ST'' And S_Date<''$ED'' ' +
            'Group  by S_CusID ) a  Where S_CusID=C_ID ';
    nStr := Format(nStr, [sTable_InvSettle]);
    nList.Add(nStr);
    //���㷵��

    nStr := 'UPDate #qichu Set C_CusName=C_Name From S_Customer a Where a.C_ID=#qichu.C_ID';
    nList.Add(nStr);
    //******
    nStr := 'UPDate #qichu Set C_AvailableMoney=C_Init+C_InMoney-C_SaleMoney-C_FLMoney';
    nList.Add(nStr);
    //�������

    nList.Text := MacroValue(nList.Text, [MI('$ST', Date2Str(FStart)),
                  MI('$ED', Date2Str(FEnd + 1))]);
    //xxxxx

    nQuery := LockDBQuery(FDBType);
    DBExecute(nList, nQuery);
    //���ɱ���

    nStr := 'Select * From #qichu order by c_id ';
    DBQuery(nStr, nQuery, ClientDS);
    //��ѯ���

    nStr := 'Drop Table #qichu';
    DBExecute(nStr, nQuery);
    //ɾ����ʱ��
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
