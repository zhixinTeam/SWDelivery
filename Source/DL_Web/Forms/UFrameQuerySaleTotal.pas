{*******************************************************************************
  作者: dmzn@163.com 2018-05-07
  描述: 销售统计
*******************************************************************************}
unit UFrameQuerySaleTotal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, UFrameBase, Vcl.Menus, uniMainMenu,
  uniRadioButton, uniButton, uniBitBtn, uniEdit, uniLabel, Data.DB,
  Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniToolBar, uniGUIBaseClasses, frxClass, frxExportPDF, frxDBSet;

type
  TfFrameQuerySaleTotal = class(TfFrameBase)
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    PMenu1: TUniPopupMenu;
    MenuItemN1: TUniMenuItem;
    Radio1: TUniRadioButton;
    Radio2: TUniRadioButton;
    Radio3: TUniRadioButton;
    Label1: TUniLabel;
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure BtnDateFilterClick(Sender: TObject);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItemN1Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件
    procedure OnDateFilter(const nStart,nEnd: TDate);
    procedure OnDateTimeFilter(const nStart,nEnd: TDate);
    //日期筛选
    procedure ArrangeColum;
    procedure AfterInitFormData; override;
    procedure ChangeDBGridParam;
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  uniGUIVars, MainModule, uniGUIApplication, ULibFun, UManagerGroup,
  USysBusiness, USysDB, USysConst, UFormDateFilter;

procedure TfFrameQuerySaleTotal.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  with TDateTimeHelper do
  begin
    FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
    FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  end;

  FJBWhere := '';
  InitDateRange(ClassName, FStart, FEnd);
end;

procedure TfFrameQuerySaleTotal.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

//Desc: 过滤字段
function TfFrameQuerySaleTotal.FilterColumnField: string;
begin
  if HasPopedom2(sPopedom_ViewPrice, FPopedom) then
       Result := ''
  else Result := 'L_Price;L_Money';
end;

procedure TfFrameQuerySaleTotal.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

procedure TfFrameQuerySaleTotal.ChangeDBGridParam;
begin
  DBGridMain.Grouping.Enabled:= not Radio1.Checked;
  if Radio1.Checked then 
    DBGridMain.Grouping.FieldName:= ''
  else if Radio2.Checked then
    DBGridMain.Grouping.FieldName:= 'L_Type'
  else DBGridMain.Grouping.FieldName:= 'L_CusName' 
end;

function TfFrameQuerySaleTotal.InitFormDataSQL(const nWhere: string): string;
begin
  ChangeDBGridParam;
  with TStringHelper, TDateTimeHelper do
  begin
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

    if Radio1.Checked then
    begin
      Result := 'select L_SaleID,L_SaleMan,L_CusID,L_CusName, '''' L_Type, ' +
                'Sum(L_Value) as L_Value,Sum(Convert(Decimal(15,2), L_Value * (L_Price+L_YunFei))) as L_Money ' +
                'From $Bill ';
      //xxxxx
    end else

    if Radio2.Checked  then
    begin
      Result := 'select '''' as L_CusID,'''' as L_CusName,L_Type,' +
                'L_StockNo,L_StockName,Sum(L_Value) as L_Value,' +
                'Sum(Convert(Decimal(15,2), L_Value * (L_Price+L_YunFei))) as L_Money From $Bill ';
      //xxxxx
    end else
    begin
      Result := 'select L_SaleID,L_SaleMan,L_CusID,L_CusName,L_Type,' +
                'L_StockNo,L_StockName,Sum(L_Value) as L_Value, L_Price,' +
                'Sum(Convert(Decimal(15,2), L_Value * (L_Price+L_YunFei))) as L_Money, L_YunFei From $Bill ';
      //xxxxx
    end;
    Result := Result + ' Left Join S_Customer On C_ID=L_CusID ';

    //--------------------------------------------------------------------------
    if FJBWhere = '' then
    begin
      Result := Result + ' Where (L_OutFact>=''$S'' and L_OutFact <''$End'')';

      if nWhere <> '' then
        Result := Result + ' And (' + nWhere + ')';
      //xxxxx
    end else
    begin
      Result := Result + ' Where (' + FJBWhere + ')';
    end;

    if (Not UniMainModule.FUserConfig.FIsAdmin) then
    begin
      if HasPopedom2(sPopedom_ViewMYCusData, FPopedom) then
        Result := Result + ' And (L_SaleMan='''+ UniMainModule.FUserConfig.FUserID +''' or C_WeiXin='''+
                                                UniMainModule.FUserConfig.FUserID +''')';
    end;
    //*****************

    if Radio1.Checked then
    begin
      Result := Result + ' Group By L_SaleID,L_SaleMan,L_CusID,L_CusName';
    end else

    if Radio2.Checked then
    begin
      Result := Result + ' Group By L_Type,L_StockNo,L_StockName';
    end else
    begin
      Result := Result + ' Group By L_SaleID,L_SaleMan,L_CusID,L_CusName,' +
                'L_Type,L_StockNo,L_StockName,L_Price,L_YunFei';
      //xxxxx
    end;

    Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
              MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
    //xxxxx

    if Radio1.Checked or Radio2.Checked then
    Result := 'Select *,(case IsNull(L_Value,0) when 0 then 0 else Convert(Decimal(15,2),' +
              'L_Money/L_Value) end) as L_Price From (' + Result + ') t';
    //计算均价

    if Radio2.Checked or Radio3.Checked then
      Result := Result + ' Order by L_CusName, L_Type, L_StockName '
  end;
end;

//Desc: 日期筛选
procedure TfFrameQuerySaleTotal.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameQuerySaleTotal.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if (EditCustomer.Text = '') or Radio2.Checked then Exit;
    //按品种合计时无法查询客户

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameQuerySaleTotal.ArrangeColum;
var nIdx : Integer;
    nstr : string;
begin
  try
    DBGridMain.Columns.BeginUpdate;

    ChangeDBGridParam;
    //*********
    for nIdx := 0 to DBGridMain.Columns.Count-1 do
    begin
      with DBGridMain.Columns[nIdx] do
      begin
        Sortable:= not DBGridMain.Grouping.Enabled;
        nstr:= FieldName;
        if (FieldName='DayValue')or(FieldName='MonthValue')or
          (Radio1.Checked and((FieldName='L_StockNo')or(FieldName='L_StockName')
                                or(FieldName='L_YunFei')or(FieldName='L_Type'))or
          (Radio2.Checked and((FieldName='L_CusID')or(FieldName='L_CusName')
                                or(FieldName='L_YunFei')or(FieldName='L_Type')))

          )then
          Visible:= False
        else Visible:= True;
      end;
    end;
  finally
    DBGridMain.Columns.EndUpdate;
  end;
end;

procedure TfFrameQuerySaleTotal.AfterInitFormData;
begin
  ArrangeColum;
end;

procedure TfFrameQuerySaleTotal.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

procedure TfFrameQuerySaleTotal.MenuItemN1Click(Sender: TObject);
begin
  ShowDateFilterForm(FTimeS, FTimeE, OnDateTimeFilter, True)
end;

procedure TfFrameQuerySaleTotal.OnDateTimeFilter(const nStart,nEnd: TDate);
begin
  with TDateTimeHelper do
  try
    FTimeS := nStart;
    FTimeE := nEnd;

    FJBWhere := '(L_OutFact>=''%s'' and L_OutFact <''%s'')';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE),
                sFlag_BillPick, sFlag_BillPost]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

initialization
  RegisterClass(TfFrameQuerySaleTotal);
end.
