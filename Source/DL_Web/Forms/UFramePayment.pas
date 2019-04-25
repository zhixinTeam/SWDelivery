{*******************************************************************************
  作者: dmzn@163.com 2018-05-08
  描述: 销售回款
*******************************************************************************}
unit UFramePayment;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, UFrameBase, uniButton, uniBitBtn, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniPanel, uniToolBar, uniGUIBaseClasses;

type
  TfFramePayment = class(TfFrameBase)
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure BtnDateFilterClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
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
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  uniGUIVars, MainModule, uniGUIApplication, ULibFun, USysDB, USysConst,
  UFormDateFilter, UFormPayment;

procedure TfFramePayment.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  InitDateRange(ClassName, FStart, FEnd);
end;

procedure TfFramePayment.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFramePayment.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

function TfFramePayment.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd));

    Result := 'Select iom.*,sm.S_Name,convert(varchar(20),M_Date,23) as ' +
              'M_DateOnly From $IOM iom ' +
              ' Left Join $SM sm On sm.S_ID=iom.M_SaleMan ' +
              'Where M_Type=''$HK'' ';

    if nWhere = '' then
         Result := Result + 'And (M_Date>=''$Start'' And M_Date <''$End'')'
    else Result := Result + 'And (' + nWhere + ')';

    Result := MacroValue(Result, [MI('$SM', sTable_Salesman),
              MI('$IOM', sTable_InOutMoney), MI('$HK', sFlag_MoneyHuiKuan),
              MI('$Start', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1)));
    //xxxxx
  end;
end;

//Desc: 日期筛选
procedure TfFramePayment.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFramePayment.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := '(M_Date>=''$Start'' And M_Date <''$End'') And ' +
              '(M_CusID like ''%%%s%%'' Or M_CusName like ''%%%s%%'')';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text);
    InitFormData(FWhere);
  end;
end;

//Desc: 回款
procedure TfFramePayment.BtnEditClick(Sender: TObject);
var nStr: string;
begin
  if DBGridMain.SelectedRows.Count > 0 then
       nStr := ClientDS.FieldByName('M_CusID').AsString
  else nStr := '';

  ShowPaymentForm(nStr,
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      InitFormData(FWhere);
    end);
  //xxxxx
end;

initialization
  RegisterClass(TfFramePayment);
end.
