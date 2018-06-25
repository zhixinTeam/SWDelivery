{*******************************************************************************
  作者: dmzn@163.com 2018-03-15
  描述: 主窗口,调度其它模块
*******************************************************************************}
unit UFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Forms, Dialogs,
  uniGUITypes, uniGUIAbstractClasses, uniGUIRegClasses, uniGUIForm, uniGUIFrame,
  Vcl.Menus, uniMainMenu, uniSplitter, uniTreeView, uniMultiItem, uniComboBox,
  uniCheckBox, uniButton, uniGUIClasses, uniMemo, uniPanel, uniPageControl,
  uniLabel, uniImage, Vcl.Controls, uniGUIBaseClasses, uniStatusBar;

type
  TfFormMain = class(TUniForm)
    StatusBar1: TUniStatusBar;
    PanelTop: TUniSimplePanel;
    ImageRight: TUniImage;
    ImageLeft: TUniImage;
    PageWork: TUniPageControl;
    SheetWelcome: TUniTabSheet;
    PanelLeft: TUniPanel;
    UniSimplePanel3: TUniSimplePanel;
    ComboFactory: TUniComboBox;
    LabelFactory: TUniLabel;
    TreeMenu: TUniTreeView;
    UniSplitter1: TUniSplitter;
    UniPanel1: TUniPanel;
    LabelHint: TUniLabel;
    SheetMemory: TUniTabSheet;
    MemoMemory: TUniMemo;
    UniSimplePanel1: TUniSimplePanel;
    BtnFresh: TUniButton;
    CheckFriendly: TUniCheckBox;
    PMenu1: TUniPopupMenu;
    N1: TUniMenuItem;
    N2: TUniMenuItem;
    N3: TUniMenuItem;
    BtnUpdateMemory: TUniButton;
    procedure UniFormCreate(Sender: TObject);
    procedure BtnFreshClick(Sender: TObject);
    procedure TreeMenuMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure BtnUpdateMemoryClick(Sender: TObject);
    procedure TreeMenuClick(Sender: TObject);
    procedure UniFormDestroy(Sender: TObject);
    procedure PageWorkChange(Sender: TObject);
    procedure ComboFactoryChange(Sender: TObject);
  private
    { Private declarations }
    procedure LoadFormConfig;
    procedure SaveFormConfig;
    //窗体配置
    procedure TabSheetClose(Sender: TObject; var AllowClose: Boolean);
    //分页关闭
  public
    { Public declarations }
  end;

function fFormMain: TfFormMain;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, UManagerGroup, System.IniFiles, USysDB,
  USysBusiness, USysConst;

function fFormMain: TfFormMain;
begin
  Result := TfFormMain(UniMainModule.GetFormInstance(TfFormMain));
end;

//Date: 2018-04-19
//Desc: 初始化窗体配置
procedure TfFormMain.LoadFormConfig;
var nStr: string;
    nInt: Integer;
    nIni: TIniFile;
begin
  ImageLeft.Url := sImageDir + 'top_left.bmp';
  ImageRight.Url := sImageDir + 'top_right.bmp';

  with UniMainModule.FUserConfig do
  begin
    Caption := FMainTitle;
    LabelHint.Caption := FHintText;

    nStr := '用户:【%s】 来自:【%s】 系统:【%s】 浏览器:【%s】';
    nStr := Format(nStr, [FUserID, FLocalIP, FOSUser, FUserAgent]);
    StatusBar1.SimpleText := nStr;
  end;

  PageWork.ActivePage := SheetWelcome;
  SheetMemory.Visible := UniMainModule.FUserConfig.FIsAdmin;
  UniMainModule.FMainForm := Self;

  GetFactoryList(ComboFactory.Items);
  if ComboFactory.Items.Count > 0 then
    ComboFactory.ItemIndex := 0;
  //default factory

  nIni := nil;
  try
    nIni := UserConfigFile;
    //config object

    nInt := nIni.ReadInteger(ClassName, 'PanelLeft', 200);
    if nInt < 100 then nInt := 100;
    PanelLeft.Width := nInt;

    nInt := nIni.ReadInteger(ClassName, 'FactoryLast', 0);
    if (ComboFactory.ItemIndex >= 0) and (nInt >= 0) then
      ComboFactory.ItemIndex := nInt;
    UniMainModule.FUserConfig.FFactory := ComboFactory.ItemIndex;
  finally
    nIni.Free;
  end;
end;

//Date: 2018-04-27
//Desc: 保存配置
procedure TfFormMain.SaveFormConfig;
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := UserConfigFile;
    nIni.WriteInteger(ClassName, 'PanelLeft', PanelLeft.Width);
    nIni.WriteInteger(ClassName, 'FactoryLast', ComboFactory.ItemIndex);
  finally
    nIni.Free;
  end;
end;

procedure TfFormMain.UniFormCreate(Sender: TObject);
begin
  LoadFormConfig;
  BuidMenuTree(TreeMenu);
end;

procedure TfFormMain.UniFormDestroy(Sender: TObject);
begin
  SaveFormConfig;
end;

//------------------------------------------------------------------------------
//Desc: 刷新内存
procedure TfFormMain.BtnFreshClick(Sender: TObject);
begin
  LoadSystemMemoryStatus(MemoMemory.Lines, CheckFriendly.Checked);
end;

//Desc: 更新内存
procedure TfFormMain.BtnUpdateMemoryClick(Sender: TObject);
var nStr: string;
begin
  nStr := '服务器将重新加载配置数据,并断开所有连接.' + #13#10 +
          '继续操作请点"是"按钮.';
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    begin
      if Res = mrYes then ReloadSystemMemory(True);
    end);
  //xxxxx
end;

procedure TfFormMain.TreeMenuMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, TreeMenu);
end;

procedure TfFormMain.N1Click(Sender: TObject);
begin
  TreeMenu.FullExpand;
end;

procedure TfFormMain.N3Click(Sender: TObject);
begin
  TreeMenu.FullCollapse;
end;

//Desc: 切换工厂
procedure TfFormMain.ComboFactoryChange(Sender: TObject);
var nStr: string;
    nFactory: TFactoryItem;
begin
  if GetFactory(ComboFactory.ItemIndex, nFactory) then
  begin
    GlobalSyncLock;
    try
      UniMainModule.FUserConfig.FFactory := ComboFactory.ItemIndex;
      //factory index
    finally
      GlobalSyncRelease;
    end;

    with nFactory do
    begin
      nStr := '当前所有业务只针对如下工厂:' + #13#10#13#10 +
              '工厂编号: %s' + #13#10 +
              '工厂名称: %s';
      nStr := Format(nStr, [FFactoryID, FFactoryName]);
      ShowMessage(nStr);
    end;
  end;
end;

procedure TfFormMain.TreeMenuClick(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nForm: TUniForm;
    nFrame: TUniFrame;
    nFrameClass: TUniFrameClass;
begin
  if (not Assigned(TreeMenu.Selected)) or
     (TreeMenu.Selected.HasChildren) then Exit;
  nIdx := NativeInt(TreeMenu.Selected.Data);

  nStr := GetMenuItemID(nIdx);
  if nStr = '' then Exit;
  //invalid menu

  for nIdx := Low(UniMainModule.FMenuModule) to High(UniMainModule.FMenuModule) do
  with UniMainModule.FMenuModule[nIdx] do
  begin
    if CompareText(FMenuID, nStr) <> 0 then Continue;
    //not match

    if FItemType = mtForm then
    begin
      nForm := SystemGetForm(FModule);
      if not Assigned(nForm) then
      begin
        nStr := '窗体类[ %s ]无效.';
        ShowMessage(Format(nStr, [FModule]));
        Exit;
      end;

      nForm.ShowModalN;
      //show form
    end else

    if FItemType = mtFrame then
    begin
      if not Assigned(FTabSheet) then
      begin
        nFrameClass := TUniFrameClass(GetClass(FModule));
        if not Assigned(nFrameClass) then
        begin
          nStr := 'Frame类[ %s ]无效.';
          ShowMessage(Format(nStr, [FModule]));
          Exit;
        end;

        FTabSheet := TUniTabSheet.Create(Self);
        with FTabSheet do
        begin
          Pagecontrol := PageWork;
          Caption := TreeMenu.Selected.Text;

          Closable := True;
          OnClose := TabSheetClose;
          Tag := NativeInt(TreeMenu.Selected);
        end;

        nFrame := nFrameClass.Create(Self);
        nFrame.Parent := FTabSheet;
        nFrame.Align := alClient;
      end;

      PageWork.ActivePage := FTabSheet;
      //active
    end;

    Break;
  end;
end;

//Desc: 页面关闭
procedure TfFormMain.TabSheetClose(Sender: TObject; var AllowClose: Boolean);
var nStr: string;
    nIdx: Integer;
    nNode: TUniTreeNode;
begin
  nNode := Pointer((Sender as TUniTabSheet).Tag);
  if not Assigned(nNode) then Exit;

  if TreeMenu.Selected = nNode then
    TreeMenu.Selected := nil;
  //xxxxx

  nIdx := NativeInt(nNode.Data);
  nStr := GetMenuItemID(nIdx);

  for nIdx := Low(UniMainModule.FMenuModule) to High(UniMainModule.FMenuModule) do
  with UniMainModule.FMenuModule[nIdx] do
  begin
    if CompareText(FMenuID, nStr) <> 0 then Continue;
    //not match

    FTabSheet := nil;
  end;

  if (PageWork.PageCount <= 3) and (not UniMainModule.FUserConfig.FIsAdmin) then
    PageWork.ActivePage := SheetWelcome;
  //xxxxx
end;

//Desc: 页面切换
procedure TfFormMain.PageWorkChange(Sender: TObject);
var nNode: TUniTreeNode;
begin
  if Assigned(PageWork.ActivePage) then
  begin
    nNode := Pointer(PageWork.ActivePage.Tag);
    if Assigned(nNode) then
      TreeMenu.Selected := nNode;
    //xxxxx
  end;
end;

initialization
  RegisterAppFormClass(TfFormMain);
end.
