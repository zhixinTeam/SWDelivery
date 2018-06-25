{*******************************************************************************
  ����: dmzn@163.com 2018-05-17
  ����: ��ȫ���ͻ�����
*******************************************************************************}
unit UFormInvoiceZZAll;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, uniGUITypes,
  uniGUIForm, USysConst, Data.Win.ADODB, UFormBase, uniBitBtn, uniMemo,
  uniGUIClasses, uniEdit, uniLabel, uniPanel, Vcl.Controls, Vcl.Forms,
  uniGUIBaseClasses, uniButton;

type
  TfFormInvoiceZZAll = class(TfFormBase)
    UniLabel1: TUniLabel;
    EditWeek: TUniEdit;
    UniLabel2: TUniLabel;
    EditMemo: TUniMemo;
    BtnWeekFilter: TUniBitBtn;
    PanelHide1: TUniHiddenPanel;
    BtnRun: TUniButton;
    procedure BtnWeekFilterClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnRunClick(Sender: TObject);
  private
    { Private declarations }
    FWeekBegin,FWeekEnd: TDateTime;
    //��������
    procedure InitFormData;
    //��ʼ��
    procedure ZZAll;
    procedure ZZ_All(const nNeedCombine: Boolean; const nQuery: TADOQuery);
    //���˲���
    procedure ShowHintText(const nText: string);
    //��ʾ����
  public
    { Public declarations }
  end;

procedure ShowInvoiceZZAllForm(const nYear,nWeek,nWeekName: string;
  const nResult: TFormModalResult);
//��ں���

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  ULibFun, USysBusiness, USysDB, UFormInvoiceGetWeek;

//Date: 2018-05-17
//Parm: ��;����,����
//Desc: ��ʾ�������ʴ���
procedure ShowInvoiceZZAllForm(const nYear,nWeek,nWeekName: string;
  const nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormInvoiceZZAll', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormInvoiceZZAll do
  begin
    with FParam do
    begin
      FParamA := nYear;
      FParamB := nWeek;
      FParamC := nWeekName;
    end;

    //FLastInterval := 0;
    InitFormData; //init
    
    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(mrOk, @FParam);
        //xxxxx
      end);
    //xxxxx
  end;
end;

procedure TfFormInvoiceZZAll.BtnWeekFilterClick(Sender: TObject);
begin
  ShowInvoiceGetWeekForm(FParam,
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      with FParam do
      begin
        FParamA := nParam.FParamA;
        FParamB := nParam.FParamB;
        FParamC := nParam.FParamC;
      end;

      InitFormData;
    end);
  //xxxxx
end;

procedure TfFormInvoiceZZAll.InitFormData;
begin
  if FParam.FParamB = '' then
       EditWeek.Text := '��ѡ���������'
  else EditWeek.Text := Format('%s ���:[ %s ]', [FParam.FParamC, FParam.FParamA]);
end;

procedure TfFormInvoiceZZAll.ShowHintText(const nText: string);
begin
  EditMemo.Lines.Add(IntToStr(EditMemo.Lines.Count) + ' ::: ' + nText);
end;

//------------------------------------------------------------------------------
//Desc: ִ������
procedure TfFormInvoiceZZAll.BtnRunClick(Sender: TObject);
begin
  ZZAll;
end;

procedure TfFormInvoiceZZAll.BtnOKClick(Sender: TObject);
var nStr: string;
    nInt: Integer;
    nQuery: TADOQuery;
begin
  if FParam.FParamB = '' then
  begin
    ShowMessage('��ѡ����Ч������');
    Exit;
  end;

  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    if not IsWeekValid(FParam.FParamB, nStr, FWeekBegin, FWeekEnd, nQuery) then
    begin
      ShowMessage(nStr); Exit;
    end;

    if IsNextWeekEnable(FParam.FParamB, nQuery) then
    begin
      nStr := '�������ѽ���,ϵͳ��ֹ�ٴ�����!';
      ShowMessage(nStr); Exit;
    end;

    nInt := IsPreWeekOver(FParam.FParamB, nQuery);
    if nInt > 0 then
    begin
      nStr := Format('��ǰ���ڻ���[ %d ]��δ�������,���ȴ���!', [nInt]);
      ShowMessage(nStr); Exit;
    end;

    if IsWeekHasEnable(FParam.FParamB, nQuery) then
         FParam.FParamE := sFlag_Yes
    else FParam.FParamE := sFlag_No;

    nStr := '�ò���������Ҫһ��ʱ��,�����ĵȺ�.' + #13#10 +
            'Ҫ������?';
    MessageDlg(nStr, mtConfirmation, mbYesNo,
      procedure(Sender: TComponent; Res: Integer)
      begin
        if Res = mrYes then
        begin
          EditMemo.Text := '��ʼ����,�����ĵȴ�';
          BtnRun.JSInterface.JSCall('fireEvent', ['click', BtnRun]);
          //����Զ�̴���,��ʾ���Ȳ�ִ��click����
        end;
      end);
    //xxxxx
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormInvoiceZZAll.ZZAll;
var nStr,nFields: string;
    nInit: Int64;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  nList := nil;
  nQuery := nil;
  nInit := GetTickCount;
  try
    nQuery := LockDBQuery(FDBType);
    ZZ_All(FParam.FParamE = sFlag_Yes, nQuery);

    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    //get list
    
    if FParam.FParamE = sFlag_Yes then
    begin
      nStr := 'Delete From %s Where R_Week=''%s''';
      nStr := Format(nStr, [sTable_InvoiceReq, FParam.FParamB]);
      nList.Add(nStr);
    end;

    nFields := 'R_Week,R_ZhiKa,R_CusID,R_Customer,R_CusPY,R_SaleID,R_SaleMan,' +
      'R_Type,R_Stock,R_StockName,R_Price,R_Value,R_YunFei,R_PreHasK,' +
      'R_ReqValue,R_KPrice,R_KValue,R_KOther,R_Man,R_Date';
    //xxxxx

    nStr := 'Insert Into %s(%s) Select %s From %s';
    //move into normal table

    nStr := Format(nStr, [sTable_InvoiceReq, nFields, nFields, sTable_InvReqtemp]);
    nList.Add(nStr);
    
    nStr := '�û�[ %s ]������[ %s ]ִ�����˲���.';
    nStr := Format(nStr, [uniMainModule.FUserConfig.FUserID, FParam.FParamC]);
    nStr := WriteSysLog(sFlag_CommonItem, FParam.FParamB, nStr, 
            FDBType, nil, False, False);
    nList.Add(nStr);

    DBExecute(nList, nQuery);
    ModalResult := mrOk;
    ShowMessage('���˲������');
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);

    nInit := GetTickCount - nInit;
    if nInit < 2000 then
      Sleep(2000 - nInit);
    //xxxxx
  end;
end;

//Date: 2018-05-17
//Parm: �ϲ�������
//Desc: ִ�����ʲ���
procedure TfFormInvoiceZZAll.ZZ_All(const nNeedCombine: Boolean;
  const nQuery: TADOQuery);
var nStr,nSQL: string;
begin
  nStr := 'Delete From ' + sTable_InvReqtemp;
  DBExecute(nStr, nQuery);
  //�����ʱ��

  nSQL := 'Select L_ZhiKa,L_SaleID,L_SaleMan,L_CusID,L_CusName,L_CusPY,' +
          'L_Type,L_StockNo,L_StockName,Sum(L_Value) as L_Value From $Bill ' +
          'Where L_OutFact>=''$S'' And L_OutFact<=''$E'' ' +
          'Group By L_ZhiKa,L_SaleID,L_SaleMan,L_CusID,L_CusName,L_CusPY,' +
          'L_Type,L_StockNo,L_StockName';
  //xxxxx

  with TStringHelper,TDateTimeHelper do
    nSQL := MacroValue(nSQL, [MI('$Bill', sTable_Bill),
            MI('$S', Date2Str(FWeekBegin)), MI('$E', Date2Str(FWeekEnd+1))]);
  //ͬ�ͻ�ͬƷ��ͬ���ۺϲ�

  nStr := 'Select ''$W'' As R_Week,''$Man'' As R_Man,$Now As R_Date,' +
          'b.* From ($Bill) b ';
  with TStringHelper do
    nSQL := MacroValue(nStr, [MI('$W', FParam.FParamB), MI('$Bill', nSQL),
            MI('$Man', UniMainModule.FUserConfig.FUserID), 
            MI('$Now', sField_SQLServer_Now)]);
  //�ϲ���Ч����

  nStr := 'Insert Into %s(R_Week,R_Man,R_Date,R_ZhiKa,R_SaleID,R_SaleMan,' +
    'R_CusID,R_Customer,R_CusPY,R_Type,R_Stock,R_StockName,' +
    'R_Value) Select * From (%s) t';
  nStr := Format(nStr, [sTable_InvReqtemp, nSQL]);

  ShowHintText('��ʼ����ͻ��������...');
  DBExecute(nStr, nQuery);
  ShowHintText('�ͻ���������������!');

  //----------------------------------------------------------------------------
  nSQL := 'Update $T Set $T.R_Price=$Z.D_Price,$T.R_KPrice=$Z.D_FLPrice, ' +
          '$T.R_YunFei=$Z.D_YunFei From $Z Where $T.R_ZhiKa=$Z.D_ZID And ' +
          '$T.R_Stock=$Z.D_StockNo';
  //xxxxx

  with TStringHelper do
  nStr := MacroValue(nSQL, [MI('$T', sTable_InvReqtemp),
          MI('$Z', sTable_ZhiKaDtl)]);
  //xxxxx

  ShowHintText('��ʼ�ϲ�������ۼ������۲�...');
  DBExecute(nStr);
  ShowHintText('�ϲ����ۼ��������!');
  
  //----------------------------------------------------------------------------
  if nNeedCombine then
  begin
    nSQL := 'Update $T Set $T.R_KPrice=$R.R_KPrice,$T.R_KValue=$R.R_KValue ' +
            'From $R Where $R.R_Week=''$W'' And $T.R_CusID=$R.R_CusID And ' +
            '$T.R_SaleID=$R.R_SaleID And $T.R_Type=$R.R_Type And ' +
            '$T.R_Stock=$R.R_Stock And $T.R_ZhiKa=$R.R_ZhiKa';
    //xxxxx

    with TStringHelper do
    nStr := MacroValue(nSQL, [MI('$T', sTable_InvReqtemp),
            MI('$R', sTable_InvoiceReq), MI('$W', FParam.FParamB)]);
    //xxxxx

    ShowHintText('��ʼ�ϲ��ϴ���������...');
    DBExecute(nStr);
    ShowHintText('�ϲ��ϴ������������!');
  end;
end;

initialization
  RegisterClass(TfFormInvoiceZZAll);
end.
