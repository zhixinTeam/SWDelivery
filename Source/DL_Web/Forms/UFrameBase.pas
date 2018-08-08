{*******************************************************************************
  作者: dmzn@163.com 2018-04-25
  描述: Frame基类
*******************************************************************************}
unit UFrameBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, MainModule, USysConst, Data.DB, uniGUITypes, uniGUIFrame,
  Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniToolBar, uniGUIBaseClasses, Data.Win.ADODB, frxClass, frxExportPDF,
  frxDBSet;

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
    frxdbDs1: TfrxDBDataset;
    frxRprt1: TfrxReport;
    frxpdfxprt1: TfrxPDFExport;
    procedure UniFrameCreate(Sender: TObject);
    procedure UniFrameDestroy(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
    procedure BtnExportClick(Sender: TObject);
    procedure BtnPrintClick(Sender: TObject);
  private
    { Private declarations }
    function GenReportPDF(const RepName: string): string;
  protected
    FDBType: TAdoConnectionType;
    {*数据连接*}
    FEntity: string;
    FMenuID: string;
    FPopedom: string;
    {*权限项*}
    FWhere: string;
    {*过滤条件*}
    procedure OnCreateFrame(const nIni: TIniFile); virtual;
    procedure OnDestroyFrame(const nIni: TIniFile); virtual;
    procedure OnLoadPopedom; virtual;
    {*基类函数*}
    function FilterColumnField: string; virtual;
    procedure OnLoadGridConfig(const nIni: TIniFile); virtual;
    procedure OnSaveGridConfig(const nIni: TIniFile); virtual;
    {*表格配置*}
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
     const nQuery: TADOQuery = nil); virtual;
    procedure InitFormData(const nWhere: string = '';
     const nQuery: TADOQuery = nil); virtual;
    function InitFormDataSQL(const nWhere: string): string; virtual;
    procedure AfterInitFormData; virtual;
    {*载入数据*}
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  ULibFun, USysBusiness, USysDB, uniPageControl, ServerModule;

procedure TfFrameBase.UniFrameCreate(Sender: TObject);
var nIni: TIniFile;
begin
  FDBType := ctWork;
  FMenuID := GetMenuByModule(ClassName);
  FEntity := FMenuID;

  FPopedom := GetPopedom(FMenuID);
  OnLoadPopedom; //加载权限

  nIni := nil;
  try
    nIni := UserConfigFile;
    //PanelQuick.Height := nIni.ReadInteger(ClassName, 'PanelQuick', 50);

    OnCreateFrame(nIni);
    //子类处理
    OnLoadGridConfig(nIni);
    //载入用户配置
  finally
    nIni.Free;
  end;

  InitFormData; //初始化数据
end;

procedure TfFrameBase.UniFrameDestroy(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := UserConfigFile;
    //nIni.WriteInteger(ClassName, 'PanelQuick', PanelQuick.Height);

    OnDestroyFrame(nIni);
    //子类处理
    OnSaveGridConfig(nIni);
    //保存用户配置
  finally
    nIni.Free;
  end;

  if ClientDS.Active then
    ClientDS.EmptyDataSet;
  //清空数据集
end;

procedure TfFrameBase.OnCreateFrame(const nIni: TIniFile);
begin

end;

procedure TfFrameBase.OnDestroyFrame(const nIni: TIniFile);
begin

end;

//Desc: 读取权限
procedure TfFrameBase.OnLoadPopedom;
begin
  BtnAdd.Enabled      := HasPopedom2(sPopedom_Add, FPopedom);
  BtnEdit.Enabled     := HasPopedom2(sPopedom_Edit, FPopedom);
  BtnDel.Enabled      := HasPopedom2(sPopedom_Delete, FPopedom);
  BtnPrint.Enabled    := HasPopedom2(sPopedom_Print, FPopedom);
  BtnPreview.Enabled  := HasPopedom2(sPopedom_Preview, FPopedom);
  BtnExport.Enabled   := HasPopedom2(sPopedom_Export, FPopedom);
end;

//Desc: 过滤不显示
function TfFrameBase.FilterColumnField: string;
begin
  Result := '';
end;

procedure TfFrameBase.OnLoadGridConfig(const nIni: TIniFile);
begin
  BuildDBGridColumn(FEntity, DBGridMain, FilterColumnField());
  //构建表头

  UserDefineGrid(ClassName, DBGridMain, True, nIni);
  //自定义表头配置
end;

procedure TfFrameBase.OnSaveGridConfig(const nIni: TIniFile);
begin
  UserDefineGrid(ClassName, DBGridMain, False, nIni);
end;

//Desc: 执行数据查询
procedure TfFrameBase.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
begin

end;

//Desc: 构建数据载入SQL语句
function TfFrameBase.InitFormDataSQL(const nWhere: string): string;
begin
  Result := '';
end;

//Desc: 载入界面数据
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
    //列格式化
  finally
    if not Assigned(nQuery) then
      ReleaseDBQuery(nC);
    AfterInitFormData;
  end
end;

//Desc: 数据载入后
procedure TfFrameBase.AfterInitFormData;
begin

end;

//------------------------------------------------------------------------------
//Desc: 关闭
procedure TfFrameBase.BtnExitClick(Sender: TObject);
var nSheet: TUniTabSheet;
begin
  nSheet := Parent as TUniTabSheet;
  nSheet.Close;
end;

//Desc: 刷新
procedure TfFrameBase.BtnRefreshClick(Sender: TObject);
begin
  FWhere := '';
  InitFormData(FWhere);
end;

//Desc: 导出
procedure TfFrameBase.BtnExportClick(Sender: TObject);
var nStr,nFile: string;
begin
  if (not ClientDS.Active) or (ClientDS.RecordCount < 1) then
  begin
    ShowMessage('没有需要导出的数据');
    Exit;
  end;

  nStr := '是否要导出当前表格内的数据?';
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

function TfFrameBase.GenReportPDF(const RepName: string): string;
begin
  try
    frxRprt1.PrintOptions.ShowDialog := False;
    frxRprt1.ShowProgress := false;

    frxRprt1.EngineOptions.SilentMode := True;
    frxRprt1.EngineOptions.EnableThreadSafe := True;
    frxRprt1.EngineOptions.DestroyForms := False;
    frxRprt1.EngineOptions.UseGlobalDataSetList := False;

    frxRprt1.LoadFromFile(gPath + 'Report\' + RepName + '.fr3');

    frxPDFxprt1.Background := True;
    frxPDFxprt1.ShowProgress := False;
    frxPDFxprt1.ShowDialog := False;
    frxPDFxprt1.FileName := UniServerModule.NewCacheFileUrl(False, 'pdf', '', '', Result, True);
    frxPDFxprt1.DefaultPath := '';

    frxRprt1.PreviewOptions.AllowEdit := False;
    frxRprt1.PrepareReport;
    frxRprt1.Export(frxPDFxprt1);

    Result:= '';
  finally
  end;
end;

procedure TfFrameBase.BtnPrintClick(Sender: TObject);
var nStr : string;
begin
  if (not ClientDS.Active) or (ClientDS.RecordCount < 1) then
  begin
    ShowMessage('没有可以打印的数据');
    Exit;
  end;

  try
    nStr := GenReportPDF('HuaYan_DAOLU');
    if nStr <> '' then
      ShowMessage(nStr);

  finally
  end;
end;

end.
