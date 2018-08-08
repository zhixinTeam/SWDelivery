{*******************************************************************************
  作者: dmzn@163.com 2018-05-25
  描述: 关联微信账户
*******************************************************************************}
unit UFormGetWXAccount;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  uniGUITypes, uniGUIForm, USysConst, UFormBase, uniBasicGrid, uniStringGrid,
  uniRadioButton, uniGUIClasses, uniCheckBox, uniPanel, Vcl.Controls, Vcl.Forms,
  uniGUIBaseClasses, uniButton, uniEdit, uniLabel, uniTimer;

type
  TWechatCustomer = record
    FBindID   : string;   //绑定客户id
    FCusName  : string;   //登录账号
    FEmail    : string;   //邮箱
    FPhone    : string;   //手机号码
    FSelected : Boolean;  //选中状态
  end;

  TWechatCustomers = array of TWechatCustomer;
  //账户列表

  TfFormGetWXAccount = class(TfFormBase)
    Grid1: TUniStringGrid;
    UniSimplePanel1: TUniSimplePanel;
    UniLabel1: TUniLabel;
    EditID: TUniEdit;
    BtnFind: TUniButton;
    UniTimer1: TUniTimer;
    procedure EditIDChange(Sender: TObject);
    procedure UniTimer1Timer(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure Grid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    { Private declarations }
    FUsers: TWechatCustomers;
    //用户清单
    FRowSelected: Integer;
    //选中行号
    procedure LoadCustomerList;
    procedure LoadCustomer(nFilter: string);
    //加载用户
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
  end;

procedure ShowGetWXAccountForm(const nCusID: string;
  const nResult: TFormModalResult);
//入口函数

implementation

{$R *.dfm}

uses
  System.IniFiles, Vcl.Grids, uniGUIVars, MainModule, uniGUIApplication,
  UManagerGroup, ULibFun, UBusinessPacker, USysBusiness, USysRemote, USysDB;

const
  giID    = 0;
  giMail  = 1;
  giPhone  = 2;
  //grid info:表格列数据描述

//Date: 2018-05-25
//Parm: 客户编号;结果回调
//Desc: 显示微信关联窗口
procedure ShowGetWXAccountForm(const nCusID: string;
  const nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormGetWXAccount', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormGetWXAccount do
  begin
    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result <> mrOk then Exit;
        FParam.FParamB := FUsers[FRowSelected].FBindID;
        FParam.FParamC := FUsers[FRowSelected].FCusName;
        nResult(mrOk, @FParam);
      end);
    //xxxxx
  end;
end;

procedure TfFormGetWXAccount.OnCreateForm(Sender: TObject);
var nIni: TIniFile;
begin
  FRowSelected := -1;
  ActiveControl := EditID;

  with Grid1 do
  begin
    FixedCols := 0;
    RowCount := 0;
    ColCount := 3;
    Options := [goVertLine,goHorzLine,goDrawFocusSelected];
  end;

  nIni := nil;
  try
    nIni := UserConfigFile;
    LoadFormConfig(Self, nIni);
    UserDefineStringGrid(Name, Grid1, True, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormGetWXAccount.OnDestroyForm(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := UserConfigFile;
    SaveFormConfig(Self, nIni);
    UserDefineStringGrid(Name, Grid1, False, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormGetWXAccount.UniTimer1Timer(Sender: TObject);
begin
  Editid.Text := '';
  BtnFind.JSInterface.JSCall('fireEvent', ['click', BtnFind]);
  //调用远程代码,显示进度并执行click操作
end;

procedure TfFormGetWXAccount.BtnOKClick(Sender: TObject);
begin
  if FRowSelected < 0 then
       ShowMessage('请选择有效账户')
  else ModalResult := mrOk;
end;

procedure TfFormGetWXAccount.EditIDChange(Sender: TObject);
begin
  LoadCustomer(EditID.Text);
end;

procedure TfFormGetWXAccount.Grid1SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var nIdx : Integer;
begin
  for nIdx:=Low(FUsers) to High(FUsers) do
    if FUsers[nIdx].FPhone=Grid1.Cells[giPhone, ARow] then
      FRowSelected:= nIdx;
end;

//------------------------------------------------------------------------------
//Desc: 加载选中的客户
procedure TfFormGetWXAccount.LoadCustomerList;
var nIdx,nRow: Integer;
begin
  Grid1.BeginUpdate;
  try
    nRow := 0;
    for nIdx:=Low(FUsers) to High(FUsers) do
      if FUsers[nIdx].FSelected then Inc(nRow);
    Grid1.RowCount := nRow;

    nRow := 0;
    for nIdx:=Low(FUsers) to High(FUsers) do
     with FUsers[nIdx] do
      if FSelected then
      begin
        Grid1.Cells[giID, nRow]    := FCusName;
        Grid1.Cells[giMail, nRow]  := FEmail;
        Grid1.Cells[giPhone, nRow] := FPhone;
        Inc(nRow);
      end;
    //xxxxx
  finally
    Grid1.EndUpdate;
  end;
end;

procedure TfFormGetWXAccount.LoadCustomer(nFilter: string);
var nIdx,nInt: Integer;
    nListA,nListB: TStrings;
begin
  FRowSelected := -1;
  nListA := nil;
  nListB := nil;

  if Length(FUsers) < 1 then
  try
    nListA := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nListB := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nListA.Text := getWXCustomerList('');

    nInt := 0;
    SetLength(FUsers, nListA.Count);

    for nIdx:=0 to nListA.Count-1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      with FUsers[nInt],nListB do
      begin
        FBindID   := Values['BindID'];
        FCusName  := Values['Name'];
        FPhone    := Values['Phone'];

        Inc(nInt);
      end;
    end;
  finally
    gMG.FObjectPool.Release(nListA);
    gMG.FObjectPool.Release(nListB);
  end;

  if Length(FUsers) > 0 then
  begin
    nFilter := LowerCase(nFilter);
    //case

    for nIdx:=Low(FUsers) to High(FUsers) do
     with FUsers[nIdx] do
      FSelected := (nFilter = '') or
                   (Pos(nFilter, LowerCase(FCusName)) > 0) or
                   (Pos(nFilter, LowerCase(FPhone)) > 0);
    //set item status

    LoadCustomerList;
    //load ui
  end;
end;

initialization
  RegisterClass(TfFormGetWXAccount);
end.
