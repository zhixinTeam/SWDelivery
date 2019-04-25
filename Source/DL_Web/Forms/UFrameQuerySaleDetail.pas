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
  uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, uniGUIBaseClasses, ULibFun,
  uniMultiItem, uniComboBox, frxClass, frxExportPDF, frxDBSet;

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
    UniLabel1: TUniLabel;
    cbb_Stock: TUniComboBox;
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure BtnDateFilterClick(Sender: TObject);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItemN1Click(Sender: TObject);
    procedure cbb_StockChange(Sender: TObject);
  private
    { Private declarations }
    FStockList: TStringHelper.TDictionaryItems;
    //品种列表
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
    procedure LoadStockList;
    function  GetStockID: string;
  end;

implementation

{$R *.dfm}
uses
  uniGUIVars, MainModule, uniGUIApplication, UManagerGroup, Data.Win.ADODB,
  USysBusiness, USysDB, USysConst, UFormDateFilter;

procedure TfFrameQuerySaleDetail.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  with TDateTimeHelper do
  begin
    FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
    FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  end;
  LoadStockList;

  FJBWhere := '';
  InitDateRange(ClassName, FStart, FEnd);
end;

procedure TfFrameQuerySaleDetail.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

//Desc: 读取品种列表
procedure TfFrameQuerySaleDetail.LoadStockList;
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    with cbb_Stock.Items do
    begin
      BeginUpdate;
      Clear;
      Add('全部显示');
    end;

    SetLength(FStockList, 0);
    nQuery := LockDBQuery(FDBType);

    nStr := 'Select D_Value,D_Memo,D_ParamB From %s ' +
            'Where D_Name=''%s'' Order By D_Index ASC';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(FStockList, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with FStockList[nIdx do
        begin
          FKey   := FieldByName('D_ParamB').AsString;
          FValue := FieldByName('D_Value').AsString;
          FParam := FieldByName('D_Memo').AsString;
        end;

        Inc(nIdx);
        Next;
      end;
    end;

    for nIdx := Low(FStockList) to High(FStockList) do
      cbb_Stock.Items.AddObject(FStockList[nIdx.FValue, Pointer(nIdx));
    cbb_Stock.ItemIndex := 0;
  finally
    cbb_Stock.Items.EndUpdate;
    ReleaseDBQuery(nQuery);
  end;
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

//Desc: 获取选中的品种
function TfFrameQuerySaleDetail.GetStockID: string;
var nIdx: Integer;
begin
  Result := '';
  if cbb_Stock.ItemIndex < 1 then Exit;

  nIdx := NativeInt(cbb_Stock.Items.Objects[cbb_Stock.ItemIndex);
  Result := FStockList[nIdx.FKey;
end;

function TfFrameQuerySaleDetail.InitFormDataSQL(const nWhere: string): string;
var nWH, nWR, nNo: string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    nWH := '';
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd));

    Result := 'Select L_Price,L_Value,Convert(Decimal(15,2), L_Value*(L_Price+IsNull(L_YunFei, 0))) as L_Money,' +
      'L_YunFei,b.* from $Bill b $WH union all ' +
      'Select S_Price*(-1) as L_Price,0 as L_Value,' +
      'S_Value*S_Price*(-1) as L_Money,L_Value*S_YunFei*(-1) as L_YunFei,b.*' +
      ' From $ST st Left Join $Bill b on b.L_ID=st.S_Bill $WR';
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

    nNo := GetStockID;
    if nNo <> '' then
      nWH := nWH + ' And (b.L_StockNo=''$No'')';
    //xxxxx

    if (Not UniMainModule.FUserConfig.FIsAdmin) then
    begin
      if HasPopedom2(sPopedom_ViewMYCusData, FPopedom) then
        nWH := nWH + 'And ((L_SaleMan='''+ UniMainModule.FUserConfig.FUserID +''') or (L_CusName='''+
                            UniMainModule.FUserConfig.FUserID+'''))';
    end;

    nWR:= StringReplace(nWH, 'L_OutFact', 'S_Date', [rfReplaceAll);

    Result := MacroValue(Result, [MI('$WH', nWH));
    Result := MacroValue(Result, [MI('$WR', nWR));
    Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
              MI('$ST', sTable_InvSettle), MI('$No', nNo),
              MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1)));
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
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text,EditBill.Text);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'b.L_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text);
    InitFormData(FWhere);
  end;

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'b.L_ID like ''%%%s%%''';
    FWhere := Format(FWhere, [EditBill.Text);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameQuerySaleDetail.cbb_StockChange(Sender: TObject);
begin
  InitFormData(FWhere);
end;

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
                sFlag_BillPick, sFlag_BillPost);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

initialization
  RegisterClass(TfFrameQuerySaleDetail);
end.
