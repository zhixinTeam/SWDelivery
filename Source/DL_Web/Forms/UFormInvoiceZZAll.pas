{*******************************************************************************
  作者: dmzn@163.com 2018-05-17
  描述: 对全部客户扎账
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
    //周期区间
    procedure InitFormData;
    //初始化
    procedure ZZAll;
    procedure ZZ_All(const nNeedCombine: Boolean; const nQuery: TADOQuery);
    //扎账操作
    procedure ShowHintText(const nText: string);
    //提示内容
  public
    { Public declarations }
  end;

procedure ShowInvoiceZZAllForm(const nYear,nWeek,nWeekName: string;
  const nResult: TFormModalResult);
//入口函数

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  ULibFun, USysBusiness, USysDB, UFormInvoiceGetWeek;

//Date: 2018-05-17
//Parm: 年;周期,名称
//Desc: 显示销售扎帐窗口
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
       EditWeek.Text := '请选择结算周期'
  else EditWeek.Text := Format('%s 年份:[ %s ]', [FParam.FParamC, FParam.FParamA]);
end;

procedure TfFormInvoiceZZAll.ShowHintText(const nText: string);
begin
  EditMemo.Lines.Add(IntToStr(EditMemo.Lines.Count) + ' ::: ' + nText);
end;

//------------------------------------------------------------------------------
//Desc: 执行扎帐
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
    ShowMessage('请选择有效的周期');
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
      nStr := '本周期已结束,系统禁止再次扎账!';
      ShowMessage(nStr); Exit;
    end;

    nInt := IsPreWeekOver(FParam.FParamB, nQuery);
    if nInt > 0 then
    begin
      nStr := Format('以前周期还有[ %d ]笔未返利完毕,请先处理!', [nInt]);
      ShowMessage(nStr); Exit;
    end;

    if IsWeekHasEnable(FParam.FParamB, nQuery) then
         FParam.FParamE := sFlag_Yes
    else FParam.FParamE := sFlag_No;

    nStr := '该操作可能需要一段时间,请耐心等候.' + #13#10 +
            '要继续吗?';
    MessageDlg(nStr, mtConfirmation, mbYesNo,
      procedure(Sender: TComponent; Res: Integer)
      begin
        if Res = mrYes then
        begin
          EditMemo.Text := '开始扎帐,请耐心等待';
          BtnRun.JSInterface.JSCall('fireEvent', ['click', BtnRun]);
          //调用远程代码,显示进度并执行click操作
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
    
    nStr := '用户[ %s ]对周期[ %s ]执行扎账操作.';
    nStr := Format(nStr, [uniMainModule.FUserConfig.FUserID, FParam.FParamC]);
    nStr := WriteSysLog(sFlag_CommonItem, FParam.FParamB, nStr, 
            FDBType, nil, False, False);
    nList.Add(nStr);

    DBExecute(nList, nQuery);
    ModalResult := mrOk;
    ShowMessage('扎账操作完成');
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
//Parm: 合并旧数据
//Desc: 执行扎帐操作
procedure TfFormInvoiceZZAll.ZZ_All(const nNeedCombine: Boolean;
  const nQuery: TADOQuery);
var nStr,nSQL: string;
begin
  nStr := 'Delete From ' + sTable_InvReqtemp;
  DBExecute(nStr, nQuery);
  //清空临时表

  nSQL := 'Select L_ZhiKa,L_SaleID,L_SaleMan,L_CusID,L_CusName,L_CusPY,' +
          'L_Type,L_StockNo,L_StockName,Sum(L_Value) as L_Value From $Bill ' +
          'Where L_OutFact>=''$S'' And L_OutFact<=''$E'' ' +
          'Group By L_ZhiKa,L_SaleID,L_SaleMan,L_CusID,L_CusName,L_CusPY,' +
          'L_Type,L_StockNo,L_StockName';
  //xxxxx

  with TStringHelper,TDateTimeHelper do
    nSQL := MacroValue(nSQL, [MI('$Bill', sTable_Bill),
            MI('$S', Date2Str(FWeekBegin)), MI('$E', Date2Str(FWeekEnd+1))]);
  //同客户同品种同单价合并

  nStr := 'Select ''$W'' As R_Week,''$Man'' As R_Man,$Now As R_Date,' +
          'b.* From ($Bill) b ';
  with TStringHelper do
    nSQL := MacroValue(nStr, [MI('$W', FParam.FParamB), MI('$Bill', nSQL),
            MI('$Man', UniMainModule.FUserConfig.FUserID), 
            MI('$Now', sField_SQLServer_Now)]);
  //合并有效内容

  nStr := 'Insert Into %s(R_Week,R_Man,R_Date,R_ZhiKa,R_SaleID,R_SaleMan,' +
    'R_CusID,R_Customer,R_CusPY,R_Type,R_Stock,R_StockName,' +
    'R_Value) Select * From (%s) t';
  nStr := Format(nStr, [sTable_InvReqtemp, nSQL]);

  ShowHintText('开始计算客户总提货量...');
  DBExecute(nStr, nQuery);
  ShowHintText('客户总提货量计算完毕!');

  //----------------------------------------------------------------------------
  nSQL := 'Update $T Set $T.R_Price=$Z.D_Price,$T.R_KPrice=$Z.D_FLPrice, ' +
          '$T.R_YunFei=$Z.D_YunFei From $Z Where $T.R_ZhiKa=$Z.D_ZID And ' +
          '$T.R_Stock=$Z.D_StockNo';
  //xxxxx

  with TStringHelper do
  nStr := MacroValue(nSQL, [MI('$T', sTable_InvReqtemp),
          MI('$Z', sTable_ZhiKaDtl)]);
  //xxxxx

  ShowHintText('开始合并提货单价及返利价差...');
  DBExecute(nStr);
  ShowHintText('合并单价及返利完毕!');
  
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

    ShowHintText('开始合并上次扎账数据...');
    DBExecute(nStr);
    ShowHintText('合并上次扎账数据完毕!');
  end;
end;

initialization
  RegisterClass(TfFormInvoiceZZAll);
end.
