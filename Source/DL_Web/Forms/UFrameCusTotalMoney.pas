{*******************************************************************************
  作者: dmzn@163.com 2018-05-29
  描述: 客户资金统计(按年或月统计)

  备注:
  格式: 客户名称 期初金额 发生金额 结余金额
*******************************************************************************}
unit UFrameCusTotalMoney;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  uniGUITypes, Data.Win.ADODB, UFrameBase, uniButton, uniBitBtn, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniPanel, uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, frxClass,
  frxExportPDF, frxDBSet;

type
  TfFrameCusTotalMoney = class(TfFrameBase)
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure BtnDateFilterClick(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    {*时间区间*}
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //日期筛选
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
  UManagerGroup, UFormDateFilter, USysBusiness;

procedure TfFrameCusTotalMoney.OnCreateFrame(const nIni: TIniFile);
var nY,nM,nD: Word;
begin
  inherited;
  InitDateRange(ClassName, FStart, FEnd);

  if FStart = FEnd then
  begin
    DecodeDate(Date(), nY, nM, nD);
    FStart := EncodeDate(nY, nM, 1);

    if nM < 12 then
         FEnd := EncodeDate(nY, nM+1, 1) - 1
    else FEnd := EncodeDate(nY+1, 1, 1) - 1;
  end;
end;

procedure TfFrameCusTotalMoney.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFrameCusTotalMoney.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

procedure TfFrameCusTotalMoney.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
var nStr: string;
    nList: TStrings;
begin
  nList := nil;
  with TStringHelper, TDateTimeHelper do
  try
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
    nDefault := False;
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;

    nStr := 'if object_id(''tempdb..#total'') is not null ' +
            'begin Drop Table #total end ';
    nList.Add(nStr);
    //删除临时表

    nStr := 'Create Table dbo.#total(C_ID varChar(15), C_Name varChar(80), ' +
            'C_PY varChar(80), C_Init decimal(15,5) default 0, ' +
            'C_Total decimal(15,5) default 0, C_End decimal(15,5) default 0)';
    nList.Add(nStr);

    nStr := 'Insert into #total(C_ID,C_Name,C_PY) Select C_ID,C_Name,' +
            'C_PY From ' + sTable_Customer;
    nList.Add(nStr);
    //生成客户列表

    nStr := 'Update #total Set C_Init=A_InitMoney From %s Where C_ID=A_CID';
    nStr := Format(nStr, [sTable_CusAccount]);
    nList.Add(nStr);
    //期初:系统初始金额

    nStr := 'Update #total Set C_Init=C_Init+IsNull(M_Money,0) From (' +
      'Select M_CusID,Sum(M_Money) as M_Money From %s Where M_Date<''$ST'' ' +
      'Group By M_CusID ) t where C_ID=M_CusID';
    nStr := Format(nStr, [sTable_InOutMoney]);
    nList.Add(nStr);
    //期初:合并入金

    nStr := 'Update #total Set C_Init=C_Init-IsNull(L_Money,0) From (' +
      'Select L_CusID,Sum(CONVERT(Decimal(15,2), (L_Price+L_YunFei)*L_Value)) as L_Money From %s ' +
      'Where L_OutFact<''$ST'' Group By L_CusID) t Where C_ID=L_CusID';
    nStr := Format(nStr, [sTable_Bill]);
    nList.Add(nStr);
    //期初:合并出金

    nStr := 'Update #total Set C_Init=C_Init-IsNull(S_Money,0) From (' +
      'Select S_CusID,Sum(S_Price*S_Value) as S_Money From %s ' +
      'Where S_OutFact<''$ST'' Group By S_CusID) t Where C_ID=S_CusID';
    nStr := Format(nStr, [sTable_InvSettle]);
    nList.Add(nStr);
    //期初:合并返还

    nStr := 'Update #total Set C_Total=IsNull(M_Money,0) From (' +
      'Select M_CusID,Sum(M_Money) as M_Money From %s Where M_Date>=''$ST'' ' +
      'And M_Date<''$ED'' Group By M_CusID) t Where C_ID=M_CusID';
    nStr := Format(nStr, [sTable_InOutMoney]);
    nList.Add(nStr);
    //发生:合并入金

    nStr := 'Update #total Set C_Total=C_Total-IsNull(L_Money,0) From (' +
      'Select L_CusID,Sum(L_Price*L_Value) as L_Money From %s Where ' +
      'L_OutFact>=''$ST'' and L_OutFact<''$ED''  Group By L_CusID' +
      ')t where C_ID=L_CusID';
    nStr := Format(nStr, [sTable_Bill]);
    nList.Add(nStr);
    //发生:合并出金

    nStr := 'Update #total Set C_Total=C_Total-IsNull(S_Money,0) From (' +
      'Select S_CusID,Sum(S_Price*S_Value) as S_Money From %s Where ' +
      'S_OutFact>=''$ST'' and S_OutFact<''$ED'' Group By S_CusID' +
      ') t where C_ID=S_CusID';
    nStr := Format(nStr, [sTable_InvSettle]);
    nList.Add(nStr);
    //发生:合并返还

    nStr := 'Update #total Set C_End=C_Init+C_Total';
    nList.Add(nStr);
    //结余:生成结余

    nList.Text := MacroValue(nList.Text, [MI('$ST', Date2Str(FStart)),
                  MI('$ED', Date2Str(FEnd + 1))]);
    //xxxxx

    DBExecute(nList, nQuery);
    //生成报表

    nStr := 'Select * From #total';
    if nWhere <> '' then
      nStr := nStr + ' Where (' + nWhere + ')';
    DBQuery(nStr, nQuery, ClientDS);
    //查询结果

    nStr := 'Drop Table #total';
    DBExecute(nStr, nQuery);
    //删除临时表

    BuidDataSetSortIndex(ClientDS);
    //sort index
    //SetGridColumnFormat(FEntity, ClientDS, UniMainModule.DoColumnFormat);
    //列格式化
  finally
    gMG.FObjectPool.Release(nList);
  end;
end;

//Desc: 日期筛选
procedure TfFrameCusTotalMoney.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameCusTotalMoney.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := '(C_PY like ''%%%s%%'' Or C_Name like ''%%%s%%'')';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end;
end;

initialization
  RegisterClass(TfFrameCusTotalMoney);
end.
