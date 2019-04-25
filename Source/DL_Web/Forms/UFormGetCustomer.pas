{*******************************************************************************
  作者: dmzn@163.com 2018-05-13
  描述: 检索客户
*******************************************************************************}
unit UFormGetCustomer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, USysConst,
  uniGUIForm, UFormBase, Data.DB, Datasnap.DBClient, uniEdit, uniLabel,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, Vcl.Controls, Vcl.Forms,
  uniGUIBaseClasses, uniButton;

type
  TfFormGetCustomer = class(TfFormBase)
    ClientDS1: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TUniDBGrid;
    PanelTop: TUniSimplePanel;
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Btn1: TUniButton;
    procedure BtnOKClick(Sender: TObject);
    procedure Btn1Click(Sender: TObject);
    procedure EditCustomerKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure FindCustomer(const nCusName: string);
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

procedure ShowGetCustomerForm(const nCusName: string;
 const nResult: TFormModalResult);
//入口函数

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, System.IniFiles,
  ULibFun, USysBusiness, USysDB;

//Date: 2018-05-04
//Parm: 客户名称;结果回调
//Desc: 显示客户查询窗口
procedure ShowGetCustomerForm(const nCusName: string;
  const nResult: TFormModalResult);
var nForm: TUniForm;
    nParm: TFormCommandParam;
begin
  nForm := SystemGetForm('TfFormGetCustomer', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormGetCustomer do
  begin
    if nCusName <> '' then
    begin
      nParm.FCommand := cCmd_GetData;
      nParm.FParamA := nCusName;
      SetParam(nParm);
    end;

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
        with nParm,ClientDS1 do
        begin
          FParamA := FieldByName('C_ID').AsString;
          FParamB := FieldByName('C_Name').AsString;
          FParamC := FieldByName('S_ID').AsString;
          FParamD := FieldByName('S_Name').AsString;

          nResult(Result, @nParm);
        end;
      end);
    //xxxxx
  end;
end;

procedure TfFormGetCustomer.OnCreateForm(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    ActiveControl := EditCustomer;
    nIni := UserConfigFile();
    LoadFormConfig(Self, nIni);

    BuildDBGridColumn('', DBGrid1);
    UserDefineGrid(ClassName, DBGrid1, True, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormGetCustomer.OnDestroyForm(Sender: TObject);
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

function TfFormGetCustomer.SetParam(const nParam: TFormCommandParam): Boolean;
begin
  Result := inherited SetParam(nParam);
  FindCustomer(nParam.FParamA);
end;

//Date: 2018-05-13
//Parm: 客户名称
//Desc: 检索数据
procedure TfFormGetCustomer.FindCustomer(const nCusName: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  EditCustomer.Text := nCusName;

  with TStringHelper do
  try
    nStr := 'Select cus.R_ID,C_ID,C_Name,S_ID,S_Name from $Cus cus ' +
            '  Left Join $SM sm On sm.S_ID=cus.C_SaleMan ' +
            'Where C_PY like ''%$ID%'' or C_Name like ''%$ID%'' or ' +
            '  C_ID like ''%$ID%''';
    nStr := MacroValue(nStr, [MI('$Cus', sTable_Customer),
            MI('$SM', sTable_Salesman), MI('$ID', nCusName));
    //xxxxx

    nQuery := LockDBQuery(FDBType);
    DBQuery(nStr, nQuery, ClientDS1);
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormGetCustomer.EditCustomerKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    Btn1.Click;
  end;
end;

procedure TfFormGetCustomer.Btn1Click(Sender: TObject);
begin
  EditCustomer.Text := Trim(EditCustomer.Text);
  if EditCustomer.Text <> '' then
    FindCustomer(EditCustomer.Text);
  //xxxxx
end;

procedure TfFormGetCustomer.BtnOKClick(Sender: TObject);
begin
  if (not ClientDS1.Active) or (ClientDS1.RecordCount < 1) then
  begin
    ShowMessage('请先查询');
    Exit;
  end;

  ModalResult := mrOk;
end;

initialization
  RegisterClass(TfFormGetCustomer);
end.
