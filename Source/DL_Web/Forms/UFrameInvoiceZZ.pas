{*******************************************************************************
  作者: dmzn@163.com 2018-05-16
  描述: 销售扎帐
*******************************************************************************}
unit UFrameInvoiceZZ;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  uniGUIForm, UFrameBase, Vcl.Menus, uniMainMenu, uniButton, uniBitBtn, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniPanel, uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, frxClass,
  frxExportPDF, frxDBSet;

type
  TfFrameInvoiceZZ = class(TfFrameBase)
    PMenu1: TUniPopupMenu;
    MenuItem1: TUniMenuItem;
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Label3: TUniLabel;
    EditWeek: TUniEdit;
    BtnWeekFilter: TUniBitBtn;
    N1: TUniMenuItem;
    N2: TUniMenuItem;
    N3: TUniMenuItem;
    unmntmN4: TUniMenuItem;
    unmntmN5: TUniMenuItem;
    procedure EditCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnWeekFilterClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
    procedure unmntmN5Click(Sender: TObject);
  private
    { Private declarations }
    FNowYear,FNowWeek,FWeekName: string;
    //当前周期
    procedure LoadWeek;
    //获取周期
  private
    procedure OnInvoiceZZDetailDetail(const nChanged: Boolean);
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  ULibFun, USysBusiness, USysDB, USysConst, UFormBase, UFormInvoiceGetWeek,
  UFormInvoiceZZAll, UFormSysLog, UFormInvoiceZZDetail;

procedure TfFrameInvoiceZZ.OnCreateFrame(const nIni: TIniFile);
begin
  FEntity := 'SW_ZHAZHANG';
  MenuItem1.Enabled := BtnEdit.Enabled;

  FNowYear := '';
  FNowWeek := '';
  FWeekName := '';
  LoadWeek;
end;

procedure TfFrameInvoiceZZ.OnInvoiceZZDetailDetail(const nChanged: Boolean);
begin
  if nChanged then InitFormData(FWhere);
end;

procedure TfFrameInvoiceZZ.unmntmN5Click(Sender: TObject);
var nStr, nCanEdit: string;
begin
  nCanEdit:= '';
  if DBGridMain.SelectedRows.Count > 0 then
  begin
    with ClientDS do
    begin
      if FieldByName('R_Value').AsString=FieldByName('R_KValue').AsString then
      begin
        nCanEdit:= 'N';
      end;
    end;

    nStr := Format(' R_Week=''%s'' And  R_CusID=''%s'' And  R_SaleID=''%s'' And  R_Type=''%s'' And  R_Stock=''%s''  '+
                   ' And  R_Price=''%s'' And  R_YunFei=''%s'' And  R_ZhiKa=''%s'' ',

                        [ClientDS.FieldByName('R_Week').AsString,
                        ClientDS.FieldByName('R_CusID').AsString,
                        ClientDS.FieldByName('R_SaleID').AsString,
                        ClientDS.FieldByName('R_Type').AsString,
                        ClientDS.FieldByName('R_Stock').AsString,
                        ClientDS.FieldByName('R_Price').AsString,
                        ClientDS.FieldByName('R_YunFei').AsString,
                        ClientDS.FieldByName('R_ZhiKa').AsString   );
    /////*****
    ShowInvoiceZZDetailForm(nStr, nCanEdit, FPopedom, OnInvoiceZZDetailDetail);
  end;
end;

function TfFrameInvoiceZZ.FilterColumnField: string;
begin
  Result := 'R_KMoney;R_KMan;R_KDate';
end;

function TfFrameInvoiceZZ.InitFormDataSQL(const nWhere: string): string;
var nInt: Integer;
    nStr,nWeek: string;
begin
  with TStringHelper,TDateTimeHelper do
  begin
    if (FNowYear = '') and (FNowWeek = '') then
    begin
      Result := '';
      EditWeek.Text := '请选择结算周期'; Exit;
    end else
    begin
      nStr := '年份:[ %s  周期:[ %s ';
      EditWeek.Text := Format(nStr, [FNowYear, FWeekName);

      if FNowWeek = '' then
      begin
        nWeek := 'Where (W_Begin>=''$S'' and ' +
                 'W_Begin<''$E'') or (W_End>=''$S'' and W_End<''$E'') ' +
                 'Order By W_Begin';
        nInt := StrToInt(FNowYear);

        nWeek := MacroValue(nWeek, [MI('$W', sTable_InvoiceWeek),
                MI('$S', IntToStr(nInt)), MI('$E', IntToStr(nInt+1)));
        //xxxxx
      end else
      begin
        nWeek := Format('Where R_Week=''%s''', [FNowWeek);
      end;
    end;

    nWeek := nWeek + ' AND R_Chk=1 ';

    //Result := 'Select req.*, W_Name, Z_Name, Z_Project From $Req req ' +
    Result := 'Select ROW_NUMBER() over(order by R_CusID) as R_ID, x.* From (  ' +
                'Select R_Week, R_CusID, R_Customer, R_SaleID, R_SaleMan, R_Type, R_Stock, R_Price, SUM(R_Value) R_Value, R_PreHasK, '+
                'R_ReqValue, IsNull(R_KPrice, 0) R_KPrice,SUM(R_KValue) R_KValue, R_KOther, R_Man, R_Date, R_CusPY, R_StockName, R_ZhiKa, R_YunFei, R_KMan, R_KDate, '+
                'R_KYunFei, W_Name,Z_Name,Z_Project From $Req  req ' +

                ' Left Join $Week On W_NO=req.R_Week ' +
                ' Left Join $ZK On Z_ID=req.R_ZhiKa  ';

    Result := Result + nWeek;

    if nWhere <> '' then
      Result := Result + ' And ( ' + nWhere + ' )';
    //xxxxx

    Result := Result +
              ' Group  by  R_Week, R_CusID, R_Customer, R_SaleID, R_SaleMan, R_Type, R_Stock, R_Price, R_PreHasK, R_ReqValue, '+
              'R_KPrice, R_KOther, R_Man, R_Date, R_CusPY, R_StockName, R_ZhiKa, R_YunFei, R_KMan, R_KDate, R_KYunFei,'+
              ' W_Name,Z_Name,Z_Project  ) x';


    Result := MacroValue(Result, [MI('$Req', sTable_InvoiceReq),
              MI('$Week', sTable_InvoiceWeek), MI('$ZK', sTable_ZhiKa));
    //xxxxx
  end;
end;

//Desc: 载入默认周期
procedure TfFrameInvoiceZZ.LoadWeek;
var nParam: TFormCommandParam;
begin
  with nParam do
  begin
    FCommand := cCmd_GetData;
    FParamA := FNowYear;
    FParamB := FNowWeek;
  end;

  ShowInvoiceGetWeekForm(nParam,
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      FNowYear := nParam.FParamA;
      FNowWeek := nParam.FParamB;
      FWeekName := nParam.FParamC;

      FWhere:= '';
      InitFormData(FWhere);
    end);
  //xxxxx
end;

procedure TfFrameInvoiceZZ.BtnAddClick(Sender: TObject);
begin
  ShowInvoiceZZAllForm(FNowYear, FNowWeek, FWeekName,
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      FNowYear := nParam.FParamA;
      FNowWeek := nParam.FParamB;
      FWeekName := nParam.FParamC;

      FWhere := '';
      InitFormData(FWhere);
    end);
  //xxxxx
end;

//Desc: 修改价差
procedure TfFrameInvoiceZZ.BtnEditClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
    nCusId, nCusName, nZhiKa, nWeek, nStockId,
    nPrice, nType, nSaleId, nYunFei, nWhere : string;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  with ClientDS do
  begin
    if FieldByName('R_KValue').AsFloat>0 then
    begin
      ShowMessage('该周期返利已生效、不能修改');
      Exit;
    end;
  end;
  //************
  nForm := SystemGetForm('TfFormInvoiceFLSet', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_EditData;

  nCusId := ClientDS.FieldByName('R_CusID').AsString;
  nCusName:= ClientDS.FieldByName('R_Customer').AsString;
  nZhiKa := ClientDS.FieldByName('R_ZhiKa').AsString;
  nWeek  := ClientDS.FieldByName('R_Week').AsString;
  nStockId := ClientDS.FieldByName('R_Stock').AsString;
  nPrice   := ClientDS.FieldByName('R_Price').AsString;
  nType    := ClientDS.FieldByName('R_Type').AsString;
  nSaleId  := ClientDS.FieldByName('R_SaleID').AsString;
  nYunFei  := ClientDS.FieldByName('R_YunFei').AsString;

  nWhere:= Format('R_CusID=''%s'' And R_Customer=''%s'' And R_ZhiKa=''%s'' And R_Week=''%s'' And R_Stock=''%s'' And R_Price=''%s'' '+
                  'And R_Type=''%s'' And R_SaleID=''%s'' And R_YunFei=''%s''', [nCusId, nCusName, nZhiKa, nWeek, nStockId,
                                  nPrice, nType, nSaleId, nYunFei);
  //*****************
  nParam.FParamA := nWhere;
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal(
    procedure(Sender: TComponent; Result:Integer)
    begin
      if Result = mrok then
        InitFormData(FWhere);
      //refresh
    end);
  //show form
end;

procedure TfFrameInvoiceZZ.BtnRefreshClick(Sender: TObject);
begin
  FWhere:= '';
  InitFormData(FWhere);
end;

//Desc: 选择周期
procedure TfFrameInvoiceZZ.BtnWeekFilterClick(Sender: TObject);
begin
  LoadWeek;
end;

procedure TfFrameInvoiceZZ.EditCustomerKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'R_CusPY Like ''%%%s%%'' Or R_Customer Like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameInvoiceZZ.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

//Desc: 价差修改记录
procedure TfFrameInvoiceZZ.N2Click(Sender: TObject);
var nStr: string;
    nParam: TFormCommandParam;
begin
  if DBGridMain.SelectedRows.Count > 0 then
  begin
    nParam.FCommand := cCmd_ViewSysLog;
    nParam.FParamA := '2008-08-08';
    nParam.FParamB := '2050-12-12';

    nParam.FParamC := ClientDS.FieldByName('R_ZhiKa').AsString;
    nStr := 'L_Group=''$Group'' And L_ItemID=''$ID''';
    with TStringHelper do
    nParam.FParamD := MacroValue(nStr, [MI('$Group', sFlag_ZhiKaItem),
                      MI('$ID', nParam.FParamC));
    //检索条件

    ShowSystemLog(nParam);
  end;
end;

//Desc: 未完成
procedure TfFrameInvoiceZZ.N3Click(Sender: TObject);
begin
  FWhere := '(R_Value<>R_KValue) And (R_KPrice <> 0)';
  InitFormData(FWhere);
end;

initialization
  RegisterClass(TfFrameInvoiceZZ);
end.
