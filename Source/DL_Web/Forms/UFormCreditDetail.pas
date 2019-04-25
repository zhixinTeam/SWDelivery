{*******************************************************************************
  ����: dmzn@163.com 2018-05-07
  ����: ������ͬ
*******************************************************************************}
unit UFormCreditDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIForm, UFormBase, Vcl.Menus, uniMainMenu,
  Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniGUIBaseClasses, uniButton;

type
  TfFormCreditDetail = class(TfFormBase)
    ClientDS1: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TUniDBGrid;
    PMenu1: TUniPopupMenu;
    MenuItem1: TUniMenuItem;
    procedure DBGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItem1Click(Sender: TObject);
  private
    { Private declarations }
    FCreditChanged: Boolean;
    //���ñ䶯
    procedure LoadCreditDetail(const nCusID: string);
    //������ϸ
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
  end;

  TFormCreditDetailResult = procedure (const nChanged: Boolean) of object;
  //����ص�

procedure ShowCreditDetailForm(const nCusID,nPopedom: string;
  const nResult: TFormCreditDetailResult);
//��ں���

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, System.IniFiles,
  UManagerGroup, ULibFun, USysBusiness, USysDB, USysConst;

//Date: 2018-05-07
//Parm: �ͻ����
//Desc: ��ʾ�ͻ����ñ䶯����
procedure ShowCreditDetailForm(const nCusID,nPopedom: string;
  const nResult: TFormCreditDetailResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormCreditDetail', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormCreditDetail do
  begin
    MenuItem1.Enabled := HasPopedom2(sPopedom_Edit, nPopedom);
    //Ȩ��

    FParam.FParamA := nCusID;
    LoadCreditDetail(nCusID);
    //load data

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        nResult(FCreditChanged);
      end);
  end;
end;

procedure TfFormCreditDetail.OnCreateForm(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    FCreditChanged := False;
    nIni := UserConfigFile();
    LoadFormConfig(Self, nIni);

    BuildDBGridColumn('CusCredit', DBGrid1);
    DBGrid1.BorderStyle := ubsNone;
    UserDefineGrid(ClassName, DBGrid1, True, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormCreditDetail.OnDestroyForm(Sender: TObject);
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

procedure TfFormCreditDetail.LoadCreditDetail(const nCusID: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nStr := 'Select cc.*,C_Name From %s cc ' +
            ' Left Join %s cus On cus.C_ID=cc.C_CusID ' +
            'Where cc.C_CusID=''%s'' Order By C_Date Desc';
    nStr := Format(nStr, [sTable_CusCredit, sTable_Customer, nCusID);

    nQuery := LockDBQuery(FDBType);
    DBQuery(nStr, nQuery, ClientDS1);
    SetGridColumnFormat('CusCredit', ClientDS1, UniMainModule.DoColumnFormat);
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormCreditDetail.DBGrid1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Exit;
  if Button = mbRight then PMenu1.Popup(X, Y, DBGrid1);
end;

//Desc: �������
procedure TfFormCreditDetail.MenuItem1Click(Sender: TObject);
var nStr,nCID: string;
    nVal: Double;
    nQuery: TADOQuery;
begin
  if DBGrid1.SelectedRows.Count < 1 then Exit;
  nQuery := nil;

  with TStringHelper,TFloatHelper,TSQLBuilder do
  try
    nQuery := LockDBQuery(FDBType);
    nStr := 'Select C_Verify,C_CusID,C_Money From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_CusCredit,
            ClientDS1.FieldByName('R_ID').AsString);
    //xxxxx

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      nStr := Fields[0.AsString;
      nCID := Fields[1.AsString;

      nVal := Fields[2.AsFloat;
      nVal := Float2Float(nVal, cPrecision, False);
      //money
    end else
    begin
      nVal := 0;
      nStr := sFlag_Yes;
    end;

    if nStr = sFlag_Yes then
    begin
      ShowMessage('������');
      Exit;
    end;

    nStr := '���ñ����ϸ����: ' + StringOfChar(#32, 16) + #13#10#13#10 +
            '��.�ͻ�����: %s' + #13#10 +
            '��.���Ž��: %.2fԪ' + #13#10#13#10 +
            '������������"��".';
    nStr := Format(nStr, [ClientDS1.FieldByName('C_Name').AsString, nVal);
    MessageDlg(nStr, mtConfirmation, mbYesNo,
      procedure(Sender: TComponent; Res: Integer)
      var nList: TStrings;
      begin
        if Res <> mrYes then Exit;
        nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
        try
          nStr := SF('R_ID', ClientDS1.FieldByName('R_ID').AsString);
          nStr := MakeSQLByStr([
                  SF('C_Verify', sFlag_Yes),
                  SF('C_VerMan', UniMainModule.FUserConfig.FUserID),
                  SF('C_VerDate', sField_SQLServer_Now, sfVal)
                  , sTable_CusCredit, nStr, False);
          nList.Add(nStr);

          nStr := 'Update %s Set A_CreditLimit=A_CreditLimit+%.2f ' +
                  'Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, nVal, nCID);
          nList.Add(nStr);

          DBExecute(nList, nil, FDBType);
          //���������в���ʹ��ȫ�ֵ�nQuery
          FCreditChanged := True;
          LoadCreditDetail(FParam.FParamA);
        finally
          gMG.FObjectPool.Release(nList);
        end;
      end);
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFormCreditDetail);
end.
