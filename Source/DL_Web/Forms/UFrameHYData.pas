{*******************************************************************************
  作者: 2018-07-22
  描述: 化验单记录
*******************************************************************************}
unit UFrameHYData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, uniGUIForm, UFrameBase, Vcl.Menus, uniMainMenu, uniButton,
  uniBitBtn, uniEdit, uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, ULibFun,
  uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, uniGUIBaseClasses,
  uniMultiItem, uniComboBox, frxClass, frxExportPDF, frxDBSet;

type
  TfFrameHYData = class(TfFrameBase)
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    Label4: TUniLabel;
    EditTruck: TUniEdit;
    PMenu1: TUniPopupMenu;
    MenuItemN1: TUniMenuItem;
    UniLabel1: TUniLabel;
    cbb_Stock: TUniComboBox;
    N1: TUniMenuItem;
    N2: TUniMenuItem;
    unmntmN31: TUniMenuItem;
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure BtnDateFilterClick(Sender: TObject);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItemN1Click(Sender: TObject);
    procedure cbb_StockChange(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure unmntmN31Click(Sender: TObject);
  private
    { Private declarations }
    FStockList: TStringHelper.TDictionaryItems;
    //品种列表
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FBillId, FValue : string;
    FJBWhere: string;
    //交班条件
    procedure OnDateFilter(const nStart,nEnd: TDate);
    procedure OnDateTimeFilter(const nStart,nEnd: TDate);
    //日期筛选
    procedure OnDateResult(const nValue: string);
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
    procedure LoadStockList;
    function  GetStockName: string;
  end;

implementation

{$R *.dfm}
uses
  uniGUIVars, MainModule, uniGUIApplication, UManagerGroup, Data.Win.ADODB,
  USysBusiness, USysDB, USysConst, UFormDateFilter, UFormInputbox, UFormInputBoxEx;


procedure TfFrameHYData.OnCreateFrame(const nIni: TIniFile);
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

procedure TfFrameHYData.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFrameHYData.unmntmN31Click(Sender: TObject);
var nStr : string;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要打印的记录');
    Exit;
  end;

  nStr := ClientDS.FieldByName('H_ID').AsString;
  PrintHuaYanReport_3(nStr);
end;

//Desc: 读取品种列表
procedure TfFrameHYData.LoadStockList;
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
function TfFrameHYData.FilterColumnField: string;
begin
  if HasPopedom2(sPopedom_ViewPrice, FPopedom) then
       Result := ''
  else Result := 'L_Price;L_Money';
end;

procedure TfFrameHYData.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

//Desc: 获取选中的品种
function TfFrameHYData.GetStockName: string;
var nIdx: Integer;
begin
  Result := '';
  if cbb_Stock.ItemIndex < 1 then Exit;

  nIdx := NativeInt(cbb_Stock.Items.Objects[cbb_Stock.ItemIndex);
  Result := FStockList[nIdx.FValue;
end;

function TfFrameHYData.InitFormDataSQL(const nWhere: string): string;
var nStr, nNo, nWH: string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd));

    nStr := 'Select R_SerialNo,P_Type,P_Stock,P_Name,P_QLevel From $SR sr ' +
            ' Left Join $SP sp on sp.P_ID=sr.R_PID';
    nStr := MacroValue(nStr, [MI('$SR', sTable_StockRecord),
            MI('$SP', sTable_StockParam));
    //检验记录

    Result := 'Select hy.*,sr.*,C_PY,C_Name,sl.S_ID, sl.S_Name From $HY hy ' +
              ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
              ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
              ' Left Join S_Salesman sl on sl.S_ID=cus.C_SaleMan ' +
              'Where H_EachTruck Is Null And (H_ReportDate>=''$Start'' and H_ReportDate<''$End'')';
    //xxxxx

    if FWhere <> '' then
    begin
      Result := Result + ' And (' + FWhere + ')';
    end;

    nNo := GetStockName;
    if nNo <> '' then
      Result := Result + ' And (P_Stock Like ''%%$No%%'' )';
    //xxxxx

    if (Not UniMainModule.FUserConfig.FIsAdmin) then
    begin
      if HasPopedom2(sPopedom_ViewMYCusData, FPopedom) then
        Result := Result + 'And (S_Name='''+ UniMainModule.FUserConfig.FUserID +''')';
    end;

    Result := MacroValue(Result, [MI('$HY', sTable_StockHuaYan),
              MI('$Cus', sTable_Customer), MI('$SR', nStr), MI('$No', nNo),
              MI('$Start', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1)));
    //xxxxx
  end;
end;

//Desc: 日期筛选
procedure TfFrameHYData.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameHYData.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'C_PY like ''%%%s%%'' Or C_Name like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'H_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameHYData.cbb_StockChange(Sender: TObject);
begin
  InitFormData(FWhere);
end;

procedure TfFrameHYData.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

procedure TfFrameHYData.MenuItemN1Click(Sender: TObject);
var nStr : string;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要打印的记录');
    Exit;
  end;

  nStr := ClientDS.FieldByName('H_ID').AsString;
  PrintHuaYanReport(nStr);
end;

procedure TfFrameHYData.OnDateResult(const nValue: string);
var nStr: string;
begin
  FValue := nValue;

  nStr := 'Update %s Set H_CusName=''%s'' Where H_ID=''%s''';
  nStr := Format(nStr, [sTable_StockHuaYan, FValue, FBillId);

  DBExecute(nStr, nil, FDBType);

  ShowMessage('开单客户名称修改成功');
  InitFormData('');
end;

procedure TfFrameHYData.N2Click(Sender: TObject);
var nBillId, nCusName, nCusNameOld, nStr: string;
    nForm: TUniForm;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要打印的记录');
    Exit;
  end;

  nBillId := ClientDS.FieldByName('H_ID').AsString;
  if nBillId<>'' then
  begin
    nCusNameOld:= ClientDS.FieldByName('H_CusName').AsString;
    FBillId    := ClientDS.FieldByName('H_ID').AsString;

    ShowInputBoxForm('请输入开单客户名称:', '修改', OnDateResult, 200)
  end;
end;

procedure TfFrameHYData.OnDateTimeFilter(const nStart,nEnd: TDate);
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
  RegisterClass(TfFrameHYData);
end.
