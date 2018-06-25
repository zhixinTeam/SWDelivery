{*******************************************************************************
  作者: dmzn@163.com 2018-05-07
  描述: 发货明细
*******************************************************************************}
unit UFrameQuerySaleDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, UFrameBase, Vcl.Menus, uniMainMenu, uniButton,
  uniBitBtn, uniEdit, uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses,
  uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, uniGUIBaseClasses;

type
  TfFrameQuerySaleDetail = class(TfFrameBase)
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    Label1: TUniLabel;
    EditBill: TUniEdit;
    Label4: TUniLabel;
    EditTruck: TUniEdit;
    PMenu1: TUniPopupMenu;
    MenuItemN1: TUniMenuItem;
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

procedure TfFrameQuerySaleDetail.OnCreateFrame(const nIni: TIniFile);
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

procedure TfFrameQuerySaleDetail.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

//Desc: 过滤字段
function TfFrameQuerySaleDetail.FilterColumnField: string;
begin
  if HasPopedom2(sPopedom_ViewPrice, FPopedom) then
       Result := ''
  else Result := 'L_Price;L_Money';
end;

procedure TfFrameQuerySaleDetail.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

function TfFrameQuerySaleDetail.InitFormDataSQL(const nWhere: string): string;
var nWH: string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    nWH := '';
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

    Result := 'Select L_Price,L_Value,L_Value*L_Price as L_Money,' +
      '0 as L_YunFei,b.* from $Bill b $WH union all ' +
      'Select S_Price*(-1) as L_Price,0 as L_Value,' +
      'S_Value*S_Price*(-1) as L_Money,L_Value*S_YunFei as L_YunFei,b.*' +
      ' From $ST st Left Join $Bill b on b.L_ID=st.S_Bill $WH';
    //xxxxx

    if FJBWhere = '' then
    begin
      nWH := 'Where (L_OutFact>=''$S'' and L_OutFact <''$End'')';

      if nWhere <> '' then
        nWH := nWH + ' And (' + nWhere + ')';
      //xxxxx
    end else
    begin
      nWH := ' Where (' + FJBWhere + ')';
    end;

    Result := MacroValue(Result, [MI('$WH', nWH)]);
    Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
              MI('$ST', sTable_InvSettle),
              MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
    //xxxxx
  end;
end;

//Desc: 日期筛选
procedure TfFrameQuerySaleDetail.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameQuerySaleDetail.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text,EditBill.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'b.L_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end;

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'b.L_ID like ''%%%s%%''';
    FWhere := Format(FWhere, [EditBill.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameQuerySaleDetail.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

procedure TfFrameQuerySaleDetail.MenuItemN1Click(Sender: TObject);
begin
  ShowDateFilterForm(FTimeS, FTimeE, OnDateTimeFilter, True)
end;

procedure TfFrameQuerySaleDetail.OnDateTimeFilter(const nStart,nEnd: TDate);
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
  RegisterClass(TfFrameQuerySaleDetail);
end.
