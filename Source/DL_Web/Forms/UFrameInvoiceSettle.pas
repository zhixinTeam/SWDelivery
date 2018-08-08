{*******************************************************************************
  作者: dmzn@163.com 2018-05-19
  描述: 销售结算
*******************************************************************************}
unit UFrameInvoiceSettle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  uniGUIForm, UFrameBase, Vcl.Menus, uniMainMenu, uniButton, uniBitBtn, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniPanel, uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, frxClass,
  frxExportPDF, frxDBSet;

type
  TfFrameInvoiceSettle = class(TfFrameBase)
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
    procedure EditCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnWeekFilterClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
  private
    { Private declarations }
    FNowYear,FNowWeek,FWeekName: string;
    //当前周期
    procedure LoadWeek;
    //获取周期
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  ULibFun, USysBusiness, USysDB, USysConst, UFormBase, UFormInvoiceGetWeek,
  UFormSysLog, UFormInvoiceSettle;

procedure TfFrameInvoiceSettle.OnCreateFrame(const nIni: TIniFile);
begin
  FEntity := 'SW_ZHAZHANG';
  MenuItem1.Enabled := BtnEdit.Enabled;

  FNowYear := '';
  FNowWeek := '';
  FWeekName := '';
  LoadWeek;
end;

function TfFrameInvoiceSettle.InitFormDataSQL(const nWhere: string): string;
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
      nStr := '年份:[ %s ] 周期:[ %s ]';
      EditWeek.Text := Format(nStr, [FNowYear, FWeekName]);

      if FNowWeek = '' then
      begin
        nWeek := 'Where (W_Begin>=''$S'' and ' +
                 'W_Begin<''$E'') or (W_End>=''$S'' and W_End<''$E'') ' +
                 'Order By W_Begin';
        nInt := StrToInt(FNowYear);

        nWeek := MacroValue(nWeek, [MI('$W', sTable_InvoiceWeek),
                MI('$S', IntToStr(nInt)), MI('$E', IntToStr(nInt+1))]);
        //xxxxx
      end else
      begin
        nWeek := Format('Where R_Week=''%s''', [FNowWeek]);
      end;
    end;

    Result := 'Select req.*,((R_KPrice+R_KYunFei)*R_KValue) R_KMoney,W_Name,Z_Name,' +
              'Z_Project From $Req req ' +
              ' Left Join $Week On W_NO=req.R_Week ' +
              ' Left Join $ZK On Z_ID=req.R_ZhiKa ';
    Result := Result + nWeek;

    if nWhere <> '' then
      Result := Result + ' And ( ' + nWhere + ' )';
    //xxxxx

    Result := MacroValue(Result, [MI('$Req', sTable_InvoiceReq),
              MI('$Week', sTable_InvoiceWeek), MI('$ZK', sTable_ZhiKa)]);
    //xxxxx
  end;
end;

//Desc: 载入默认周期
procedure TfFrameInvoiceSettle.LoadWeek;
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
      InitFormData(FWhere);
    end);
  //xxxxx
end;

//Desc: 开始结算
procedure TfFrameInvoiceSettle.BtnAddClick(Sender: TObject);
var nStr: string;
    nBegin,nEnd: TDateTime;
    nQuery: TADOQuery;
begin
  if FNowWeek = '' then
  begin
    ShowMessage('请选择结算周期'); Exit;
  end;

  nQuery := nil;
  try
    if ClientDS.RecordCount < 1 then
    begin
      ShowMessage('没有需要结算的数据'); Exit;
    end;

    nQuery := LockDBQuery(FDBType);
    if not IsWeekValid(FNowWeek, nStr, nBegin, nEnd, nQuery) then
    begin
      ShowMessage(nStr); Exit;
    end;

    ShowInvoiceSettleForm(FNowYear, FNowWeek, FWeekName, nBegin, nEnd,
      procedure(const nResult: Integer; const nParam: PFormCommandParam)
      begin
        InitFormData(FWhere);
      end);
  //xxxxx
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Desc: 修改价差
procedure TfFrameInvoiceSettle.BtnEditClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  nForm := SystemGetForm('TfFormInvoiceFLSet', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := ClientDS.FieldByName('R_ID').AsString;
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

procedure TfFrameInvoiceSettle.BtnRefreshClick(Sender: TObject);
begin
  inherited;

end;

//Desc: 选择周期
procedure TfFrameInvoiceSettle.BtnWeekFilterClick(Sender: TObject);
begin
  LoadWeek;
end;

procedure TfFrameInvoiceSettle.EditCustomerKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'R_CusPY Like ''%%%s%%'' Or R_Customer Like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameInvoiceSettle.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

//Desc: 价差修改记录
procedure TfFrameInvoiceSettle.N2Click(Sender: TObject);
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
                      MI('$ID', nParam.FParamC)]);
    //检索条件

    ShowSystemLog(nParam);
  end;
end;

//Desc: 未完成
procedure TfFrameInvoiceSettle.N3Click(Sender: TObject);
begin
  FWhere := '(R_Value<>R_KValue) And (R_KPrice <> 0)';
  InitFormData(FWhere);
end;

initialization
  RegisterClass(TfFrameInvoiceSettle);
end.
