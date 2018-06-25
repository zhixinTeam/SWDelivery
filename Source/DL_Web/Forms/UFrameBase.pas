{*******************************************************************************
  ����: dmzn@163.com 2018-04-25
  ����: Frame����
*******************************************************************************}
unit UFrameBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, MainModule, USysConst, Data.DB, uniGUITypes, uniGUIFrame,
  Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniToolBar, uniGUIBaseClasses, Data.Win.ADODB;

type
  TfFrameBase = class(TUniFrame)
    PanelWork: TUniContainerPanel;
    UniToolBar1: TUniToolBar;
    BtnAdd: TUniToolButton;
    BtnEdit: TUniToolButton;
    BtnDel: TUniToolButton;
    UniToolButton4: TUniToolButton;
    BtnRefresh: TUniToolButton;
    BtnPrint: TUniToolButton;
    BtnPreview: TUniToolButton;
    BtnExport: TUniToolButton;
    UniToolButton10: TUniToolButton;
    UniToolButton11: TUniToolButton;
    BtnExit: TUniToolButton;
    PanelQuick: TUniSimplePanel;
    DBGridMain: TUniDBGrid;
    ClientDS: TClientDataSet;
    DataSource1: TDataSource;
    procedure UniFrameCreate(Sender: TObject);
    procedure UniFrameDestroy(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
    procedure BtnExportClick(Sender: TObject);
  private
    { Private declarations }
  protected
    FDBType: TAdoConnectionType;
    {*��������*}
    FEntity: string;
    FMenuID: string;
    FPopedom: string;
    {*Ȩ����*}
    FWhere: string;
    {*��������*}
    procedure OnCreateFrame(const nIni: TIniFile); virtual;
    procedure OnDestroyFrame(const nIni: TIniFile); virtual;
    procedure OnLoadPopedom; virtual;
    {*���ຯ��*}
    function FilterColumnField: string; virtual;
    procedure OnLoadGridConfig(const nIni: TIniFile); virtual;
    procedure OnSaveGridConfig(const nIni: TIniFile); virtual;
    {*�������*}
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
     const nQuery: TADOQuery = nil); virtual;
    procedure InitFormData(const nWhere: string = '';
     const nQuery: TADOQuery = nil); virtual;
    function InitFormDataSQL(const nWhere: string): string; virtual;
    procedure AfterInitFormData; virtual;
    {*��������*}
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  ULibFun, USysBusiness, USysDB, uniPageControl;

procedure TfFrameBase.UniFrameCreate(Sender: TObject);
var nIni: TIniFile;
begin
  FDBType := ctWork;
  FMenuID := GetMenuByModule(ClassName);
  FEntity := FMenuID;

  FPopedom := GetPopedom(FMenuID);
  OnLoadPopedom; //����Ȩ��

  nIni := nil;
  try
    nIni := UserConfigFile;
    //PanelQuick.Height := nIni.ReadInteger(ClassName, 'PanelQuick', 50);

    OnCreateFrame(nIni);
    //���ദ��
    OnLoadGridConfig(nIni);
    //�����û�����
  finally
    nIni.Free;
  end;

  InitFormData; //��ʼ������
end;

procedure TfFrameBase.UniFrameDestroy(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := UserConfigFile;
    //nIni.WriteInteger(ClassName, 'PanelQuick', PanelQuick.Height);

    OnDestroyFrame(nIni);
    //���ദ��
    OnSaveGridConfig(nIni);
    //�����û�����
  finally
    nIni.Free;
  end;

  if ClientDS.Active then
    ClientDS.EmptyDataSet;
  //������ݼ�
end;

procedure TfFrameBase.OnCreateFrame(const nIni: TIniFile);
begin

end;

procedure TfFrameBase.OnDestroyFrame(const nIni: TIniFile);
begin

end;

//Desc: ��ȡȨ��
procedure TfFrameBase.OnLoadPopedom;
begin
  BtnAdd.Enabled      := HasPopedom2(sPopedom_Add, FPopedom);
  BtnEdit.Enabled     := HasPopedom2(sPopedom_Edit, FPopedom);
  BtnDel.Enabled      := HasPopedom2(sPopedom_Delete, FPopedom);
  BtnPrint.Enabled    := HasPopedom2(sPopedom_Print, FPopedom);
  BtnPreview.Enabled  := HasPopedom2(sPopedom_Preview, FPopedom);
  BtnExport.Enabled   := HasPopedom2(sPopedom_Export, FPopedom);
end;

//Desc: ���˲���ʾ
function TfFrameBase.FilterColumnField: string;
begin
  Result := '';
end;

procedure TfFrameBase.OnLoadGridConfig(const nIni: TIniFile);
begin
  BuildDBGridColumn(FEntity, DBGridMain, FilterColumnField());
  //������ͷ

  UserDefineGrid(ClassName, DBGridMain, True, nIni);
  //�Զ����ͷ����
end;

procedure TfFrameBase.OnSaveGridConfig(const nIni: TIniFile);
begin
  UserDefineGrid(ClassName, DBGridMain, False, nIni);
end;

//Desc: ִ�����ݲ�ѯ
procedure TfFrameBase.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
begin

end;

//Desc: ������������SQL���
function TfFrameBase.InitFormDataSQL(const nWhere: string): string;
begin
  Result := '';
end;

//Desc: �����������
procedure TfFrameBase.InitFormData(const nWhere: string;
  const nQuery: TADOQuery);
var nStr: string;
    nBool: Boolean;
    nC: TADOQuery;
begin
  nC := nil;
  try
    if Assigned(nQuery) then
         nC := nQuery
    else nC := LockDBQuery(FDBType);

    nBool := True;
    OnInitFormData(nBool, nWhere, nC);
    if not nBool then Exit;

    nStr := InitFormDataSQL(nWhere);
    if nStr = '' then Exit;

    DBQuery(nStr, nC, ClientDS);
    //query data
    BuidDataSetSortIndex(ClientDS);
    //sort index

    SetGridColumnFormat(FEntity, ClientDS, UniMainModule.DoColumnFormat);
    //�и�ʽ��
  finally
    if not Assigned(nQuery) then
      ReleaseDBQuery(nC);
    AfterInitFormData;
  end
end;

//Desc: ���������
procedure TfFrameBase.AfterInitFormData;
begin

end;

//------------------------------------------------------------------------------
//Desc: �ر�
procedure TfFrameBase.BtnExitClick(Sender: TObject);
var nSheet: TUniTabSheet;
begin
  nSheet := Parent as TUniTabSheet;
  nSheet.Close;
end;

//Desc: ˢ��
procedure TfFrameBase.BtnRefreshClick(Sender: TObject);
begin
  FWhere := '';
  InitFormData(FWhere);
end;

//Desc: ����
procedure TfFrameBase.BtnExportClick(Sender: TObject);
var nStr,nFile: string;
begin
  if (not ClientDS.Active) or (ClientDS.RecordCount < 1) then
  begin
    ShowMessage('û����Ҫ����������');
    Exit;
  end;

  nStr := '�Ƿ�Ҫ������ǰ����ڵ�����?';
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    begin
      if Res <> mrYes then Exit;
      nFile := gPath + 'files\' + UserFlagByID + '.xls';

      if FileExists(nFile) then
        DeleteFile(nFile);
      //xxxxx

      nStr := GridExportExcel(DBGridMain, nFile);
      if nStr = '' then
      begin
        UniSession.SendFile(nFile);
        //send file
      end else ShowMessage(nStr);
    end);
  //xxxxx
end;

end.
