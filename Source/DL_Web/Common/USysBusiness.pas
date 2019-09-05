{*******************************************************************************
  ����: dmzn@163.com 2018-04-23
  ����: ҵ���嵥Ԫ
*******************************************************************************}
unit USysBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, ComCtrls, Controls, Messages, Forms, SysUtils, IniFiles,
  Data.DB, Data.Win.ADODB, Datasnap.Provider, Datasnap.DBClient,
  System.SyncObjs, Vcl.Grids, Vcl.DBGrids, Vcl.Graphics,
  //----------------------------------------------------------------------------
  uniGUIAbstractClasses, uniGUITypes, uniGUIClasses, uniGUIBaseClasses, uniGUIFrame,
  uniGUISessionManager, uniGUIApplication, uniTreeView, uniGUIForm,
  uniDBGrid, uniStringGrid, uniComboBox, UDataReport,
  //----------------------------------------------------------------------------
  UBaseObject, UManagerGroup, ULibFun, USysDB, USysConst, USysFun, USysRemote,
  DBGrid2Excel;

procedure GlobalSyncLock;
procedure GlobalSyncRelease;
//ȫ��ͬ������
procedure RegObjectPoolTypes;
//ע�Ỻ��ض���

function LockDBConn(const nType: TAdoConnectionType = ctMain): TADOConnection;
procedure ReleaseDBconn(const nConn: TADOConnection);
function LockDBQuery(const nType: TAdoConnectionType = ctMain): TADOQuery;
procedure ReleaseDBQuery(const nQuery: TADOQuery);
//���ݿ���·
function DBQuery(const nStr: string; const nQuery: TADOQuery;
  const nClientDS: TClientDataSet = nil): TDataSet;
function DBExecute(const nStr: string; const nCmd: TADOQuery = nil;
  const nType: TAdoConnectionType = ctMain): Integer; overload;
function DBExecute(const nList: TStrings; const nCmd: TADOQuery = nil;
  const nType: TAdoConnectionType = ctMain): Integer; overload;
//���ݿ����
procedure DSClientDS(const nDS: TDataSet; const nClientDS: TClientDataSet);
//���ݼ�ת��

function AdjustHintToRead(const nHint: string): string;
//������ʾ����
function SystemGetForm(const nClass: string;
  const nException: Boolean = False): TUniForm;
//���������ƻ�ȡ�������
function UserFlagByID: string;
function UserConfigFile: TIniFile;
//�û��Զ��������ļ�
function WriteSysLog(const nGroup,nItem,nEvent: string;
  const nType: TAdoConnectionType = ctMain; const nQuery: TADOQuery = nil;
  const nHint: Boolean = True; const nExec: Boolean = True;
  const nKeyID: string = ''; const nMan: string = ''): string;
 //��¼ϵͳ��־
procedure LoadFormConfig(const nForm: TUniForm; const nIni: TIniFile = nil);
procedure SaveFormConfig(const nForm: TUniForm; const nIni: TIniFile = nil);
//��д����������Ϣ
function ParseCardNO(const nCard: string; const nHex: Boolean): string;
//��ʽ���ſ����
procedure LoadSystemMemoryStatus(const nList: TStrings; const nFriend: Boolean);
//����ϵͳ�ڴ�״̬
procedure ReloadSystemMemory(const nResetAllSession: Boolean);
//���¼���ϵͳ��������

procedure LoadSysDictItem(const nItem: string; const nList: TStrings);
//��ȡϵͳ�ֵ���
procedure LoadStockFromDict(var nStock: TStockItems; const nQuery: TADOQuery=nil;
  const nType: TAdoConnectionType = ctMain);
//��ȡ�����б�
function LoadSaleMan(const nList: TStrings; const nWhere: string = ''): Boolean;
//��ȡҵ��Ա�б�
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
//��ȡ�ͻ��б�
function LoadVerifyMan(const nList: TStrings; const nWhere: string = ''): Boolean;
//��ȡ���Ȩ���û��б�
function GetIDFromBox(const nBox: TUniComboBox): string;
function GetNameFromBox(const nBox: TUniComboBox): string;
//��nBox�ж�ȡID,Name��

function IsZhiKaNeedVerify(const nQuery: TADOQuery): Boolean;
//ֽ���Ƿ���Ҫ���
procedure SaveCustomerPayment(const nCusID,nCusName,nSaleMan: string;
 const nType,nPayment,nMemo: string; const nMoney: Double;
 const nModalResult: TFormModalResult = nil; const nCredit: Boolean = True);
//����ؿ��¼
function IsAutoPayCredit(const nQuery: TADOQuery): Boolean;
//�ؿ�ʱ������
function SaveCustomerCredit(const nCusID,nMemo: string; const nCredit: Double;
 const nEndTime: TDateTime; nVarMan:string): Boolean;
//�������ü�¼

procedure LoadMenuItems(const nForce: Boolean);
//����˵�����
procedure BuidMenuTree(const nTree: TUniTreeView; nEntity: string = '');
//�����˵���
function GetMenuItemID(const nIdx: Integer): string;
//��ȡָ���˵���ʶ
function GetMenuByModule(const nModule: string): string;
function GetModuleByMenu(const nMenu: string): string;
//�˵���ģ�黥��

procedure LoadFactoryList(const nForce: Boolean);
//���빤���б�
procedure GetFactoryList(const nList: TStrings);
function GetFactory(const nIdx: Integer; var nFactory: TFactoryItem): Boolean;
//���������б�

procedure LoadPopedomList(const nForce: Boolean);
//����Ȩ���б�
function GetPopedom(const nMenu: string): string;
function HasPopedom(const nMenu,nPopedom: string): Boolean;
function HasPopedom2(const nPopedom,nAll: string): Boolean;
//�Ƿ���ָ��Ȩ��

procedure LoadEntityList(const nForce: Boolean);
//���������ֵ��б�
procedure BuildDBGridColumn(const nEntity: string; const nGrid: TUniDBGrid;
  const nFilter: string = '');
//���������
procedure BuidDataSetSortIndex(const nClientDS: TClientDataSet);
//����nClientDS��������
procedure SetGridColumnFormat(const nEntity: string;
  const nClientDS: TClientDataSet; const nOnData: TFieldGetTextEvent);
//����nGrid�����ݺ���ʵӳ��
procedure UserDefineGrid(const nForm: string; const nGrid: TUniDBGrid;
  const nLoad: Boolean; const nIni: TIniFile = nil);
procedure UserDefineStringGrid(const nForm: string; const nGrid: TUniStringGrid;
  const nLoad: Boolean; const nIni: TIniFile = nil);
procedure DoStringGridColumnResize(const nGrid: TObject;
  const nParam: TUniStrings);
//�û��Զ�����
function GridExportExcel(const nGrid: TUniDBGrid; const nFile: string): string;
//��nGrid�����ݵ�����nFile�ļ���

function IsWeekValid(const nWeek: string; var nHint: string;
  var nBegin,nEnd: TDateTime; const nQuery: TADOQuery): Boolean;
//�����Ƿ���Ч
function IsWeekHasEnable(const nWeek: string; const nQuery: TADOQuery): Boolean;
//�����Ƿ�����
function IsNextWeekEnable(const nWeek: string; const nQuery: TADOQuery): Boolean;
//��һ�����Ƿ�����
function IsWeekCanZZ(const nWeek: string; const nQuery: TADOQuery): Boolean;
function IsPreWeekOver(const nWeek: string; const nQuery: TADOQuery; var nPreWeek:string): Integer;
//��һ�����Ƿ����

function GetLeftStr(SubStr, Str: string): string;
function GetRightStr(SubStr, Str: string): string;


function PrintHuaYanReport(const nHID: string): Boolean;
function PrintHuaYanReport_3(const nHID: string): Boolean;


implementation

uses
  MainModule, ServerModule;

var
  gSyncLock: TCriticalSection;
  //ȫ����ͬ������

//------------------------------------------------------------------------------
//Date: 2018-04-23
//Desc: ȫ��ͬ������
procedure GlobalSyncLock;
begin
  gSyncLock.Enter;
end;

//Date: 2018-04-23
//Desc: ȫ��ͬ�������Ӵ�
procedure GlobalSyncRelease;
begin
  gSyncLock.Leave;
end;

//Date: 2018-04-20
//Desc: ע������
procedure RegObjectPoolTypes;
var nCD: PAdoConnectionData;
begin
  with gMG.FObjectPool do
  begin
    NewClass(TADOConnection,
      function(var nData: Pointer):TObject
      begin
        Result := TADOConnection.Create(nil);
        New(nCD);
        nData := nCD;

        nCD.FConnUser := '';
        nCD.FConnStr := '';
      end,

      procedure(const nObj: TObject; const nData: Pointer)
      begin
        nObj.Free;
        Dispose(PAdoConnectionData(nData));
      end);
    //ado conn

    NewClass(TADOQuery,
      function(var nData: Pointer):TObject
      begin
        Result := TADOQuery.Create(nil);
      end);
    //ado query

    NewClass(TDataSetProvider,
      function(var nData: Pointer):TObject
      begin
        Result := TDataSetProvider.Create(nil);
      end,

      procedure(const nObj: TObject; const nData: Pointer)
      begin
        TDataSetProvider(nObj).Free;
      end);
    //data provider

    NewClass(TDBGrid2Excel,
      function(var nData: Pointer):TObject
      begin
        Result := TDBGrid2Excel.Create(nil);
      end);
    //data exporter

    NewClass(TDBGrid,
      function(var nData: Pointer):TObject
      begin
        Result := TDBGrid.Create(nil);
      end);
    //data grid
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-04-20
//Parm: ��������
//Desc: ��ȡ���ݿ���·
function LockDBConn(const nType: TAdoConnectionType): TADOConnection;
var nStr: string;
    nCD: PAdoConnectionData;
begin
  GlobalSyncLock;
  try
    if nType = ctMain then
         nStr := gServerParam.FDBMain
    else nStr := gAllFactorys[UniMainModule.FUserConfig.FFactory].FDBWorkOn;
  finally
    GlobalSyncRelease;
  end;

  Result := gMG.FObjectPool.Lock(TADOConnection, nil, @nCD,
    function(const nObj: TObject; const nData: Pointer; var nTimes: Integer): Boolean
    begin
      Result := (not Assigned(nData)) or
                (PAdoConnectionData(nData).FConnUser = nStr);
    end) as TADOConnection;
  //��ͬ��������

  with Result do
  begin
    if nCD.FConnUser <> nStr then
    begin
      nCD.FConnUser := nStr;
      //user data

      Connected := False;
      ConnectionString := nStr;
      LoginPrompt := False;
    end;
  end;
end;

//Date: 2018-04-20
//Parm: ���Ӷ���
//Desc: �ͷ���·
procedure ReleaseDBconn(const nConn: TADOConnection);
begin
  if Assigned(nConn) then
  begin
    gMG.FObjectPool.Release(nConn);
  end;
end;

//Date: 2018-04-20
//Parm: ��������
//Desc: ��ȡ��ѯ����
function LockDBQuery(const nType: TAdoConnectionType): TADOQuery;
begin
  Result := gMG.FObjectPool.Lock(TADOQuery) as TADOQuery;
  with Result do
  begin
    Close;
    Connection := LockDBConn(nType);
  end;
end;

//Date: 2018-04-20
//Parm: ��ѯ����
//Desc: �ͷŲ�ѯ����
procedure ReleaseDBQuery(const nQuery: TADOQuery);
begin
  if Assigned(nQuery) then
  begin
    try
      if nQuery.Active then
        nQuery.Close;
      //xxxxx
    except
      //ignor any error
    end;

    gMG.FObjectPool.Release(nQuery.Connection);
    gMG.FObjectPool.Release(nQuery);
  end;
end;

//Date: 2018-04-20
//Parm: SQL;��ѯ����
//Desc: ��nQuery��ִ�в�ѯ
function DBQuery(const nStr: string; const nQuery: TADOQuery;
  const nClientDS: TClientDataSet): TDataSet;
var nBookMark: TBookmark;
begin
  try
      try
        if not nQuery.Connection.Connected then
          nQuery.Connection.Connected := True;
        //xxxxx

        nQuery.Close;
        nQuery.SQL.Text := nStr;
        nQuery.Open;

        Result := nQuery;
        //result
                                         if Assigned(nClientDS) then
                                            nBookMark := nClientDS.GetBookmark;
        if Assigned(nClientDS) then
          DSClientDS(Result, nClientDS);
        //xxxxx
      except
        nQuery.Connection.Connected := False;
        raise;
      end;

       if Assigned(nClientDS) then
       if nClientDS.BookmarkValid(nBookMark) then
        nClientDS.GotoBookmark(nBookMark);
  finally
      if Assigned(nClientDS) then
        nClientDS.FreeBookmark(nBookMark);
  end;
end;

//Date: 2018-04-28
//Parm: �������ݼ�;Զ�����ݼ�
//Desc: ��nDSת��ΪnClientDS
procedure DSClientDS(const nDS: TDataSet; const nClientDS: TClientDataSet);
var nProvider: TDataSetProvider;
begin
  nProvider := nil;
  try
    nProvider := gMG.FObjectPool.Lock(TDataSetProvider) as TDataSetProvider;
    nProvider.DataSet := nDS;

    if nClientDS.Active then
      nClientDS.EmptyDataSet;
    nClientDS.Data := nProvider.Data;

    nClientDS.LogChanges := False;
    nProvider.DataSet := nil;
    //xxxxx
  finally
    gMG.FObjectPool.Release(nProvider);
  end;
end;

//Date: 2018-04-20
//Parm: SQL;��������;��������
//Desc: ��nCmd��ִ��д�����
function DBExecute(const nStr: string; const nCmd: TADOQuery;
  const nType: TAdoConnectionType): Integer;
var nC: TADOQuery;
begin
  nC := nil;
  try
    if Assigned(nCmd) then
         nC := nCmd
    else nC := LockDBQuery(nType);

    if not nC.Connection.Connected then
      nC.Connection.Connected := True;
    //xxxxx

    with nC do
    try
      Close;
      SQL.Text := nStr;
      Result := ExecSQL;
    except
      nC.Connection.Connected := False;
      raise;
    end;
  finally
    if not Assigned(nCmd) then
      ReleaseDBQuery(nC);
    //xxxxx
  end;
end;

function DBExecute(const nList: TStrings; const nCmd: TADOQuery = nil;
  const nType: TAdoConnectionType = ctMain): Integer;
var nIdx: Integer;
    nC: TADOQuery;
begin
  nC := nil;
  try
    if Assigned(nCmd) then
         nC := nCmd
    else nC := LockDBQuery(nType);

    if not nC.Connection.Connected then
      nC.Connection.Connected := True;
    //xxxxx

    Result := 0;
    try
      nC.Connection.BeginTrans;
      //trans start

      for nIdx := 0 to nList.Count-1 do
      with nC do
      begin
        Close;
        SQL.Text := nList[nIdx];
        Result := Result + ExecSQL;
      end;

      nC.Connection.CommitTrans;
      //commit
    except
      on nErr: Exception do
      begin
        nC.Connection.RollbackTrans;
        nC.Connection.Connected := False;
        raise;
      end;
    end;
  finally
    if not Assigned(nCmd) then
      ReleaseDBQuery(nC);
    //xxxxx
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-22
//Parm: 16λ��������
//Desc: ��ʽ��nCardΪ��׼����
function ParseCardNO(const nCard: string; const nHex: Boolean): string;
var nInt: Int64;
    nIdx: Integer;
begin
  if nHex then
  begin
    Result := '';
    for nIdx:=1 to Length(nCard) do
      Result := Result + IntToHex(Ord(nCard[nIdx]), 2);
    //xxxxx
  end else Result := nCard;

  nInt := StrToInt64('$' + Result);
  Result := IntToStr(nInt);
  Result := StringOfChar('0', 12 - Length(Result)) + Result;
end;

//Date: 2018-04-24
//Parm: �б�;�Ѻø�ʽ
//Desc: ���ڴ�״̬���ݼ��ص��б���
procedure LoadSystemMemoryStatus(const nList: TStrings; const nFriend: Boolean);
var nIdx,nLen: Integer;
begin
  GlobalSyncLock;
  try
    nList.BeginUpdate;
    nList.Clear;

    with TObjectStatusHelper do
    begin
      AddTitle(nList, 'System Buffer');
      nList.Add(FixData('All Users:', gAllUsers.Count));
      nList.Add(FixData('All Menus:', Length(gAllMenus)));
      nList.Add(FixData('All Popedoms:', Length(gAllPopedoms)));
      nList.Add(FixData('All Entitys:', Length(gAllEntitys)));
      nList.Add(FixData('All Factorys:', Length(gAllFactorys)));
    end;

    gMG.FObjectPool.GetStatus(nList, nFriend);
    gMG.FObjectManager.GetStatus(nList, nFriend);
    gMG.FObjectManager.GetStatus(nList, nFriend);
    gMG.FChannelManager.GetStatus(nList, nFriend);

    with TObjectStatusHelper do
    begin
      AddTitle(nList, 'Online Users');
      //online
      nLen := gAllUsers.Count - 1;

      for nIdx := 0 to nLen do
       with PSysParam(gAllUsers[nIdx])^ do
        nList.Add(FixData(Format('%2d.Name: %s', [nIdx+1, FUserID]), Format(
         'IP:%s SYS:%s DESC:%s', [FLocalIP, FOSUser, FUserAgent])));
      //xxxxx
    end;
  finally
    GlobalSyncRelease;
    nList.EndUpdate;
  end;
end;

//Date: 2018-04-24
//Parm: �Ͽ�ȫ���Ự
//Desc: ���ػ���,�Ͽ�ȫ������
procedure ReloadSystemMemory(const nResetAllSession: Boolean);
var nStr: string;
    nIdx: Integer;
    nList: TUniGUISessions;
begin
  if nResetAllSession then
  begin
    nList := UniServerModule.SessionManager.Sessions;
    try
      nList.Lock;
      for nIdx := nList.SessionList.Count-1 downto 0 do
      begin
        nStr := '����Ա����ϵͳ,�����µ�¼';
        TUniGUISession(nList.SessionList[nIdx]).Terminate(nStr);
      end;
    finally
      nList.Unlock;
    end;
  end;

  GlobalSyncLock;
  try
    LoadFactoryList(True);
    //���빤���б�
    LoadPopedomList(True);
    //����Ȩ���б�
    LoadMenuItems(True);
    //����˵���
    LoadEntityList(True);
    //���������ֵ�
  finally
    GlobalSyncRelease;
  end;
end;

//Date: 2018-05-16
//Parm: ��ʾ����
//Desc: ����nHintΪ�׶��ĸ�ʽ
function AdjustHintToRead(const nHint: string): string;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := nil;
  try
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nList.Text := nHint;

    for nIdx:=0 to nList.Count - 1 do
      nList[nIdx] := '��.' + nList[nIdx];
    Result := nList.Text;
  finally
    gMG.FObjectPool.Release(nList);
  end;
end;

//Date: 2018-04-24
//Parm: ��������
//Desc: ��ȡnClass��Ķ���
function SystemGetForm(const nClass: string;const nException:Boolean): TUniForm;
var nCls: TClass;
begin
  nCls := GetClass(nClass);
  if Assigned(nCls) then
       Result := TUniForm(UniMainModule.GetFormInstance(nCls))
  else Result := nil;

  if (not Assigned(Result)) and nException then
    UniMainModule.FMainForm.ShowMessage(Format('������[ %s ]��Ч.', [nClass]));
  //xxxxx
end;

//Date: 2018-05-22
//Desc: �����û���ʶ
function UserFlagByID: string;
var nStr: string;
    nIdx: Integer;
begin
  with TEncodeHelper,UniMainModule do
    nStr := EncodeBase64(FUserConfig.FUserID);
  Result := '';

  for nIdx := 1 to Length(nStr) do
   if CharInSet(nStr[nIdx], ['a'..'z', 'A'..'Z','0'..'9']) then
    Result := Result + nStr[nIdx];
  //number & charactor
end;

//Date: 2018-04-26
//Desc: �û��Զ�������
function UserConfigFile: TIniFile;
var nStr: string;
begin
  nStr := gPath + 'users\';
  if not DirectoryExists(nStr) then
    ForceDirectories(nStr);
  //new folder

  nStr := nStr + UserFlagByID + '.ini';
  Result := TIniFile.Create(nStr);

  if not FileExists(nStr) then
  begin
    Result.WriteString('Config', 'User', UniMainModule.FUserConfig.FUserID);
  end;
end;

//Date: 2009-6-8
//Parm: ��Ϣ����;��ʶ;�¼�;��������;������ʾ;ִ��;������ʶ;������
//Desc: ��ϵͳ��־��д��һ����־��¼
function WriteSysLog(const nGroup,nItem,nEvent: string;
 const nType: TAdoConnectionType; const nQuery: TADOQuery;
 const nHint,nExec: Boolean; const nKeyID,nMan: string): string;
var nStr,nSQL: string;
begin
  with TStringHelper,UniMainModule do
  begin
    nSQL := 'Insert Into $T(L_Date,L_Man,L_Group,L_ItemID,L_KeyID,L_Event) ' +
            'Values($D,''$M'',''$G'',''$I'',''$K'',''$E'')';
    nSQL := MacroValue(nSQL, [MI('$T', sTable_SysLog),
            MI('$D', sField_SQLServer_Now), MI('$G', nGroup), MI('$I', nItem),
            MI('$E', nEvent), MI('$K', nKeyID)]);
    //xxxxx

    if nMan = '' then
         nStr := FUserConfig.FUserName
    else nStr := nMan;

    nSQL := MacroValue(nSQL, [MI('$M', nStr)]);
    Result := nSQL;

    if nExec then
    try
      DBExecute(nSQL, nQuery, nType);
    except
      if nHint then
        FMainForm.ShowMessage('ϵͳ��־д�����');
      Result := '';
    end;
  end;
end;

//Desc: ��ȡ��������
procedure LoadFormConfig(const nForm: TUniForm; const nIni: TIniFile);
var nC: TIniFile;
begin
  nC := nil;
  try
    if Assigned(nIni) then
         nC := nIni
    else nC := UserConfigFile();

    nForm.Width := nC.ReadInteger(nForm.ClassName, 'Width', nForm.Width);
    nForm.Height := nC.ReadInteger(nForm.ClassName, 'Height', nForm.Height);
  finally
    if not Assigned(nIni) then
      nC.Free;
    //xxxxx
  end;
end;

//Desc: ���洰������
procedure SaveFormConfig(const nForm: TUniForm; const nIni: TIniFile);
var nC: TIniFile;
begin
  nC := nil;
  try
    if Assigned(nIni) then
         nC := nIni
    else nC := UserConfigFile();

    nC.WriteInteger(nForm.ClassName, 'Width', nForm.Width);
    nC.WriteInteger(nForm.ClassName, 'Height', nForm.Height);
  finally
    if not Assigned(nIni) then
      nC.Free;
    //xxxxx
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-05-03
//Parm: �ֵ���;�б�
//Desc: ��SysDict�ж�ȡnItem�������,����nList��
procedure LoadSysDictItem(const nItem: string; const nList: TStrings);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  with TStringHelper do
  try
    nList.BeginUpdate;
    nList.Clear;
    nQuery := LockDBQuery(ctWork);

    nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                        MI('$Name', nItem)]);
    DBQuery(nStr, nQuery);

    if nQuery.RecordCount > 0 then
    with nQuery do
    begin
      First;

      while not Eof do
      begin
        nList.Add(FieldByName('D_Value').AsString);
        Next;
      end;
    end;
  finally
    nList.EndUpdate;
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-07-03
//Parm: �����б�
//Desc: ���ֵ������ж�ȡ�����б�
procedure LoadStockFromDict(var nStock: TStockItems; const nQuery: TADOQuery;
  const nType: TAdoConnectionType);
var nStr: string;
    nIdx: Integer;
    nTmp: TADOQuery;
begin
  nTmp := nil;
  try
    if Assigned(nQuery) then
         nTmp := nQuery
    else nTmp := LockDBQuery(nType);

    SetLength(nStock, 0);
    nStr := 'Select * From %s Where D_Name=''%s'' Order By D_Index DESC';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

    with DBQuery(nStr, nTmp) do
    if nTmp.RecordCount > 0 then
    begin
      SetLength(nStock, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with nStock[nIdx] do
        begin
          FID := FieldByName('D_ParamB').AsString;
          FName := FieldByName('D_Value').AsString;
          FType := FieldByName('D_Memo').AsString;
          FSelected := True;
        end;

        Inc(nIdx);
        Next;
      end;
    end;
  finally
    if not Assigned(nQuery) then
      ReleaseDBQuery(nTmp);
    //xxxxx
  end;
end;

//Date: 2018-05-03
//Parm: �б�;��ѯ����
//Desc: ����ҵ��Ա�б�nList��
function LoadSaleMan(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nList.BeginUpdate;
    nList.Clear;
    nQuery := LockDBQuery(ctWork);

    if nWhere = '' then
         nW := ''
    else nW := Format(' And (%s)', [nWhere]);

    nStr := 'Select S_ID,S_Name From %s ' +
            'Where IsNull(S_InValid, '''')<>''%s'' %s Order By S_PY';
    nStr := Format(nStr, [sTable_Salesman, sFlag_Yes, nW]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nList.Add(FieldByName('S_ID').AsString + '.' +
                  FieldByName('S_Name').AsString);
        Next;
      end;
    end;

    Result := nList.Count > 0;
  finally
    nList.EndUpdate;
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-05-03
//Parm: �б�;��ѯ����
//Desc: ��ȡ�ͻ��б�nList��,������������
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nList.BeginUpdate;
    nList.Clear;
    nQuery := LockDBQuery(ctWork);

    if nWhere = '' then
         nW := ''
    else nW := Format(' And (%s)', [nWhere]);

    nStr := 'Select C_ID,C_Name From %s ' +
            'Where IsNull(C_XuNi, '''')<>''%s'' %s Order By C_PY';
    nStr := Format(nStr, [sTable_Customer, sFlag_Yes, nW]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nList.Add(FieldByName('C_ID').AsString + '.' +
                  FieldByName('C_Name').AsString);
        Next;
      end;
    end;

    Result := nList.Count > 0;
  finally
    nList.EndUpdate;
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-07-17
//Parm: �б�;��ѯ����
//Desc: ����������б�nList��
function LoadVerifyMan(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nList.BeginUpdate;
    nList.Clear;
    nQuery := LockDBQuery(ctWork);

    if nWhere = '' then
         nW := ''
    else nW := Format(' And (%s)', [nWhere]);

    nStr := 'Select U_Name From %s ' +
            'Where U_State=1 And U_VerifyCredit=-1 ';
    nStr := Format(nStr, [sTable_User, sFlag_Yes, nW]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nList.Add(FieldByName('U_Name').AsString);
        Next;
      end;
    end;

    Result := nList.Count > 0;
  finally
    nList.EndUpdate;
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-05-08
//Parm: ������,���ݸ�ʽ: ID.Name
//Desc: ��ȡnBox��ǰѡ�еļ�¼ID��
function GetIDFromBox(const nBox: TUniComboBox): string;
begin
  Result := nBox.Text;
  Result := Copy(Result, 1, Pos('.', Result) - 1);
end;

//Date: 2018-05-13
//Parm: ������,���ݸ�ʽ: ID.Name
//Desc: ��ȡnBox��ǰѡ�еļ�¼Name��
function GetNameFromBox(const nBox: TUniComboBox): string;
begin
  Result := nBox.Text;
  System.Delete(Result, 1, Pos('.', Result));
end;

//Date: 2018-05-05
//Parm: ��ѯ����
//Desc: ֽ���Ƿ���Ҫ���
function IsZhiKaNeedVerify(const nQuery: TADOQuery): Boolean;
var nStr: string;
begin
  with TStringHelper do
  begin
    nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
    nStr := MacroValue(nStr, [MI('$T', sTable_SysDict),
            MI('$N', sFlag_SysParam), MI('$M', sFlag_ZhiKaVerify)]);
    //xxxxx
  end;

  with DBQuery(nStr, nQuery) do
  if RecordCount > 0 then
       Result := Fields[0].AsString = sFlag_Yes
  else Result := False;
end;

procedure DoSaveCustomerPayment(const nCusID,nCusName,nSaleMan,nType,nPayment,
  nMemo: string; const nVal,nLimit: Double;
  const nList: TStrings; const nQuery: TADOQuery);
var nStr: string;
    nTmp: TStrings;
begin
  nTmp := nil;
  try
    if Assigned(nList) then
         nTmp := nList
    else nTmp := gMG.FObjectPool.Lock(TStrings) as TStrings;

    nStr := 'Update %s Set A_InMoney=A_InMoney+%.2f Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nVal, nCusID]);
    nTmp.Add(nStr);

    with TSQLBuilder do
    nStr := TSQLBuilder.MakeSQLByStr([SF('M_SaleMan', nSaleMan),
            SF('M_CusID', nCusID),
            SF('M_CusName', nCusName),
            SF('M_Type', nType),
            SF('M_Payment', nPayment),
            SF('M_Money', nVal, sfVal),
            SF('M_Date', sField_SQLServer_Now, sfVal),
            SF('M_Man', UniMainModule.FUserConfig.FUserID),
            SF('M_Memo', nMemo)
            ], sTable_InOutMoney);
    nTmp.Add(nStr);

    DBExecute(nTmp, nQuery, ctWork);
    //do save

    if (nLimit > 0) and (
       not SaveCustomerCredit(nCusID, '�ؿ�ʱ���', -nLimit, Now(),'')) then
    begin
      nStr := '����δ֪����,���³���ͻ�[ %s ]���ò���ʧ��.' + #13#10 +
              '���ֶ������ÿͻ����ö��.';
      nStr := Format(nStr, [nCusName]);
      UniMainModule.FMainForm.ShowMessage(nStr);
    end;
  finally
    if not Assigned(nList) then
      gMG.FObjectPool.Release(nTmp);
    //xxxxx
  end;
end;

//Desc: ����nCusID��һ�λؿ��¼
procedure SaveCustomerPayment(const nCusID,nCusName,nSaleMan: string;
 const nType,nPayment,nMemo: string; const nMoney: Double;
 const nModalResult: TFormModalResult; const nCredit: Boolean);
var nStr: string;
    nVal,nLimit: Double;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  nList := nil;
  nQuery := nil;
  //init

  with TStringHelper,TFloatHelper do
  try
    nVal := Float2Float(nMoney, cPrecision, False);
    //adjust float value
    nQuery := LockDBQuery(ctWork);

    {$IFNDEF NoCheckOnPayment}
    if nVal < 0 then
    begin
      nLimit := GetCustomerValidMoney(nCusID, True);
      //get money value

      {$IFDEF SXSW}
      nStr := 'Select A_InMoney+A_InitMoney From %s Where A_CID=''%s''';
      {$ELSE}
      nStr := 'Select A_InMoney From %s Where A_CID=''%s''';
      {$ENDIF}
      nStr := Format(nStr, [sTable_CusAccount, nCusID]);

      with DBQuery(nStr, nQuery) do
      if  RecordCount > 0 then
      begin
        if Fields[0].AsFloat < nLimit then
          nLimit := Float2Float(Fields[0].AsFloat, cPrecision, False);
        //�ͻ����С�ڵ�ǰ���ý�ʱ,ֻ���˻������
      end;

      if (nLimit <= 0) or (nLimit < -nVal) then
      begin
        nStr := '�ͻ�: %s ' + #13#10#13#10 +
                '��ǰ���Ϊ[ %.2f ]Ԫ,�޷�֧��[ %.2f ]Ԫ.';
        nStr := Format(nStr, [nCusName, nLimit, -nVal]);

        UniMainModule.FMainForm.ShowMessage(nStr);
        Exit;
      end;
    end;
    {$ENDIF}

    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nLimit := 0;
    //no limit

    if nCredit and (nVal > 0) and IsAutoPayCredit(nQuery) then
    begin
      nStr := 'Select A_CreditLimit From %s Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, nCusID]);

      with DBQuery(nStr, nQuery) do
      if (RecordCount > 0) and (Fields[0].AsFloat > 0) then
      begin
        if FloatRelation(nVal, Fields[0].AsFloat, rtGreater) then
             nLimit := Float2Float(Fields[0].AsFloat, cPrecision, False)
        else nLimit := nVal;

        nStr := '�ͻ�[ %s ]��ǰ���ö��Ϊ[ %.2f ]Ԫ,�Ƿ���?' +
                #32#32#13#10#13#10 + '���"��"������[ %.2f ]Ԫ�Ķ��.';
        nStr := Format(nStr, [nCusName, Fields[0].AsFloat, nLimit]);

        UniMainModule.FMainForm.MessageDlg(nStr, mtConfirmation, mbYesNo,
          procedure(Sender: TComponent; Res: Integer)
          begin
            if Res <> mrYes then
              nLimit := 0;
            //xxxxx

            DoSaveCustomerPayment(nCusID, nCusName, nSaleMan, nType, nPayment,
               nMemo, nVal, nLimit, nil, nil);
            //���������в���ʹ��ȫ�ֵ�nList,nQuery

            if Assigned(nModalResult) then
              nModalResult(mrOk);
            //xxxxx
          end);
        Exit;
      end;
    end;

    DoSaveCustomerPayment(nCusID, nCusName, nSaleMan, nType, nPayment,
      nMemo, nVal, 0, nList, nQuery);
    //do save

    if Assigned(nModalResult) then
      nModalResult(mrOk);
    //xxxxx
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
  end
end;

//Desc: ���ʱ�����ö��
function IsAutoPayCredit(const nQuery: TADOQuery): Boolean;
var nStr: string;
begin
  with TStringHelper do
  begin
    nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
    nStr := MacroValue(nStr, [MI('$T', sTable_SysDict),
            MI('$N', sFlag_SysParam), MI('$M', sFlag_PayCredit)]);
    //xxxxx

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
         Result := Fields[0].AsString = sFlag_Yes
    else Result := False;
  end;
end;

//Parm: ǰ׺;����;�ֶ�;����������ų�
//Desc: ����ǰ׺ΪnPrefix,��nTable.nFieldΪ�ο����������
function GetSerialID(const nPrefix, nTable, nField: string;
 const nIncLen: Integer = 3): string;
var nStr,nTmp: string;
    nQuery: TADOQuery;
begin

  Result := ''; nQuery := nil;
  try
    nTmp := FormatDateTime('YYMMDD', Now);

    nStr := 'Select Top 1 %s From %s Where %s Like ''%s'' Order By %s DESC';
    nStr := Format(nStr, [nField, nTable, nField, nPrefix+nTmp+'%', nField]);
    //xxxxx

    nQuery := LockDBQuery(ctWork);
    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      nStr := Fields[0].AsString;
      nStr := Copy(nStr, Length(nStr) - nIncLen + 1, nIncLen);

      if TStringHelper.IsNumber(nStr, False) then
           nStr := IntToStr(StrToInt(nStr) + 1)
      else nStr := '1';
    end else nStr := '1';

    nStr := StringOfChar('0', nIncLen - Length(nStr)) + nStr;
    Result := nPrefix + nTmp + nStr;
  except
    //ignor any error
  end;
end;


//Desc: ����nCusID��һ�����ż�¼
function SaveCustomerCredit(const nCusID,nMemo: string; const nCredit: Double;
 const nEndTime: TDateTime; nVarMan:string): Boolean;
var nStr, nCId: string;
    nVal: Double;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  nList := nil;
  nQuery := nil;
  with TStringHelper,TFloatHelper,TSQLBuilder,TDateTimeHelper do
  try
    nVal := Float2Float(nCredit, cPrecision, False);
    //adjust float value

    nQuery := LockDBQuery(ctWork);
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;

    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_CreditVerify]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
         nStr := Fields[0].AsString
    else nStr := sFlag_No;

    if nStr = sFlag_Yes then //�����
    begin
      nCId:= GetSerialID('V', sTable_CusCredit, 'C_CreditID');

      nStr := MakeSQLByStr([SF('C_CusID', nCusID),
              SF('C_Money', nVal, sfVal),
              SF('C_Man', UniMainModule.FUserConfig.FUserID),
              SF('C_Date', sField_SQLServer_Now, sfVal),
              SF('C_Verify', sFlag_Unknow),
              SF('C_VerMan', nVarMan),
              SF('C_End', DateTime2Str(nEndTime)),
              SF('C_Memo',nMemo), SF('C_CreditID', nCId)
              ], sTable_CusCredit, '', True);
      nList.Add(nStr);

      nStr := MakeSQLByStr([SF('V_CreditID', nCId),
              SF('V_PreFxMan', UniMainModule.FUserConfig.FUserID),
              SF('V_Verify', sFlag_Unknow),
              SF('V_VerMan', nVarMan)
              ], sTable_CusCreditVif, '', True);
      nList.Add(nStr);

    end else
    begin
      nStr := MakeSQLByStr([SF('C_CusID', nCusID),
              SF('C_Money', nVal, sfVal),
              SF('C_Man', UniMainModule.FUserConfig.FUserID),
              SF('C_Date', sField_SQLServer_Now, sfVal),
              SF('C_End', DateTime2Str(nEndTime)),
              SF('C_Verify', sFlag_Yes),
              SF('C_VerMan', UniMainModule.FUserConfig.FUserID),
              SF('C_VerDate', sField_SQLServer_Now, sfVal),
              SF('C_Memo',nMemo)
              ], sTable_CusCredit, '', True);
      nList.Add(nStr);

      nStr := 'Update %s Set A_CreditLimit=A_CreditLimit+%.2f ' +
              'Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, nVal, nCusID]);
      nList.Add(nStr);
    end;

    DBExecute(nList, nQuery);
    Result := True;
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-04-23
//Parm: ǿ�Ƽ���
//Desc: ��ȡ���ݿ�˵���
procedure LoadMenuItems(const nForce: Boolean);
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nIdx := Length(gAllMenus);
    if (nIdx > 0) and (not nForce) then Exit;

    nQuery := LockDBQuery(ctMain);
    //get query

    nStr := 'Select * From %s ' +
         'Where M_ProgID=''%s'' And M_NewOrder>=0 And M_Title<>''-'' ' +
         'Order By M_NewOrder ASC';
    nStr := Format(nStr, [sTable_Menu, gSysParam.FProgID]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(gAllMenus, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with gAllMenus[nIdx] do
        begin
          FEntity    := FieldByName('M_Entity').AsString;
          FMenuID    := FieldByName('M_MenuID').AsString;
          FPMenu     := FieldByName('M_PMenu').AsString;
          FTitle     := FieldByName('M_Title').AsString;
          FImgIndex  := FieldByName('M_ImgIndex').AsInteger;
          FFlag      := FieldByName('M_Flag').AsString;
          FAction    := FieldByName('M_Action').AsString;
          FFilter    := FieldByName('M_Filter').AsString;
          FNewOrder  := FieldByName('M_NewOrder').AsFloat;
          FLangID    := 'cn';
        end;

        Inc(nIdx);
        Next;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-04-23
//Parm: �б���;ʵ������
//Desc: �����˵��б�nTree
procedure BuidMenuTree(const nTree: TUniTreeView; nEntity: string);
var nIdx,nInt: Integer;
    nGroup: Integer;
    nItem: TuniTreeNode;

  //Desc: �����nItem�Ƿ��пɶ�Ȩ��
  function HasPopedom(const nMItem: string): Boolean;
  var i: Integer;
  begin
    Result := UniMainModule.FUserConfig.FIsAdmin;
    if Result then Exit;
    
    with gAllPopedoms[nGroup] do
    begin
      for i := Low(FPopedom) to High(FPopedom) do
      if CompareText(nMItem, FPopedom[i].FItem) = 0 then
      begin 
        Result := Pos(sPopedom_Read, FPopedom[i].FPopedom) > 0;
        Exit;
      end;
    end;
  end;

  //Desc: �����ӽڵ�
  procedure MakeChileMenu(const nParent: TuniTreeNode);
  var i,nTag: Integer;
      nSub: TuniTreeNode;
  begin
    for i := 0 to nInt do
    with gAllMenus[i] do
    begin
      if CompareText(FEntity, nEntity) <> 0 then Continue;
      //not match entity

      nTag := Integer(nParent.Data);
      if CompareText(FPMenu, gAllMenus[nTag].FMenuID) <> 0 then Continue;
      //not sub item

      if not HasPopedom(MakeMenuID(FEntity, FMenuID)) then Continue;
      //no popedom

      nSub := nTree.Items.AddChild(nParent, FTitle);
      nSub.Data := Pointer(i);
      MakeChileMenu(nSub);
    end;
  end;
begin
  if nEntity='' then
    nEntity := 'MAIN';
  //main menu

  GlobalSyncLock;
  try
    nTree.Items.BeginUpdate;
    nTree.Items.Clear;
    nGroup := -1;

    for nIdx := Low(gAllPopedoms) to High(gAllPopedoms) do
    if gAllPopedoms[nIdx].FID = UniMainModule.FUserConfig.FGroupID then
    begin
      nGroup := nIdx;
      Break;
    end;

    if nGroup < 0 then
    begin
      nTree.Items.AddChild(nil, 'Ȩ�޲���');
      Exit;
    end;

    nInt := Length(gAllMenus)-1;
    for nIdx := 0 to nInt do
    with gAllMenus[nIdx] do
    begin
      if CompareText(FEntity, nEntity) <> 0 then Continue;
      //not match entity
      if (FMenuID = '') or (FPMenu <> '') then Continue;
      //not root item
      if not HasPopedom(MakeMenuID(FEntity, FMenuID)) then Continue;
      //no popedom

      nItem := nTree.Items.AddChild(nil, FTitle);
      nItem.Data := Pointer(nIdx);
    end;

    nItem := nTree.Items.GetFirstNode;
    while Assigned(nItem) do
    begin
      MakeChileMenu(nItem);
      nItem := nItem.GetNextSibling;
    end;
  finally
    GlobalSyncRelease;
    nTree.Items.EndUpdate;
  end;

  {$IFDEF DEBUG}
  nTree.FullExpand;
  {$ENDIF}
end;

//Date: 2018-04-24
//Parm: �˵�������
//Desc: ��ȡnIdx�Ĳ˵���ʶ
function GetMenuItemID(const nIdx: Integer): string;
begin
  GlobalSyncLock;
  try
    Result := '';
    if (nIdx >= Low(gAllMenus)) and (nIdx <= High(gAllMenus)) then
     with gAllMenus[nIdx] do
      Result := MakeMenuID(FEntity, FMenuID);
    //xxxxx
  finally
    GlobalSyncRelease;
  end;
end;

//Date: 2018-04-26
//Parm: ģ������
//Desc: ����ģ��ΪnModule�Ĳ˵���
function GetMenuByModule(const nModule: string): string;
var nIdx: Integer;
begin
  with UniMainModule do
  begin
    Result := '';
    //init

    for nIdx := Low(FMenuModule) to High(FMenuModule) do
    with FMenuModule[nIdx] do
    begin
      if CompareText(nModule, FModule) = 0 then
      begin
        Result := FMenuID;
        Exit;
      end;
    end;
  end;
end;

//Date: 2018-04-26
//Parm: �˵���
//Desc: �����˵���ΪnMenu��ģ��
function GetModuleByMenu(const nMenu: string): string;
var nIdx: Integer;
begin
  with UniMainModule do
  begin
    Result := '';
    //init

    for nIdx := Low(FMenuModule) to High(FMenuModule) do
    with FMenuModule[nIdx] do
    begin
      if CompareText(nMenu, FModule) = 0 then
      begin
        Result := FModule;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-04-24
//Parm: ǿ�Ƹ���
//Desc: ���ع����б��ڴ�
procedure LoadFactoryList(const nForce: Boolean);
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nIdx := Length(gAllFactorys);
    if (nIdx > 0) and (not nForce) then Exit;

    nQuery := LockDBQuery(ctMain);
    //get query

    nStr := 'Select * From %s Where F_Valid=''%s'' Order By F_Index ASC';
    nStr := Format(nStr, [sTable_Factorys, sFlag_Yes]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(gAllFactorys, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with gAllFactorys[nIdx] do
        begin
          FFactoryID  := FieldByName('F_ID').AsString;
          FFactoryName:= FieldByName('F_Name').AsString;
          FMITServURL := FieldByName('F_MITUrl').AsString;
          FHardMonURL := FieldByName('F_HardUrl').AsString;
          FWechatURL  := FieldByName('F_WechatUrl').AsString;
          FDBWorkOn   := FieldByName('F_DBConn').AsString;
        end;

        Inc(nIdx);
        Next;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-04-24
//Parm: �б�
//Desc: ���ع����б�nList��
procedure GetFactoryList(const nList: TStrings);
var nIdx: Integer;
begin
  GlobalSyncLock;
  try
    nList.BeginUpdate;
    nList.Clear;

    for nIdx := Low(gAllFactorys) to High(gAllFactorys) do
     with gAllFactorys[nIdx] do
      nList.AddObject(FFactoryID + '.' + FFactoryName, Pointer(nIdx));
    //xxxxx
  finally
    GlobalSyncRelease;
    nList.EndUpdate;
  end;
end;

//Date: 2018-04-24
//Parm: ����;��������
//Desc: ��ȡnIdx�����ݵ�nFactory
function GetFactory(const nIdx: Integer; var nFactory: TFactoryItem): Boolean;
begin
  GlobalSyncLock;
  try
    Result := (nIdx >= Low(gAllFactorys)) and (nIdx <= High(gAllFactorys));
    if Result then
      nFactory := gAllFactorys[nIdx];
    //xxxxx
  finally
    GlobalSyncRelease;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-04-24
//Parm: ǿ�Ƽ���
//Desc: ����Ȩ�޵��ڴ�
procedure LoadPopedomList(const nForce: Boolean);
var nStr: string;
    nIdx,nInt: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nIdx := Length(gAllPopedoms);
    if (nIdx > 0) and (not nForce) then Exit;

    nQuery := LockDBQuery(ctMain);
    //get query
    nStr := 'Select * From ' + sTable_Group;

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(gAllPopedoms, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with gAllPopedoms[nIdx] do
        begin
          FID       := FieldByName('G_ID').AsString;
          FName     := FieldByName('G_NAME').AsString;
          FDesc     := FieldByName('G_DESC').AsString;
          SetLength(FPopedom, 0);
        end;

        Inc(nIdx);
        Next;
      end;
    end;

    //--------------------------------------------------------------------------
    nStr := 'Select * From ' + sTable_Popedom;
    //Ȩ�ޱ�

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      for nIdx := Low(gAllPopedoms) to High(gAllPopedoms) do
      with gAllPopedoms[nIdx] do
      begin
        nInt := 0;
        First;

        while not Eof do
        begin
          if FieldByName('P_Group').AsString = FID then
            Inc(nInt);
          Next;
        end;

        SetLength(FPopedom, nInt);
        nInt := 0;
        First;

        while not Eof do
        begin
          if FieldByName('P_Group').AsString = FID then
          begin
            with FPopedom[nInt] do
            begin
              FItem := FieldByName('P_Item').AsString;
              FPopedom := FieldByName('P_Popedom').AsString;
            end;

            Inc(nInt);
          end;

          Next;
        end;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-04-26
//Parm: �˵���
//Desc: ��ȡ��ǰ�û���nMenu��ӵ�е�Ȩ��
function GetPopedom(const nMenu: string): string;
var nIdx,nGroup: Integer;
begin
  with UniMainModule do
  try
    GlobalSyncLock;
    Result := '';
    nGroup := -1;

    for nIdx := Low(gAllPopedoms) to High(gAllPopedoms) do
    if gAllPopedoms[nIdx].FID = FUserConfig.FGroupID then
    begin
      nGroup := nIdx;
      Break;
    end;

    if nGroup < 0 then Exit;
    //no group match

    with gAllPopedoms[nGroup] do
    begin
      for nIdx := Low(FPopedom) to High(FPopedom) do
      if CompareText(nMenu, FPopedom[nIdx].FItem) = 0 then
      begin
        Result := FPopedom[nIdx].FPopedom;
        Exit;
      end;
    end;
  finally
    GlobalSyncRelease;
  end;
end;

//Date: 2018-04-26
//Parm: �˵���;Ȩ����
//Desc: �жϵ�ǰ�û���nMenu�Ƿ���nPopedomȨ��
function HasPopedom(const nMenu,nPopedom: string): Boolean;
begin
  with UniMainModule do
  begin
    Result := FUserConfig.FIsAdmin or (Pos(nPopedom, GetPopedom(nMenu)) > 0);
  end;
end;

//Date: 2018-04-26
//Parm: Ȩ����;Ȩ����
//Desc: ���nAll���Ƿ���nPopedomȨ����
function HasPopedom2(const nPopedom,nAll: string): Boolean;
begin
  with UniMainModule do
  begin
    Result := FUserConfig.FIsAdmin or (Pos(nPopedom, nAll) > 0);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-04-26
//Parm: ǿ��ˢ��
//Desc: ���������ֵ�
procedure LoadEntityList(const nForce: Boolean);
var nStr: string;
    nIdx,nInt: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nIdx := Length(gAllEntitys);
    if (nIdx > 0) and (not nForce) then Exit;

    nQuery := LockDBQuery(ctMain);
    //get query

    nStr := 'Select * From %s Where E_ProgID=''%s''';
    nStr := Format(nStr, [sTable_Entity, gSysParam.FProgID]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(gAllEntitys, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with gAllEntitys[nIdx] do
        begin
          FEntity := FieldByName('E_Entity').AsString;
          FTitle  := FieldByName('E_Title').AsString;
          SetLength(FDictItem, 0);
        end;

        Inc(nIdx);
        Next;
      end;
    end;

    //--------------------------------------------------------------------------
    nStr := 'Select * From %s Order By D_Index ASC';
    nStr := Format(nStr, ['Sys_DataDict']);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      for nIdx := Low(gAllEntitys) to High(gAllEntitys) do
      with gAllEntitys[nIdx] do
      begin
        nStr := gSysParam.FProgID + '_' + FEntity;
        nInt := 0;
        First;

        while not Eof do
        begin
          if CompareText(nStr, FieldByName('D_Entity').AsString) = 0 then
            Inc(nInt);
          Next;
        end;

        if nInt < 1 then Continue;
        //no entity detail

        SetLength(FDictItem, nInt);
        nInt := 0;
        First;

        while not Eof  do
        begin
          if CompareText(nStr, FieldByName('D_Entity').AsString) = 0 then
          with FDictItem[nInt] do
          begin
            FItemID  := FieldByName('D_ItemID').AsInteger;
            FTitle   := FieldByName('D_Title').AsString;
            FAlign   := TAlignment(FieldByName('D_Align').AsInteger);
            FWidth   := FieldByName('D_Width').AsInteger;
            FIndex   := FieldByName('D_Index').AsInteger;
            FVisible := StrToBool(FieldByName('D_Visible').AsString);
            FLangID  := FieldByName('D_LangID').AsString;

            with FDBItem do
            begin
              FTable := FieldByName('D_DBTable').AsString;
              FField := FieldByName('D_DBField').AsString;
              FIsKey := StrToBool(FieldByName('D_DBIsKey').AsString);

              if Assigned(FindField('D_Locked')) then
              begin
                FLocked:= StrToBool(FieldByName('D_Locked').AsString);
              end else FLocked := False;

              FType  := TFieldType(FieldByName('D_DBType').AsInteger);
              FWidth := FieldByName('D_DBWidth').AsInteger;
              FDecimal:= FieldByName('D_DBDecimal').AsInteger;
            end;

            with FFormat do
            begin
              FStyle  := TDictFormatStyle(FieldByName('D_FmtStyle').AsInteger);
              FData   := FieldByName('D_FmtData').AsString;
              FFormat := FieldByName('D_FmtFormat').AsString;
              FExtMemo:= FieldByName('D_FmtExtMemo').AsString;
            end;

            with FFooter do
            begin
              FDisplay := FieldByName('D_FteDisplay').AsString;
              FFormat := FieldByName('D_FteFormat').AsString;
              FKind := TDictFooterKind(FieldByName('D_FteKind').AsInteger);
              FPosition := TDictFooterPosition(FieldByName('D_FtePositon').AsInteger);
            end;

            Inc(nInt);
          end;

          Next;
        end;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-05-11
//Parm: ���ݼ�
//Desc: ����nClientDS��������
procedure BuidDataSetSortIndex(const nClientDS: TClientDataSet);
var nStr: string;
    nIdx: Integer;
begin
  with nClientDS do
  begin
    for nIdx := FieldCount-1 downto 0 do
    begin
      nStr := Fields[nIdx].FieldName + '_asc';
      if IndexDefs.IndexOf(nStr) < 0 then
        IndexDefs.Add(nStr, Fields[nIdx].FieldName, []);
      //xxxxx

      nStr := Fields[nIdx].FieldName + '_des';
      if IndexDefs.IndexOf(nStr) < 0 then
        IndexDefs.Add(nStr, Fields[nIdx].FieldName, [ixDescending]);
      //xxxxx
    end;
  end;
end;

//Date: 2018-04-26
//Parm: ʵ������;�б�;�ų��ֶ�
//Desc: ʹ�������ֵ�nEntity����nGrid�ı�ͷ
procedure BuildDBGridColumn(const nEntity: string; const nGrid: TUniDBGrid;
 const nFilter: string);
var i,nIdx: Integer;
    nList: TStrings;
    nColumn: TUniBaseDBGridColumn;
    nStr:string;
begin
  with nGrid do
  begin
    BorderStyle := ubsDefault;
    LoadMask.Message := '���ڼ������ݡ����Ժ�';
    Options := [dgTitles, dgIndicator, dgColLines, dgRowLines, dgRowSelect];

    if UniMainModule.FGridColumnAdjust then
      Options := Options + [dgColumnResize, dgColumnMove];
    //ѡ�����

    ReadOnly := True;
    WebOptions.Paged := True;
    WebOptions.PageSize := 1000;

    if not Assigned(OnColumnSort) then
      OnColumnSort := UniMainModule.DoColumnSort;
    if not Assigned(OnColumnSummary) then
      OnColumnSummary := UniMainModule.DoColumnSummary;
    if not Assigned(OnColumnSummaryResult) then
      OnColumnSummaryResult := UniMainModule.DoColumnSummaryResult;
    if not Assigned(OnColumnSummaryTotal) then
      OnColumnSummaryTotal := UniMainModule.DoColumnSummaryTotal;
    //xxxxx
  end;

  if nEntity = '' then Exit;
  //manual column

  nList := nil;
  try
    GlobalSyncLock;
    nGrid.Columns.BeginUpdate;
    nIdx := -1;
    //init

    for i := Low(gAllEntitys) to High(gAllEntitys) do
    if CompareText(nEntity, gAllEntitys[i].FEntity) = 0 then
    begin
      nIdx := i;
      Break;
    end;

    if nIdx < 0 then Exit;
    //no entity match

    if nFilter <> '' then
    begin
      nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
      TStringHelper.Split(nFilter, nList, 0, ';');
    end;

    with gAllEntitys[nIdx],nGrid do
    begin
      with Summary do
      begin
        Enabled := False;
        GrandTotal := False;
      end;

      Tag := nIdx;
      Columns.Clear;
      //clear first

      for i := Low(FDictItem) to High(FDictItem) do
      with FDictItem[i] do
      begin
        if not FVisible then Continue;

        if Assigned(nList) and (nList.IndexOf(FDBItem.FField) >= 0) then
          Continue;
        //�ֶα�����,������ʾ

        nColumn := Columns.Add;
        with nColumn do
        begin
          Tag := i;
          Sortable := True;
          Alignment := FAlign;
          FieldName := FDBItem.FField;

          if FDBItem.FLocked then
            Locked:= FDBItem.FLocked;

          Title.Alignment := FAlign;
          Title.Caption := FTitle;
          Width := FWidth;

          if (FFooter.FKind = fkSum) or (FFooter.FKind = fkCount) then
          begin
            nColumn.ShowSummary := True;
            Summary.Enabled := True;
            Summary.GrandTotal:= True;
          end;
        end;
      end;
    end;
  finally
    GlobalSyncRelease;
    gMG.FObjectPool.Release(nList);
    nGrid.Columns.EndUpdate;
  end;
end;

//Date: 2018-05-10
//Parm: ʵ��;���ݼ�;�����¼�
//Desc: ����nClientDS���ݸ�ʽ��
procedure SetGridColumnFormat(const nEntity: string;
  const nClientDS: TClientDataSet; const nOnData: TFieldGetTextEvent);
var nIdx,nEn,nL,nH: Integer;
    nField: TField;
begin
  try
    GlobalSyncLock;
    nEn := -1;
    //init

    for nIdx := Low(gAllEntitys) to High(gAllEntitys) do
    if CompareText(nEntity, gAllEntitys[nIdx].FEntity) = 0 then
    begin
      nEn := nIdx;
      Break;
    end;

    if nEn < 0 then Exit;
    //no entity match
    nClientDS.Tag := nEn;

    nL := Low(gAllEntitys[nEn].FDictItem);
    nH := High(gAllEntitys[nEn].FDictItem);

    for nIdx := nL to nH do
    with gAllEntitys[nEn].FDictItem[nIdx] do
    begin
      if FFormat.FStyle <> fsFixed then Continue;
      if Trim(FFormat.FData) = '' then Continue;

      nField := nClientDS.FindField(FDBItem.FField);
      if Assigned(nField) then
      begin
        nField.Tag := nIdx;
        nField.OnGetText := nOnData;
      end;
    end;
  finally
    GlobalSyncRelease;
  end;
end;

//Date: 2018-04-27
//Parm: ������;���;��ȡ
//Desc: ��дnForm.nGrid���û�����
procedure UserDefineGrid(const nForm: string; const nGrid: TUniDBGrid;
  const nLoad: Boolean; const nIni: TIniFile = nil);
var nStr: string;
    i,j,nCount: Integer;
    nTmp: TIniFile;
    nList: TStrings;
begin
  nTmp := nil;
  nList := nil;

  with TStringHelper do
  try
    if Assigned(nIni) then
         nTmp := nIni
    else nTmp := UserConfigFile;

    nCount := nGrid.Columns.Count - 1;
    //column num

    if nLoad then
    begin
      nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
      nStr := nTmp.ReadString(nForm, 'GridIndex_' + nGrid.Name, '');
      if Split(nStr, nList, nGrid.Columns.Count) then
      begin
        for i := 0 to nCount do
        begin
          if not IsNumber(nList[i], False) then Continue;
          //not valid

          for j := 0 to nCount do
          if nGrid.Columns[j].Tag = StrToInt(nList[i]) then
          begin
            nGrid.Columns[j].Index := i;
            Break;
          end;
        end;
      end;

      nStr := nTmp.ReadString(nForm, 'GridWidth_' + nGrid.Name, '');
      if Split(nStr, nList, nGrid.Columns.Count) then
      begin
        for i := 0 to nCount do
         if IsNumber(nList[i], False) then
          nGrid.Columns[i].Width := StrToInt(nList[i]);
        //apply width
      end;

      if not UniMainModule.FGridColumnAdjust then //����ʱȫ����ʾ
      begin
        nStr := nTmp.ReadString(nForm, 'GridVisible_' + nGrid.Name, '');
        if Split(nStr, nList, nGrid.Columns.Count) then
        begin
          for i := 0 to nCount do
            nGrid.Columns[i].Visible := nList[i] = '1';
          //apply visible
        end;
      end;
    end else
    begin
      if UniMainModule.FGridColumnAdjust then //save manual adjust grid
      begin
        nStr := '';
        for i := 0 to nCount do
        begin
          nStr := nStr + IntToStr(nGrid.Columns[i].Tag);
          if i <> nCount then nStr := nStr + ';';
        end;
        nTmp.WriteString(nForm, 'GridIndex_' + nGrid.Name, nStr);

        nStr := '';
        for i := 0 to nCount do
        begin
          nStr := nStr + IntToStr(nGrid.Columns[i].Width);
          if i <> nCount then nStr := nStr + ';';
        end;
        nTmp.WriteString(nForm, 'GridWidth_' + nGrid.Name, nStr);
      end else
      begin
        nStr := '';
        for i := 0 to nCount do
        begin
          if nGrid.Columns[i].Visible then
               nStr := nStr + '1'
          else nStr := nStr + '0';
          if i <> nCount then nStr := nStr + ';';
        end;
        nTmp.WriteString(nForm, 'GridVisible_' + nGrid.Name, nStr);
      end;
    end;
  finally
    gMG.FObjectPool.Release(nList);
    if not Assigned(nIni) then
      nTmp.Free;
    //xxxxx
  end;
end;

//Date: 2018-05-24
//Parm: ������;���;��ȡ
//Desc: ��дnForm.nGrid���û�����
procedure UserDefineStringGrid(const nForm: string; const nGrid: TUniStringGrid;
  const nLoad: Boolean; const nIni: TIniFile = nil);
var nStr: string;
    nIdx,nCount: Integer;
    nTmp: TIniFile;
    nList: TStrings;
begin
  nTmp := nil;
  nList := nil;

  with TStringHelper do
  try
    if Assigned(nIni) then
         nTmp := nIni
    else nTmp := UserConfigFile;

    nCount := nGrid.Columns.Count - 1;
    //column num

    if nLoad then
    begin
      nStr := 'columnresize=function columnresize(ct,column,width,eOpts){'+
        'ajaxRequest($O, ''$E'', [''idx=''+column.dataIndex,''w=''+width])}';
      //add resize event

      nStr := MacroValue(nStr, [MI('$O', nForm + '.' + nGrid.Name),
        MI('$E', sEvent_StrGridColumnResize)]);
      //xxxx

      nIdx := nGrid.ClientEvents.ExtEvents.IndexOf(nStr);
      if UniMainModule.FGridColumnAdjust and (nIdx < 0) then
      begin
        nGrid.Options := nGrid.Options + [goColSizing];
        //��ӿɵ��п�

        nGrid.ClientEvents.ExtEvents.Add(nStr);
        //����¼�����

        if not Assigned(nGrid.OnAjaxEvent) then
          nGrid.OnAjaxEvent := UniMainModule.DoDefaultAdjustEvent;
        //����¼�����
      end else
      begin
        nGrid.Options := nGrid.Options - [goColSizing];
        //ɾ���ɵ��п�

        if nIdx >= 0 then
          nGrid.ClientEvents.ExtEvents.Delete(nIdx);
        //xxxxx
      end;

      nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
      nStr := nTmp.ReadString(nForm, 'GridWidth_' + nGrid.Name, '');

      if Split(nStr, nList, nGrid.Columns.Count) then
      begin
        for nIdx := 0 to nCount do
         if (nGrid.Columns[nIdx].Width>0) and IsNumber(nList[nIdx], False) then
          nGrid.Columns[nIdx].Width := StrToInt(nList[nIdx]);
        //apply width
      end;
    end else

    if UniMainModule.FGridColumnAdjust then    
    begin
      nStr := '';
      for nIdx := 0 to nCount do
      begin
        nStr := nStr + IntToStr(nGrid.Columns[nIdx].Width);
        if nIdx <> nCount then nStr := nStr + ';';
      end;
      nTmp.WriteString(nForm, 'GridWidth_' + nGrid.Name, nStr);
    end;
  finally
    gMG.FObjectPool.Release(nList);
    if not Assigned(nIni) then
      nTmp.Free;
    //xxxxx
  end;
end;

//Date: 2018-05-24
//Parm: ���;����
//Desc: �û������п�ʱ����,���û������Ľ��Ӧ�õ�nGrid.
procedure DoStringGridColumnResize(const nGrid: TObject;
  const nParam: TUniStrings);
var nStr: string;
    nIdx,nW: Integer;
begin
  with TStringHelper,TUniStringGrid(nGrid) do
  begin
    nStr := nParam.Values['idx'];
    if IsNumber(nStr, False) then
         nIdx := StrToInt(nStr)
    else nIdx := -1;

    if (nIdx < 0) or (nIdx >= Columns.Count) then Exit;
    //out of range

    nStr := nParam.Values['w'];
    if IsNumber(nStr, False) then
         nW := StrToInt(nStr)
    else nW := -1;

    if nW < 0 then Exit;
    if nW > 320 then
      nW := 320;
    Columns[nIdx].Width := nW;
  end;
end;

//Date: 2018-05-04
//Parm: �б���;���
//Desc: ʹ��nWideths����nGrid��ͷ���
procedure LoadGridColumn(const nWidths: string; const nGrid: TUniStringGrid);
var nList: TStrings;
    i,nCount: integer;
begin
  with nGrid do
  begin
    FixedCols := 0;
    FixedRows := 0;
    BorderStyle := ubsDefault;
    Options := [goVertLine,goHorzLine,goColSizing,goRowSelect];
    //style
  end;

  if (nWidths <> '') and (nGrid.Columns.Count > 0) then
  begin
    nList := TStringList.Create;
    try
      if TStringHelper.Split(nWidths, nList, nGrid.Columns.Count, ';') then
      begin
        nCount := nList.Count - 1;
        for i:=0 to nCount do
         if TStringHelper.IsNumber(nList[i], False) then
          nGrid.Columns[i].Width := StrToInt(nList[i]);
      end;
    finally
      nList.Free;
    end;
  end;
end;

//Date: 2018-05-04
//Parm: ���
//Desc: ����nGrid��ͷ����ַ���
function MakeGridColumnInfo(const nGrid: TUniStringGrid): string;
var i,nCount: integer;
begin
  Result := '';
  nCount := nGrid.Columns.Count - 1;

  for i:=0 to nCount do
  if i = nCount then
       Result := Result + IntToStr(nGrid.Columns[i].Width)
  else Result := Result + IntToStr(nGrid.Columns[i].Width) + ';';
end;

//Date: 2018-05-22
//Parm: ���;�ļ���
//Desc: ��nGrid�����ݵ�����nFile�ļ�
function GridExportExcel(const nGrid: TUniDBGrid; const nFile: string): string;
var nIdx: Integer;
    nGrd: TDBGrid;
    nExcel: TDBGrid2Excel;
begin
  Result := '';
  nGrd := nil;
  nExcel := nil;
  try
    try
      nGrd := gMG.FObjectPool.Lock(TDBGrid) as TDBGrid;
      //get grid

      with nGrd do
      begin
        Columns.Clear;
        TitleFont.Charset := GB2312_CHARSET;
        TitleFont.Name := '����';
        TitleFont.Size := 11;
      end;

      for nIdx := 0 to nGrid.Columns.Count - 1 do
      begin
        if not nGrid.Columns[nIdx].Visible then Continue;
        //no visible,no export

        with nGrd.Columns.Add do
        begin
          Title.Caption := nGrid.Columns[nIdx].Title.Caption;
          FieldName := nGrid.Columns[nIdx].FieldName;
          Width := nGrid.Columns[nIdx].Width;
          Color := clWhite;

          Font.Charset := GB2312_CHARSET;
          Font.Name := '����';
          Font.Size := 9;
          //Font.Color := clWhite;
        end;
      end;

      nGrd.DataSource := nGrid.DataSource;
      nExcel := gMG.FObjectPool.Lock(TDBGrid2Excel) as TDBGrid2Excel;
      //get exporter

      with nExcel do
      begin
        DBGrid := nGrd;
        SaveDBGridAs(nFile);
      end;

      nExcel.DBGrid := nil;
      nGrd.DataSource := nil;
      nGrd.Columns.Clear;
    except
      on nErr: Exception do
      begin
        Result := '���ݵ�������: ' + nErr.Message;
      end;
    end;
  finally
    gMG.FObjectPool.Release(nGrd);
    gMG.FObjectPool.Release(nExcel);
  end;
end;

//Desc: ��ӡnGrid���
function GridPrintData(const nQuery: TADOQuery; var nTitle: string): Boolean;
begin

end;
//------------------------------------------------------------------------------
//Date: 2018-05-17
//Parm: ���ڱ��;��ʾ
//Desc: ���nWeek�Ƿ���ڻ����
function IsWeekValid(const nWeek: string; var nHint: string;
  var nBegin,nEnd: TDateTime; const nQuery: TADOQuery): Boolean;
var nStr: string;
    nInt: Integer;
begin
  with TStringHelper do
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SettleValid]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
         nInt := Fields[0].AsInteger
    else nInt := 0;

    nStr := 'Select W_Begin,W_End,$Now From $W Where W_NO=''$NO''';
    nStr := MacroValue(nStr, [MI('$W', sTable_InvoiceWeek),
            MI('$Now', sField_SQLServer_Now), MI('$NO', nWeek)]);
    //xxxxx

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      nBegin := Fields[0].AsDateTime;
      nEnd   := Fields[1].AsDateTime;
      Result := nEnd + nInt + 1 > Fields[2].AsDateTime;
      if not Result then
        nHint := '�ý��������ѽ���';
      //xxxxx
    end else
    begin
      Result := False;
      nHint := '�ý�����������Ч';
    end;
  end;
end;

//Date: 2018-05-17
//Parm: ���ڱ��
//Desc: ���nWeek�Ƿ�������
function IsWeekHasEnable(const nWeek: string; const nQuery: TADOQuery): Boolean;
var nStr: string;
begin
  with TStringHelper do
  begin
    nStr := 'Select Top 1 * From $Req Where R_Week=''$NO''';
    nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq), MI('$NO', nWeek)]);
    Result := DBQuery(nStr, nQuery).RecordCount > 0;
  end;
end;

//Date: 2018-05-17
//Parm: ���ڱ��
//Desc: ���nWeek����������Ƿ�������
function IsNextWeekEnable(const nWeek: string; const nQuery: TADOQuery): Boolean;
var nStr: string;
begin
  with TStringHelper do
  begin
    nStr := 'Select Top 1 * From $Req Where R_Week In ' +
            '( Select W_NO From $W Where W_Begin > (' +
            '  Select Top 1 W_Begin From $W Where W_NO=''$NO''))';
    nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq),
            MI('$W', sTable_InvoiceWeek), MI('$NO', nWeek)]);
    Result := DBQuery(nStr, nQuery).RecordCount > 0;
  end;
end;

//Desc: ���nWeek�����ܷ����ٴ�����
function IsWeekCanZZ(const nWeek: string; const nQuery: TADOQuery): Boolean;
var nStr: string;
begin
  with TStringHelper do
  begin
    nStr := 'Select * From $Stl Where S_Week=''$NO'' ';
    nStr := MacroValue(nStr, [MI('$Stl', sTable_InvSettle),MI('$NO', nWeek)]);
    Result := DBQuery(nStr, nQuery).RecordCount > 0;
  end;
end;

//Date: 2018-05-17
//Parm: ���ڱ��
//Desc: ���nWeeǰ��������Ƿ��ѽ������
function IsPreWeekOver(const nWeek: string; const nQuery: TADOQuery; var nPreWeek:string): Integer;
var nStr: string;
begin
  with TStringHelper do
  begin
//    nStr := 'Select Count(*) From $Req Where (R_Week In ( ' +
//            ' Select W_NO From $W Where W_Begin < (' +
//            '  Select Top 1 W_Begin From $W Where W_NO=''$NO''))) And ' +
//            '(R_Value<>R_KValue) And (R_KPrice <> 0)';
//    nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq),
//            MI('$W', sTable_InvoiceWeek), MI('$NO', nWeek)]);
    //xxxxx

    nStr := 'Select R_Week, Count(*) From $Req Where (R_Week<>''$NO'') And ' +
            '(R_Value<>R_KValue) And (R_KPrice <> 0) And R_Chk=1 Group by R_Week';
    nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq),
            MI('$W', sTable_InvoiceWeek), MI('$NO', nWeek)]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      nPreWeek:= Fields[0].AsString;
      Result  := Fields[1].AsInteger;
    end
    else Result := 0;
  end;
end;

function GetLeftStr(SubStr, Str: string): string;
begin
   Result := Copy(Str, 1, Pos(SubStr, Str) - 1);
end;

function GetRightStr(SubStr, Str: string): string;
var
   i: integer;
begin
   i := pos(SubStr, Str);
   if i > 0 then
     Result := Copy(Str
       , i + Length(SubStr)
       , Length(Str) - i - Length(SubStr) + 1)
   else
     Result := '';
end;

//Desc: ��ȡnStockƷ�ֵı����ļ�
function GetReportFileByStock(const nStock: string): string;
begin
  Result := TStringHelper.GetPinYin(nStock);

  if Pos('dj', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42_DJ.fr3'
  else if Pos('gsysl', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_gsl.fr3'
  else if Pos('kzf', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_kzf.fr3'
  else if Pos('qz', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_qz.fr3'
  else if Pos('32', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan32.fr3'
  else if Pos('42', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42.fr3'
  else if Pos('52', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan42.fr3'

  else if Pos('dlsn', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_DaoLu.fr3'
  else if Pos('zrsn', Result) > 0 then
    Result := gPath + sReportDir + 'HuaYan_ZhongRe.fr3'
  else Result := '';
end;

//Desc: ��ӡ��ʶΪnHID�Ļ��鵥
function PrintHuaYanReport(const nHID: string): Boolean;
var nStr,nSR: string;
    nQuery: TADOQuery;
var
  FDR: TFDR;
begin
  Result := True;
  FDR := TFDR(UniMainModule.GetFormInstance(TFDR));
  try
    with TStringHelper, TDateTimeHelper do
    begin
      nSR := 'Select * From %s sr ' +
             ' Left Join %s sp on sp.P_ID=sr.R_PID';
      nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

      nStr := 'Select hy.*,sr.*,C_Name,(case when H_PrintNum>0 THEN ''��'' ELSE '''' END) AS IsBuDan From $HY hy ' +
              ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
              ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
              'Where H_ID in ($ID)';
      //xxxxx

      nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
              MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nHID)]);
      //xxxxx

      nQuery := LockDBQuery(ctMain);
      //get query
      DBQuery(nStr, nQuery);
      if nQuery.RecordCount < 1 then
      begin
        nStr := '���Ϊ[ %s ] �Ļ��鵥��¼����Ч!!';
        nStr := Format(nStr, [nHID]);
        Exit;
      end;

      nStr := nQuery.FieldByName('P_Stock').AsString;
      nStr := GetReportFileByStock(nStr);
      if not FDR.LoadReportFile(nStr) then
      begin
        nStr := '�޷���ȷ���ر����ļ�';
        Exit;
      end;

      FDR.Dataset1.DataSet := nQuery;
      FDR.ShowReport(FDR.GenReportPDF);
      Result := FDR.PrintSuccess;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;


//Desc: ��ӡ��ʶΪnHID�Ļ��鵥    ����ӡ3������
function PrintHuaYanReport_3(const nHID: string): Boolean;
var nStr,nSR: string;
    nQuery: TADOQuery;
var
  FDR: TFDR;
begin
  Result := True;
  FDR := TFDR(UniMainModule.GetFormInstance(TFDR));
  try
    with TStringHelper, TDateTimeHelper do
    begin
      nSR := 'Select R_ID,R_SerialNo,R_PID,R_SGType,R_SGValue,R_HHCType,R_HHCValue,R_MgO,R_SO3,R_ShaoShi,R_CL,R_BiBiao,R_ChuNing,R_ZhongNing, ' +
             'R_AnDing,R_XiDu,R_Jian,R_ChouDu,R_BuRong,R_YLiGai,R_Water,R_KuangWu,R_GaiGui,R_3DZhe1,R_3DZhe2,R_3DZhe3,''-'' R_28Zhe1,''-'' R_28Zhe2,''-'' R_28Zhe3, ' +
             'R_3DYa1,R_3DYa2,R_3DYa3,R_3DYa4,R_3DYa5,R_3DYa6,''-'' R_28Ya1,''-'' R_28Ya2,''-'' R_28Ya3,''-'' R_28Ya4,''-'' R_28Ya5,''-'' R_28Ya6,   ' +
             'R_Date,R_Man,R_HHCValueBak,R_HHCValueHJ,R_GanSuo,R_NaiMo,R_C4AF,R_C3A,R_C3S,R_7DZhe1,R_7DZhe2,R_7DZhe3,R_7DYa1,R_7DYa2,R_7DYa3,  ' +
             'R_7DYa4,R_7DYa5,R_7DYa6,R_3DShui1,R_3DShui2,R_7DShui1,R_7DShui2,''-'' R_28DShui1,''-'' R_28DShui2,R_ZhuMoJi,R_ZhuMoJiValue,R_LvSuanSG, sp.* From %s sr  ' +
             'Left Join %s sp on sp.P_ID=sr.R_PID ';
      nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

      nStr := 'Select hy.*,sr.*,C_Name,(case when H_PrintNum>0 THEN ''��'' ELSE '''' END) AS IsBuDan From $HY hy ' +
              ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
              ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
              'Where H_ID in ($ID)';
      //xxxxx

      nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
              MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nHID)]);
      //xxxxx

      nQuery := LockDBQuery(ctMain);
      //get query
      DBQuery(nStr, nQuery);
      if nQuery.RecordCount < 1 then
      begin
        nStr := '���Ϊ[ %s ] �Ļ��鵥��¼����Ч!!';
        nStr := Format(nStr, [nHID]);
        Exit;
      end;

      nStr := nQuery.FieldByName('P_Stock').AsString;
      nStr := GetReportFileByStock(nStr);
      if not FDR.LoadReportFile(nStr) then
      begin
        nStr := '�޷���ȷ���ر����ļ�';
        Exit;
      end;

      FDR.Dataset1.DataSet := nQuery;
      FDR.ShowReport(FDR.GenReportPDF);
      Result := FDR.PrintSuccess;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;





initialization
  gSyncLock := TCriticalSection.Create;
finalization
  FreeAndNil(gSyncLock);
end.


