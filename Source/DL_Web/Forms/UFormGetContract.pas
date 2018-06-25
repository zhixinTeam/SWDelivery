{*******************************************************************************
  作者: dmzn@163.com 2018-05-04
  描述: 检索合同
*******************************************************************************}
unit UFormGetContract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, uniGUIForm,
  USysConst, UFormBase, Data.DB, Datasnap.DBClient, uniEdit, uniLabel,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, Vcl.Controls, Vcl.Forms,
  uniGUIBaseClasses, uniButton;

type
  TfFormGetContract = class(TfFormBase)
    ClientDS1: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TUniDBGrid;
    PanelTop: TUniSimplePanel;
    Label1: TUniLabel;
    EditContract: TUniEdit;
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Btn1: TUniButton;
    procedure EditContractEnter(Sender: TObject);
    procedure EditCustomerEnter(Sender: TObject);
    procedure Btn1Click(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditContractKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
  end;

function ShowGetContractForm(const nResult: TFormModalResult): Boolean;
//入口函数

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, System.IniFiles,
  ULibFun, USysBusiness, USysDB;

//Date: 2018-05-04
//Parm: 结果回调
//Desc: 显示合同查询窗口
function ShowGetContractForm(const nResult: TFormModalResult): Boolean;
var nForm: TUniForm;
begin
  Result := False;
  nForm := SystemGetForm('TfFormGetContract', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormGetContract do
  begin
    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
        with ClientDS1 do
        begin
          FParam.FParamA := FieldByName('C_ID').AsString;
          nResult(Result, @FParam);
        end;
      end);
    Result := True;
  end;
end;

procedure TfFormGetContract.OnCreateForm(Sender: TObject);
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

procedure TfFormGetContract.OnDestroyForm(Sender: TObject);
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

procedure TfFormGetContract.EditContractEnter(Sender: TObject);
begin
  Btn1.Top := EditContract.Top;
  Btn1.Tag := 10;
end;

procedure TfFormGetContract.EditContractKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    Btn1.Click;
  end;
end;

procedure TfFormGetContract.EditCustomerEnter(Sender: TObject);
begin
  Btn1.Top := EditCustomer.Top;
  Btn1.Tag := 20;
end;

procedure TfFormGetContract.Btn1Click(Sender: TObject);
var nStr: string;
    nQuery: TADOQuery;
begin
  if Btn1.Tag = 10 then
  begin
    EditContract.Text := Trim(EditContract.Text);
    if EditContract.Text = '' then
    begin
      ShowMessage('请输入合同编号');
      Exit;
    end;
  end else
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then
    begin
      ShowMessage('请输入客户名称');
      Exit;
    end;
  end;

  nQuery := nil;
  with TStringHelper do
  try
    nStr := 'Select sc.C_ID,C_Project,S_Name,C_Name From $SC sc ' +
            ' Left Join $SM sm On sm.S_ID=sc.C_SaleMan' +
            ' Left Join $Cus cus On cus.C_ID=sc.C_Customer ' +
            'Where IsNull(C_Freeze,'''')<>''$Yes''';
    //xxxxx

    if Btn1.Tag = 10 then
         nStr := nStr + ' And sc.C_ID Like ''%%$CID%%'''
    else nStr := nStr + ' And (cus.C_Name Like ''%%$CN%%''' +
                        ' Or cus.C_PY Like ''%%$CN%%'')';
    //xxxxx

    nStr := MacroValue(nStr, [MI('$SC', sTable_SaleContract),
          MI('$SM', sTable_Salesman), MI('$Cus', sTable_Customer),
          MI('$CID', EditContract.Text), MI('$CN', EditCustomer.Text),
          MI('$Yes', sFlag_Yes)]);
    //xxxxx

    nQuery := LockDBQuery(FDBType);
    DBQuery(nStr, nQuery, ClientDS1);
    //query
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormGetContract.BtnOKClick(Sender: TObject);
begin
  if (not ClientDS1.Active) or (ClientDS1.RecordCount < 1) then
  begin
    ShowMessage('请先查询');
    Exit;
  end;

  ModalResult := mrOk;
end;

initialization
  RegisterClass(TfFormGetContract);
end.
