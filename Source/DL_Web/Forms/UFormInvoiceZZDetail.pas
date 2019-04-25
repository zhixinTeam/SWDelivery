{*******************************************************************************
  作者:  2018-09-07
  描述: 扎帐明细（发货记录）
*******************************************************************************}
unit UFormInvoiceZZDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, uniGUIForm, UFormBase, Vcl.Menus, uniMainMenu,
  Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniGUIBaseClasses, uniButton, uniCheckBox, uniLabel;

type
  TfFormInvoiceZZDetail = class(TfFormBase)
    ClientDS1: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TUniDBGrid;
    Chk_All: TUniCheckBox;
    UnLblChk: TUniLabel;
    UnLblTotal: TUniLabel;
    procedure DBGrid1CellClick(Column: TUniDBGridColumn);
    procedure Chk_AllClick(Sender: TObject);
    function  ChoiceBill(const nBill, nChk: string): Boolean;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FCreditChanged: Boolean;
    //变动
    Fwhere, FChk, FUnChk : string;
    FCanEdit:Boolean;
  private
    procedure LoadDetail(const nWhere: string);
    //加载明细
    procedure ArrangeColum;
    procedure GetSelectedBill(const nList: TStrings);
    procedure RefTotal;
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
    procedure ArrangeGridCTL;
  end;

  TFormCreditDetailResult = procedure (const nChanged: Boolean) of object;
  //结果回调

procedure ShowInvoiceZZDetailForm(const nWhere,nCanEdit,nPopedom: string;
  const nResult: TFormCreditDetailResult);
//入口函数

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication,
  UManagerGroup, ULibFun, USysBusiness, USysDB, USysConst;

//Date: 2018-05-07
//Parm: 客户编号
//Desc: 显示客户信用变动窗口
procedure ShowInvoiceZZDetailForm(const nWhere, nCanEdit,nPopedom: string;
  const nResult: TFormCreditDetailResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormInvoiceZZDetail', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormInvoiceZZDetail do
  begin
    FCanEdit:= False;
    FParam.FParamA := nWhere;
    LoadDetail(nWhere);    Fwhere:= nWhere;
    FCanEdit:= nCanEdit='';
    //load data

    FChk:= ''; FUnChk:= '';
    DBGrid1.LoadMask.Enabled:= False;

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        nResult(FCreditChanged);
      end);
  end;
end;

procedure TfFormInvoiceZZDetail.ArrangeGridCTL;
begin
  with DBGrid1 do
  begin
    if UniMainModule.FGridColumnAdjust then
         Options := Options + [dgMultiSelect
    else Options := Options + [dgEditing, dgMultiSelect;
  end;
end;

procedure TfFormInvoiceZZDetail.BtnOKClick(Sender: TObject);
begin
  if not ClientDS1.Active then Exit;
  if ClientDS1.RecordCount=0 then Exit;
  with ClientDS1 do
  begin
    DisableControls;
    try
      First;
      while not Eof do
      begin
        if (FieldByName('R_Chk').AsBoolean) then
        begin
          if FChk='' then
              FChk:= FieldByName('R_ID').AsString
          else FChk:= FChk + ',' + FieldByName('R_ID').AsString;
        end
        else
        begin
          if FUnChk='' then
              FUnChk:= FieldByName('R_ID').AsString
          else FUnChk:= FUnChk + ',' + FieldByName('R_ID').AsString;
        end;

        Next;
      end;
    finally
      EnableControls;
    end;
  end;
  //*************************
  ChoiceBill(FChk, '1');
  ChoiceBill(FUnChk, '0');
  close;
end;

procedure TfFormInvoiceZZDetail.Chk_AllClick(Sender: TObject);
begin
  if not ClientDS1.Active then Exit;
  if ClientDS1.RecordCount=0 then Exit;
  with ClientDS1 do
  begin
    First;
    while not Eof do
    begin
      Edit;
      ClientDS1.FieldByName('R_Chk').AsBoolean:= Chk_All.Checked;
      Post;
      Next;
    end;
  end;
end;

function TfFormInvoiceZZDetail.ChoiceBill(const nBill, nChk: string): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  Result := False;
  if nBill='' then Exit;
  if DBGrid1.SelectedRows.Count < 1 then Exit;

  nStr := 'UPDate %s Set R_Chk=''%s'' Where R_ID In (%s) ';
  nStr := Format(nStr, [sTable_InvoiceReq, nChk, nBill);

  DBExecute(nStr, nil, FDBType);
  Result := True;
end;

procedure TfFormInvoiceZZDetail.RefTotal;
var nChkTotal, nTotal:Double;
    nPi : Integer;
begin
  if not ClientDS1.Active then Exit;
  if ClientDS1.RecordCount=0 then Exit;
  //**********
  nChkTotal:= 0;  nTotal:= 0;
  with ClientDS1 do
  begin
    nPi:= RecNo;
    DisableControls;
    try
      First;
      while not Eof do
      begin
        nTotal:= nTotal + FieldByName('R_Value').AsFloat;

        if (FieldByName('R_Chk').AsBoolean) then
          nChkTotal:= nChkTotal + FieldByName('R_Value').AsFloat;

        Next;
      end;
    finally
      EnableControls;
      RecNo:= nPi;
      UnLblChk.Caption:= Format('已选择：%.2f 吨', [nChkTotal);
      UnLblTotal.Caption := Format('总数：%.2f 吨', [nTotal);
    end;
  end;
end;

procedure TfFormInvoiceZZDetail.DBGrid1CellClick(Column: TUniDBGridColumn);
begin
  inherited;
  if not ClientDS1.Active then Exit;
  if ClientDS1.RecordCount=0 then Exit;
  if not FCanEdit then
  begin
    ShowMessage('该记录所属周期返利已生效、禁止更改');
    Exit;
  end;

  try
    ClientDS1.Edit;
    ClientDS1.FieldByName('R_Chk').AsBoolean:= not ClientDS1.FieldByName('R_Chk').AsBoolean;
    ClientDS1.Post;
  finally
    FCreditChanged:= True;
    RefTotal;
  end;
end;

procedure TfFormInvoiceZZDetail.OnCreateForm(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    FCreditChanged := False;
    nIni := UserConfigFile();
    LoadFormConfig(Self, nIni);

    BuildDBGridColumn('InvoiceZZDtl', DBGrid1);
    DBGrid1.BorderStyle := ubsNone;
    UserDefineGrid(ClassName, DBGrid1, True, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormInvoiceZZDetail.OnDestroyForm(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := UserConfigFile();
    SaveFormConfig(Self, nIni);
    UserDefineGrid(ClassName, DBGrid1, False, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormInvoiceZZDetail.ArrangeColum;
var nIdx, nDay : Integer;
begin
  try
    DBGrid1.Columns.BeginUpdate;
    for nIdx := 0 to DBGrid1.Columns.Count-1 do
      if (DBGrid1.Columns[nIdx.Title.Caption='选择') then
      begin
        DBGrid1.Columns[nIdx.Alignment:= taLeftJustify;

        DBGrid1.Columns[nIdx.CheckBoxField.Enabled:= True;
        DBGrid1.Columns[nIdx.CheckBoxField.FieldValues:='1;0';
        DBGrid1.Columns[nIdx.CheckBoxField.DisplayValues:=' √ ;';
      end;
  finally
    DBGrid1.Columns.EndUpdate;
    RefTotal;
  end;
end;

//Desc: 获取选中记录
procedure TfFormInvoiceZZDetail.GetSelectedBill(const nList: TStrings);
var nIdx: Integer;
    nBK: TBookmark;
begin
  nList.Clear;
  nBK := nil;
  try
    ClientDS1.DisableControls;
    nBK := ClientDS1.GetBookmark;
    //backup

    for nIdx:=DBGrid1.SelectedRows.Count - 1 downto 0 do
    begin
      ClientDS1.Bookmark := DBGrid1.SelectedRows[nIdx;
      nList.Add(ClientDS1.FieldByName('R_ID').AsString);
    end;
  finally
    if Assigned(nBK) then
    begin
      if ClientDS1.BookmarkValid(nBK) then
        ClientDS1.GotoBookmark(nBK); //restore
      ClientDS1.FreeBookmark(nBK);
    end;
    ClientDS1.EnableControls;
  end;
end;

procedure TfFormInvoiceZZDetail.LoadDetail(const nWhere: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;   ArrangeGridCTL;
  try
    nStr := 'Select req.*, W_Name, Z_Name, Z_Project From $Req req ' +
              ' Left Join $Week On W_NO=req.R_Week ' +
              ' Left Join $ZK On Z_ID=req.R_ZhiKa ';

    nStr := nStr + ' Where ' + nWhere ;
    nStr := nStr + ' Order by R_OutFact ';
    //xxxxx

    with TStringHelper,TDateTimeHelper do
      nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq),
                MI('$Week', sTable_InvoiceWeek), MI('$ZK', sTable_ZhiKa));
    //xxxxx

    nQuery := LockDBQuery(FDBType);
    DBQuery(nStr, nQuery, ClientDS1);
    SetGridColumnFormat('InvoiceZZDtl', ClientDS1, UniMainModule.DoColumnFormat);
  finally
    ReleaseDBQuery(nQuery);
    ArrangeColum;
  end;
end;

//------------------------------------------------------------------------------
initialization
  RegisterClass(TfFormInvoiceZZDetail);
end.
