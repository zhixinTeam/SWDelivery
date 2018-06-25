{*******************************************************************************
  ����: dmzn@163.com 2018-05-29
  ����: �ͻ�Ӧ���˿���ϸ

  ��ע:
  *.ĳ���ͻ�����ĳ��ʱ����˻��䶯��ϸ,����������¼ �ɿ��¼ ������¼
*******************************************************************************}
unit UFrameCusReceivable;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  uniGUITypes, Data.Win.ADODB, UFrameBase, uniButton, uniBitBtn, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniPanel, uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses;

type
  TfFrameCusReceivable = class(TfFrameBase)
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    BtnFindCus: TUniBitBtn;
    UniHiddenPanel1: TUniHiddenPanel;
    BtnLoad: TUniButton;
    procedure BtnDateFilterClick(Sender: TObject);
    procedure BtnFindCusClick(Sender: TObject);
    procedure BtnLoadClick(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    {*ʱ������*}
    FCusID,FCusName: string;
    //�ͻ���Ϣ
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //����ɸѡ
    procedure CalJieCun;
    //������
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

procedure TfFrameCusReceivable.OnCreateFrame(const nIni: TIniFile);
var nY,nM,nD: Word;
begin
  inherited;
  FCusID := '';
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

procedure TfFrameCusReceivable.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFrameCusReceivable.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
begin
  with TDateTimeHelper do
    EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
  //xxxxx

  nDefault := False;
  BtnLoad.JSInterface.JSCall('fireEvent', ['click', BtnLoad]);
end;

procedure TfFrameCusReceivable.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

//Desc: ����ɸѡ
procedure TfFrameCusReceivable.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameCusReceivable.BtnFindCusClick(Sender: TObject);
begin
  ShowGetCustomerForm(FCusName,
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      FCusID := nParam.FParamA;
      FCusName := nParam.FParamB;
      BtnLoad.JSInterface.JSCall('fireEvent', ['click', BtnLoad]);
    end);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: ��������
procedure TfFrameCusReceivable.BtnLoadClick(Sender: TObject);
var nStr: string;
    nInit: Int64;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  with TDateTimeHelper do
    EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
  if FCusID = '' then Exit;
  EditCustomer.Text := FCusID + '.' + FCusName;

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

    nStr := 'Select A_CID as C_ID,A_InitMoney as C_Init into #qichu From %s ' +
            'where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, FCusID]);
    nList.Add(nStr);
    //�ڳ����

    nStr := 'Update #qichu Set C_Init=C_Init+IsNull((Select Sum(M_Money) ' +
            ' From %s Where M_CusID=''%s'' And M_Date<''$ST''), 0)';
    nStr := Format(nStr, [sTable_InOutMoney, FCusID]);
    nList.Add(nStr);
    //�ϲ����

    nStr := 'Update #qichu Set C_Init=C_Init-IsNull((Select Sum(L_Price*' +
            'L_Value) From %s Where L_CusID=''%s'' And L_OutFact<''$ST''), 0)';
    nStr := Format(nStr, [sTable_Bill, FCusID]);
    nList.Add(nStr);
    //�ϲ�����

    nStr := 'Update #qichu Set C_Init=C_Init-IsNull((Select Sum(S_Price*' +
            'S_Value) From %s Where S_CusID=''%s'' And S_Date<''$ST''), 0)';
    nStr := Format(nStr, [sTable_InvSettle, FCusID]);
    nList.Add(nStr);
    //�ϲ�����

    nStr := 'if object_id(''tempdb..#recv'') is not null ' +
            'begin Drop Table #recv end ';
    nList.Add(nStr);
    //׼������Ӧ�ձ�

    nStr := 'Create Table dbo.#recv(R_ID varChar(32), R_Date DateTime,' +
      'R_Type Integer, R_Desc varChar(32), R_Stock varChar(80),' +
      'R_Init decimal(15,5) default 0, R_Shou decimal(15,5) default 0,' +
      'R_Value decimal(15,5) default 0, R_Price decimal(15,5) default 0,' +
      'R_Money decimal(15,5) default 0, R_YunFei decimal(15,5) default 0,' +
      'R_End decimal(15,5) default 0)';
    nList.Add(nStr);
    //��¼��,����,����,Ʒ��,�ڳ����,�տ�,������,����,Ӧ�ս��,�˷�,���

    nStr := 'Insert into #recv(R_Date,R_Type,R_Desc,R_Init) Select ' +
         '''2000-01-01'' as R_Date,1 as R_Type,''���'' as R_Desc,' +
         'C_Init as R_Init From #qichu';
    nList.Add(nStr);
    //�ڳ����

    nStr := 'Insert into #recv(R_ID,R_Date,R_Type,R_Desc,R_Stock,R_Value,' +
      'R_Price,R_Money) Select L_ID,L_OutFact,2,''����ƾ֤'',L_StockName,' +
      'L_Value,L_Price,L_Price*L_Value From %s ' +
      'Where L_CusID=''%s'' And L_OutFact>=''$ST'' and L_OutFact<''$ED''';
    nStr := Format(nStr, [sTable_Bill, FCusID]);
    nList.Add(nStr);
    //�����¼

    nStr := 'Insert into #recv(R_ID,R_Date,R_Type,R_Desc,R_Shou) Select ' +
      '''IOMONEY-''+CAST(R_ID as nvarchar(10)),M_Date,3,''���ۻؿ�'',' +
      'M_Money From %s Where M_CusID=''%s'' And M_Date>=''$ST'' And ' +
      'M_Date<''$ED''';
    nStr := Format(nStr, [sTable_InOutMoney, FCusID]);
    nList.Add(nStr);
    //�����

    nStr := 'Insert into #recv(R_ID,R_Date,R_Type,R_Desc,R_Stock,R_Price,' +
      'R_Money,R_YunFei) Select S_Bill,S_Date,4,''���㷵��'',S_StockName,' +
      'S_Price*(-1),S_Price*S_Value*(-1),S_YunFei*S_Value From %s ' +
      'Where S_CusID=''%s'' And S_Date>=''$ST'' And S_Date<''$ED''';
    nStr := Format(nStr, [sTable_InvSettle, FCusID]);
    nList.Add(nStr);
    //���㷵��

    nList.Text := MacroValue(nList.Text, [MI('$ST', Date2Str(FStart)),
                  MI('$ED', Date2Str(FEnd + 1))]);
    //xxxxx

    nQuery := LockDBQuery(FDBType);
    DBExecute(nList, nQuery);
    //���ɱ���

    nStr := 'Select row_number()over(Order By R_Date ASC) as ID,* From #recv ' +
            'Order By R_Date ASC';
    DBQuery(nStr, nQuery, ClientDS);
    //��ѯ���

    nStr := 'Drop Table #recv';
    DBExecute(nStr, nQuery);
    nStr := 'Drop Table #qichu';
    DBExecute(nStr, nQuery);
    //ɾ����ʱ��

    CalJieCun;
    //������
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

//Desc: ����ClientDS.R_End�������
procedure TfFrameCusReceivable.CalJieCun;
var nType: Integer;
    nInit: Double;

  procedure ApplyData(const nVal: Double);
  begin
    with ClientDS,TFloatHelper do
    begin
      Edit; //to change
      FieldByName('R_End').AsFloat := Float2Float(nVal, cPrecision, True);
      Post; //apply
    end;
  end;
begin
  with ClientDS do
  begin
    if (not Active) or (RecordCount < 1) then Exit;
    //no data
    First;

    if FieldByName('R_Type').AsInteger <> 1 then
    begin
      ShowMessage('���ݼ������,�޷���ȡ�ڳ�����');
      Exit;
    end;

    Edit;
    nInit := FieldByName('R_Init').AsFloat;
    FieldByName('R_End').AsFloat := nInit;
    FieldByName('R_Date').AsDateTime := FStart;
    Post;

    Next;//xxxxx
    while not Eof do
    begin
      nType := FieldByName('R_Type').AsInteger;
      if nType = 2 then
      begin
        nInit := nInit - FieldByName('R_Money').AsFloat;
        ApplyData(nInit);
      end else

      if nType = 3 then
      begin
        nInit := nInit + FieldByName('R_Shou').AsFloat;
        ApplyData(nInit);
      end else

      if nType = 4 then
      begin
        nInit := nInit - FieldByName('R_Money').AsFloat;
        ApplyData(nInit);
      end;

      Next;
    end;

    First;
    //xxxxx
  end;
end;

initialization
  RegisterClass(TfFrameCusReceivable);
end.
