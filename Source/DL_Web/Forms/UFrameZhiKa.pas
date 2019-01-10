{*******************************************************************************
  ����: dmzn@163.com 2018-05-04
  ����: ��ͬ����
*******************************************************************************}
unit UFrameZhiKa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, UFrameBase, Vcl.Menus, uniMainMenu, uniButton,
  uniBitBtn, uniEdit, uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses,
  uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, uniGUIBaseClasses, frxClass,
  frxExportPDF, frxDBSet;

type
  TfFrameZhiKa = class(TfFrameBase)
    Label1: TUniLabel;
    EditID: TUniEdit;
    Label2: TUniLabel;
    EditCus: TUniEdit;
    PMenu1: TUniPopupMenu;
    MenuItem1: TUniMenuItem;
    MenuItemN1: TUniMenuItem;
    MenuItem2: TUniMenuItem;
    MenuItem3: TUniMenuItem;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    MenuItem4: TUniMenuItem;
    MenuItem5: TUniMenuItem;
    MenuItemN4: TUniMenuItem;
    MenuItemN5: TUniMenuItem;
    MenuItem6: TUniMenuItem;
    MenuItem7: TUniMenuItem;
    MenuItem8: TUniMenuItem;
    MenuItem9: TUniMenuItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditIDKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItem2Click(Sender: TObject);
    procedure BtnDateFilterClick(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    {*ʱ������*}
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //����ɸѡ
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //�������
  end;

implementation

{$R *.dfm}
uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm,
  ULibFun, UManagerGroup, USysBusiness, UFormBase, USysDB, USysConst,
  UFormDateFilter, UFormzhikaFixMoney, UFormZhiKaVerify;

procedure TfFrameZhiKa.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  InitDateRange(ClassName, FStart, FEnd);

  MenuItem3.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
  MenuItem4.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
  MenuItem5.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
  MenuItem9.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
end;

procedure TfFrameZhiKa.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFrameZhiKa.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

function TfFrameZhiKa.InitFormDataSQL(const nWhere: string): string;
begin
  with TDateTimeHelper do
    EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
  //xxxxx

  Result := 'Select zk.*,sm.S_Name,sm.S_PY,cus.C_Name,cus.C_PY From $ZK zk ' +
            ' Left Join $SM sm On sm.S_ID=zk.Z_SaleMan ' +
            ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer';
  //ֽ��

  if nWhere = '' then
       Result := Result + ' Where (zk.Z_Date>=''$ST'' and zk.Z_Date <''$End'')' +
                 ' and (Z_InValid Is Null or Z_InValid<>''$Yes'')'
  else Result := Result + ' Where (' + nWhere + ')';

  with TStringHelper,TDateTimeHelper do
  Result := MacroValue(Result, [MI('$ZK', sTable_ZhiKa),
             MI('$Con', sTable_SaleContract), MI('$SM', sTable_Salesman),
             MI('$Cus', sTable_Customer), MI('$Yes', sFlag_Yes),
             MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

//Desc: ����ɸѡ
procedure TfFrameZhiKa.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameZhiKa.BtnAddClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  nForm := SystemGetForm('TfFormZhiKa', True);
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

procedure TfFrameZhiKa.BtnEditClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('��ѡ��Ҫ�޸ĵļ�¼');
    Exit;
  end;

  nForm := SystemGetForm('TfFormZhiKa', True);
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

procedure TfFrameZhiKa.BtnDelClick(Sender: TObject);
var nStr,nID: string;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('��ѡ��Ҫɾ���ļ�¼');
    Exit;
  end;

  nList := nil;
  nQuery := nil;
  try
    nID := ClientDS.FieldByName('Z_ID').AsString;
    nStr := 'Select Count(*) From %s Where L_ZhiKa=''%s''';
    nStr := Format(nStr, [sTable_Bill, nID]);

    nQuery := LockDBQuery(FDBType);
    with DBQuery(nStr, nQuery) do
    if Fields[0].AsInteger > 0 then
    begin
      ShowMessage('��ֽ�������,����ɾ��.');
      Exit;
    end;

    nStr := Format('ȷ��Ҫɾ�����Ϊ[ %s ]��ֽ����?', [nID]);
    MessageDlg(nStr, mtConfirmation, mbYesNo,
      procedure(Sender: TComponent; Res: Integer)
      begin
        if Res <> mrYes then Exit;
        //cancel

        try
          nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
          nStr := 'Delete From %s Where Z_ID=''%s''';
          nStr := Format(nStr, [sTable_ZhiKa, nID]);
          nList.Add(nStr);

          nStr := 'Delete From %s Where D_ZID=''%s''';
          nStr := Format(nStr, [sTable_ZhiKaDtl, nID]);
          nList.Add(nStr);

          nStr := 'Update %s Set M_ZID=M_ZID+''_d'' Where M_ZID=''%s''';
          nStr := Format(nStr, [sTable_InOutMoney, nID]);
          nList.Add(nStr);

          DBExecute(nList, nil, FDBType);
          gMG.FObjectPool.Release(nList);
          nList := nil;

          InitFormData(FWhere);
          ShowMessage('�ѳɹ�ɾ����¼');
        except
          on nErr: Exception do
          begin
            gMG.FObjectPool.Release(nList);
            ShowMessage('ɾ��ʧ��: ' + nErr.Message);
          end;
        end;
      end);
    //xxxxx
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFrameZhiKa.EditIDKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'Z_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameZhiKa.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

//Desc: ����,�ⶳ
procedure TfFrameZhiKa.MenuItem2Click(Sender: TObject);
var nStr,nFlag,nMsg: string;
begin
  if DBGridMain.SelectedRows.Count > 0 then
  begin
    case TComponent(Sender).Tag of
     10:
       if ClientDS.FieldByName('Z_Freeze').AsString <> sFlag_Yes then
       begin
         nMsg := 'ֽ���ѳɹ�����';
         nFlag := sFlag_Yes;
       end else Exit;
     20:
       if ClientDS.FieldByName('Z_Freeze').AsString = sFlag_Yes then
       begin
         nMsg := '�����ѳɹ����';
         nFlag := sFlag_No;
       end else Exit;
    end;

    nStr := 'Update %s Set Z_Freeze=''%s'' Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, nFlag,
      ClientDS.FieldByName('Z_ID').AsString]);
    //xxxxx

    DBExecute(nStr, nil, FDBType);
    InitFormData(FWhere);
    ShowMessage(nMsg);
  end;
end;

//Desc: �������
procedure TfFrameZhiKa.MenuItem5Click(Sender: TObject);
begin
  if DBGridMain.SelectedRows.Count > 0 then
   ShowZKFixMoneyForm(ClientDS.FieldByName('Z_ID').AsString,
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      if nResult = mrOk then InitFormData(FWhere);
    end);
  //xxxxx
end;

//Desc: ֽ�����
procedure TfFrameZhiKa.MenuItem9Click(Sender: TObject);
begin
  if DBGridMain.SelectedRows.Count > 0 then
   ShowZKVerifyForm(ClientDS.FieldByName('Z_ID').AsString,
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      if nResult = mrOk then InitFormData(FWhere);
    end);
  //xxxxx
end;

//Desc: ��ݲ�ѯ
procedure TfFrameZhiKa.MenuItem6Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    10: FWhere := Format('Z_Freeze=''%s''', [sFlag_Yes]);
    20: FWhere := Format('Z_InValid=''%s''', [sFlag_Yes]);
    30: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

initialization
  RegisterClass(TfFrameZhiKa);
end.
