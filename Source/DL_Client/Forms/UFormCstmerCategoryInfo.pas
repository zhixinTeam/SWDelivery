unit UFormCstmerCategoryInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsCore, dxSkinsDefaultPainters, dxSkinsdxLCPainter, ComCtrls,
  cxContainer, cxEdit, StdCtrls, dxLayoutControl, cxMemo, cxTextEdit,
  cxTreeView, USysDataFun, UFormBase;

type
  TTfFormCstmerCategoryInfo = class(TBaseForm)
    dxLayout1: TdxLayoutControl;
    InfoTv1: TcxTreeView;
    EditText: TcxTextEdit;
    EditMemo: TcxMemo;
    BtnAdd: TButton;
    BtnDel: TButton;
    BtnSave: TButton;
    dxLayoutGroup1: TdxLayoutGroup;
    dxLayoutGroup2: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Item6: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Item7: TdxLayoutItem;
    dxLayout1Item8: TdxLayoutItem;
    dxLayout1Item9: TdxLayoutItem;
    dxLayout1Item2: TdxLayoutItem;
    Edt_Mark: TcxTextEdit;
    dxlytmLayout1Item1: TdxLayoutItem;
    lbl1: TLabel;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InfoTv1Click(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure InfoTv1Change(Sender: TObject; Node: TTreeNode);
    procedure InfoTv1DblClick(Sender: TObject);
  private
    { Private declarations }
    FGroup, FMark : string;
  private
    procedure LoadInfoData(const nGroup: string);
    //读取数据
    procedure GetSelectedData(var nInfo: TBaseInfoData);
    //获取数据
  public
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  UDataModule, UMgrControl, ULibFun, USysGrid, USysDB, USysConst;


class function TTfFormCstmerCategoryInfo.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;

  with TTfFormCstmerCategoryInfo.Create(Application) do
  begin
    try
        FGroup:= 'KHCategoryItem';
        LoadInfoData(FGroup);

        if Assigned(nParam) then nP := nParam;

        if nPopedom='ChoseItem' then
        begin
          BtnAdd.Visible:= False;
          BtnDel.Visible:= False;
          BtnSave.Visible:= False;

          Caption:= '选择客户类别';

          nP.FCommand := cCmd_ModalResult;
          nP.FParamA := ShowModal;
          nP.FParamB := FMark;
        end
        else ShowModal;
    finally
      Free;
    end;
  end;
end;

class function TTfFormCstmerCategoryInfo.FormID: integer;
begin
  Result := cFI_FormCstmerCategoryInfo;
end;

procedure TTfFormCstmerCategoryInfo.LoadInfoData(const nGroup: string);
var nStr: string;
    i,nCount: integer;
    nData: PBaseInfoData;
begin
  BuildBaseInfoTree(InfoTv1.InnerTreeView, nGroup);
end;

//Desc: 获取选中节点的内容
procedure TTfFormCstmerCategoryInfo.GetSelectedData(var nInfo: TBaseInfoData);
var nData: PBaseInfoData;
begin
  if Assigned(InfoTv1.Selected) and Assigned(InfoTv1.Selected.Data) then
  begin
    nData := InfoTv1.Selected.Data;

    nInfo.FSub := nil;
    nInfo.FID := nData.FID;
    nInfo.FPID := nData.FPID;
    nInfo.FIndex := nData.FIndex;

    nInfo.FText := nData.FText;
    nInfo.FPY := nData.FPY;
    nInfo.FMemo := nData.FMemo;
    nInfo.FPText := nData.FPText;
    nInfo.FGroup := nData.FGroup;
  end;
end;

procedure TTfFormCstmerCategoryInfo.BtnAddClick(Sender: TObject);
begin
  BtnSave.Enabled := True;
  BtnAdd.Enabled := False;

  BtnDel.Caption := '取消';
  BtnDel.Tag := 7;

  EditText.Clear;
  EditText.SetFocus;
  Edt_Mark.Clear;
  EditMemo.Clear;
end;

procedure TTfFormCstmerCategoryInfo.BtnSaveClick(Sender: TObject);
var nStr,nPID: string;
begin
  EditText.Text := Trim(EditText.Text);
  Edt_Mark.Text := Trim(Edt_Mark.Text);
  if (EditText.Text = '')or(Edt_Mark.Text='') then
  begin
    EditText.SetFocus;
    ShowMsg('请填写名称和标识', sHint); Exit;
  end;

  if Assigned(InfoTv1.Selected) then
       nPID := IntToStr(PBaseInfoData(InfoTv1.Selected.Data).FID)
  else nPID := '0';

  nStr := 'Select * From %s Where B_Group=''%s'' And B_Text=''%s'' And B_Py=''%s'' ';
  nStr := Format(nStr, [sTable_BaseInfo, FGroup, EditText.Text, Trim(Edt_Mark.Text)]);

  with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      ShowMsg('已存在相同客户或标识、请修改 !', sHint);
      Exit;
    end;

  nStr := 'Insert Into %s(B_Group,B_Text,B_Py,B_Memo,B_PID) Values(' +
          '''%s'', ''%s'', ''%s'', ''%s'', %s)';
  nStr := Format(nStr, [sTable_BaseInfo, FGroup, EditText.Text,
                        Trim(Edt_Mark.Text), Trim(EditMemo.Text), nPID]);

  try
    FDM.ExecuteSQL(nStr);
    LoadInfoData(FGroup);
    ShowMsg('已成功保存', sHint);
  except
    ShowMsg('数据保存失败', '未知错误');
  end;
end;

procedure TTfFormCstmerCategoryInfo.FormShow(Sender: TObject);
begin
  LoadInfoData('KHCategoryItem');

  BtnSave.Enabled := False;
end;

procedure TTfFormCstmerCategoryInfo.InfoTv1Click(Sender: TObject);
var nP: TPoint;
begin
  GetCursorPos(nP);
  nP := InfoTv1.ScreenToClient(nP);
  if InfoTv1.GetNodeAt(nP.X, nP.Y) = nil then InfoTv1.Selected := nil;
end;

procedure TTfFormCstmerCategoryInfo.BtnDelClick(Sender: TObject);
var nStr: string;
    nNode: TTreeNode;
    nData: PBaseInfoData;
begin
  if BtnDel.Tag > 0 then
  begin
    BtnSave.Enabled := False;
    BtnAdd.Enabled := True;

    BtnDel.Caption := '删除';
    BtnDel.Tag := 0; Exit;
  end;

  if not Assigned(InfoTv1.Selected) then
  begin
    ShowMsg('请选择要删除的节点', sHint); Exit;
  end;

  nData := InfoTv1.Selected.Data;
  nStr := '确定要删除内容为[ %s ]的节点吗?其子节点也会被一起删除.';
  
  nStr := Format(nStr, [nData.FText]);
  if not QueryDlg(nStr, sAsk, Handle) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nNode := InfoTv1.Selected;
    while Assigned(nNode) do
    begin
      nData := nNode.Data;
      nStr := 'Delete From %s Where B_ID=%s';
      nStr := Format(nStr, [sTable_BaseInfo, IntToStr(nData.FID)]);
      FDM.ExecuteSQL(nStr);

      nNode := nNode.GetNext;
      if Assigned(nNode) and (nNode.Level = InfoTv1.Selected.Level) then Break;
    end;

    FDM.ADOConn.CommitTrans;
    LoadInfoData(FGroup);
    ShowMsg('已成功删除', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('删除数据失败', '未知错误');
  end;

end;

procedure TTfFormCstmerCategoryInfo.InfoTv1Change(Sender: TObject;
  Node: TTreeNode);
var nData: PBaseInfoData;
begin
  if Assigned(Node) then
  begin
    nData := Node.Data;
    EditText.Text := nData.FText;
    Edt_Mark.Text := nData.FPY;      FMark:= nData.FPY;
    EditMemo.Text := nData.FMemo;
  end else
  begin
    EditText.Clear;
    Edt_Mark.Clear;
    EditMemo.Clear;
  end;
end;

procedure TTfFormCstmerCategoryInfo.InfoTv1DblClick(Sender: TObject);
var nNode: PBaseInfoData;
begin
  if Assigned(InfoTv1.Selected) then
  begin
    nNode := InfoTv1.Selected.Data;
    
    if not Assigned(nNode.FSub) then
      ModalResult := mrOK
      
    else ShowMsg('请选择具体类别', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TTfFormCstmerCategoryInfo, TTfFormCstmerCategoryInfo.FormID);
end.
