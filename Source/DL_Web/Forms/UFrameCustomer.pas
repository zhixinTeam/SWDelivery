{*******************************************************************************
  作者: dmzn@163.com 2018-04-25
  描述: 客户管理
*******************************************************************************}
unit UFrameCustomer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, uniGUITypes,
  UFrameBase, Vcl.Menus, uniMainMenu, uniLabel, uniEdit, Data.DB,
  Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, frxClass,
  frxExportPDF, frxDBSet;

type
  TfFrameCustomer = class(TfFrameBase)
    EditName: TUniEdit;
    UniLabel1: TUniLabel;
    PMenu1: TUniPopupMenu;
    N1: TUniMenuItem;
    N2: TUniMenuItem;
    N3: TUniMenuItem;
    N4: TUniMenuItem;
    N5: TUniMenuItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  uniGUIVars, MainModule, uniGUIApplication, uniGUIForm, UFormBase, ULibFun,
  UManagerGroup, USysBusiness, USysDB, USysConst, USysRemote, UBusinessPacker,
  UFormGetWXAccount;

function TfFrameCustomer.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper do
  begin
    Result := 'Select cus.*,S_Name From $Cus cus' +
              ' Left Join $Sale On S_ID=cus.C_SaleMan';
    //xxxxx

    if nWhere = '' then
         Result := Result + ' Where C_XuNi<>''$Yes'''
    else Result := Result + ' Where (' + nWhere + ')';

    Result := MacroValue(Result, [MI('$Cus', sTable_Customer),
              MI('$Sale', sTable_Salesman), MI('$Yes', sFlag_Yes));
    //xxxxx
  end;
end;

procedure TfFrameCustomer.BtnAddClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  nForm := SystemGetForm('TfFormCutomer', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_AddData;
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

procedure TfFrameCustomer.BtnEditClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  nForm := SystemGetForm('TfFormCutomer', True);
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

procedure TfFrameCustomer.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
    nList: TStrings;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要删除的记录');
    Exit;
  end;

  nStr := ClientDS.FieldByName('C_Name').AsString;
  nStr := Format('确定要删除名称为[ %s 的客户吗?', [nStr);
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    begin
      if Res <> mrYes then Exit;
      //cancel

      nList := nil;
      try
        nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
        nStr := ClientDS.FieldByName('C_ID').AsString;

        nSQL := 'Delete From %s Where C_ID=''%s''';
        nSQL := Format(nSQL, [sTable_Customer, nStr);
        nList.Add(nSQL);

        nSQL := 'Delete From %s Where I_Group=''%s'' and I_ItemID=''%s''';
        nSQL := Format(nSQL, [sTable_ExtInfo, sFlag_CustomerItem, nStr);
        nList.Add(nSQL);

        DBExecute(nList, nil, FDBType);
        gMG.FObjectPool.Release(nList);
        nList := nil;

        InitFormData(FWhere);
        ShowMessage('已成功删除记录');
      except
        on nErr: Exception do
        begin
          gMG.FObjectPool.Release(nList);
          ShowMessage('删除失败: ' + nErr.Message);
        end;
      end;
    end);
  //xxxxx
end;

procedure TfFrameCustomer.EditNameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameCustomer.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

//Desc: 快捷菜单
procedure TfFrameCustomer.N1Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    10: FWhere := Format('C_XuNi=''%s''', [sFlag_Yes);
    20: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

//Desc: 关联微信
procedure TfFrameCustomer.N4Click(Sender: TObject);
var nStr,nID,nAccount,nBindID: string;
    nList: TStrings;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要开通的记录');
    Exit;
  end;

  nAccount := ClientDS.FieldByName('C_WeiXin').AsString;
  if nAccount <> '' then
  begin
    ShowMessage('商城账户[' + nAccount + '已存在');
    Exit;
  end;

  ShowGetWXAccountForm(nAccount,
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      nList := nil;
      try
        nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
        nBindID  := nParam.FParamB;
        nAccount := nParam.FParamC;
        nID      := ClientDS.FieldByName('C_ID').AsString;

        with nList do
        begin
          Values['Action'   := 'add';
          Values['BindID'   := nBindID;
          Values['Account'  := nAccount;
          Values['CusID'    := nID;
          Values['CusName'  := ClientDS.FieldByName('C_Name').AsString;
          Values['Memo'     := sFlag_Sale;
        end;

        if edit_shopclients(PackerEncodeStr(nList.Text)) <> sFlag_Yes then Exit;
        //call remote

        nStr := 'update %s set C_WeiXin=''%s'' where C_ID=''%s''';
        nStr := Format(nStr,[sTable_Customer, nAccount, nID);
        DBExecute(nStr, nil, FDBType);

        ShowMessage('关联商城账户成功');
        InitFormData(FWhere);
      finally
        gMG.FObjectPool.Release(nList);
      end;
    end);
  //xxxxx
end;

//Desc: 取消关联商城账户
procedure TfFrameCustomer.N5Click(Sender: TObject);
var nStr,nID,nName,nAccount:string;
    nList: TStrings;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要取消的记录');
    Exit;
  end;

  nName := ClientDS.FieldByName('C_Name').AsString;
  nStr := Format('确定要取消[ %s 的商城账户吗?', [nName);
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    begin
      if Res <> mrYes then Exit;
      //cancel

      nList := nil;
      try
        nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
        nID := ClientDS.FieldByName('C_ID').AsString;
        nAccount := ClientDS.FieldByName('C_WeiXin').AsString;

        with nList do
        begin
          Values['Action'   := 'del';
          Values['Account'  := nAccount;
          Values['CusID'    := nID;
          Values['CusName'  := nName;
          Values['Memo'     := sFlag_Sale;
        end;

        if edit_shopclients(PackerEncodeStr(nList.Text)) <> sFlag_Yes then Exit;
        //call remote

        nStr := 'update %s set C_WeiXin=Null where C_ID=''%s''';
        nStr := Format(nStr,[sTable_Customer, nID);
        DBExecute(nStr, nil, FDBType);

        ShowMessage('取消商城关联成功！');
        InitFormData(FWhere);
      finally
        gMG.FObjectPool.Release(nList);
      end;
    end);
  //xxxxx
end;

initialization
  RegisterClass(TfFrameCustomer);
end.
