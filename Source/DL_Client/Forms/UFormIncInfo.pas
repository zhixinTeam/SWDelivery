{*******************************************************************************
  作者: dmzn 2008-9-20
  描述: 公司信息
*******************************************************************************}
unit UFormIncInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, ExtCtrls, dxLayoutControl, cxContainer, cxEdit,
  cxTextEdit, cxControls, cxMemo, UFormBase, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinsdxLCPainter;

type
  TfFormIncInfo = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    EditName: TcxTextEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditPhone: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    EditWeb: TcxTextEdit;
    dxLayoutControl1Item3: TdxLayoutItem;
    EditMail: TcxTextEdit;
    dxLayoutControl1Item4: TdxLayoutItem;
    EditAddr: TcxTextEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayoutControl1Item6: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item7: TdxLayoutItem;
    BtnOK: TButton;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    chk1: TCheckBox;
    dxlytmLayoutControl1Item9: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure chk1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure InitFormData;
    {*初始化界面*}
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysConst, USysDB, USysPopedom;

ResourceString
  sCompany = 'Company';

//------------------------------------------------------------------------------
class function TfFormIncInfo.CreateForm;
begin
  Result := nil;

  with TfFormIncInfo.Create(Application) do
  begin
    //Caption := '信息设置';
    InitFormData;
    BtnOK.Enabled := gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);

    if (not gSysParam.FIsAdmin) then
    begin
      BtnOK.Visible:= False;
      BtnExit.Visible:= False;
    end;

    ShowModal;
    Free;
  end;
end;

class function TfFormIncInfo.FormID: integer;
begin
  Result := cFI_FormIncInfo;
end;

//------------------------------------------------------------------------------
//Date: 2009-5-31
//Parm: 字符串;处理或者逆向处理
//Desc: 处理nStr中的回车换行符
function RegularStr(const nStr: string; const nGo: Boolean): string;
begin
  if nGo then
       Result := StringReplace(nStr, #13#10, '*|*', [rfReplaceAll])
  else Result := StringReplace(nStr, '*|*', #13#10, [rfReplaceAll]);
end;

//Desc: 初始化界面数据
procedure TfFormIncInfo.InitFormData;
var nIni: TIniFile;
    nX  : string;
begin
  nIni := TIniFile.Create(gPath + sConfigFile);
  try
    EditName.Text := nIni.ReadString(sCompany, 'Name', '');
    EditPhone.Text := nIni.ReadString(sCompany, 'Phone', '');
    EditWeb.Text := nIni.ReadString(sCompany, 'Web', '');
    EditMail.Text := nIni.ReadString(sCompany, 'Mail', '');
    EditAddr.Text := nIni.ReadString(sCompany, 'Address', '');
    EditMemo.Text := RegularStr(nIni.ReadString(sCompany, 'Memo', ''), False);
    nX := (nIni.ReadString('OtherExtParam', 'IsPound', 'N'));

    chk1.Checked:= nX='Y';
  finally
    nIni.Free;
  end;
end;

//Desc: 保存
procedure TfFormIncInfo.BtnOKClick(Sender: TObject);
var nIni: TIniFile;
    nX  : string;
begin
  EditName.Text := Trim(EditName.Text);
  if EditName.Text = '' then
  begin
    EditName.SetFocus;
    ShowMsg('请输入公司名称', sHint); Exit;
  end;
  if chk1.Checked then nX:= 'Y' else nX:= 'N';

  nIni := TIniFile.Create(gPath + sConfigFile);
  try
    gSysParam.FHintText := EditName.Text;
    nIni.WriteString(gSysParam.FProgID, 'HintText', EditName.Text);

    nIni.WriteString(sCompany, 'Name', EditName.Text);
    nIni.WriteString(sCompany, 'Phone', EditPhone.Text);
    nIni.WriteString(sCompany, 'Web', EditWeb.Text);
    nIni.WriteString(sCompany, 'Mail', EditMail.Text);
    nIni.WriteString(sCompany, 'Address', EditAddr.Text);
    nIni.WriteString(sCompany, 'Memo', RegularStr(EditMemo.Text, True));

    nIni.WriteString('OtherExtParam', 'IsPound', nX);
  finally
    nIni.Free;
  end;

  ModalResult := mrOK;
  AddVerifyData(gPath + sConfigFile, gSysParam.FProgID);
  ShowMsg('信息已保存', sHint);
end;

procedure TfFormIncInfo.chk1Click(Sender: TObject);
begin
  inherited;
  gSysParam.FPound:= True;
end;

procedure TfFormIncInfo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  gSysParam.FPound:= chk1.Checked;
end;

initialization
  gControlManager.RegCtrl(TfFormIncInfo, TfFormIncInfo.FormID);
end.
