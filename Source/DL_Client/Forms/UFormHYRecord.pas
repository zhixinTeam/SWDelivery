{*******************************************************************************
  作者: dmzn@163.com 2009-07-20
  描述: 检验录入
*******************************************************************************}
unit UFormHYRecord;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, cxGraphics, StdCtrls, cxMaskEdit, cxDropDownEdit,
  cxMCListBox, cxMemo, dxLayoutControl, cxContainer, cxEdit, cxTextEdit,
  cxControls, cxButtonEdit, cxCalendar, ExtCtrls, cxPC, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinsdxLCPainter;

type
  TfFormHYRecord = class(TForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group5: TdxLayoutGroup;
    EditID: TcxButtonEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayoutControl1Item12: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    wPanel: TPanel;
    dxLayoutControl1Item4: TdxLayoutItem;
    Label17: TLabel;
    Label18: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Bevel2: TBevel;
    cxTextEdit29: TcxTextEdit;
    cxTextEdit30: TcxTextEdit;
    cxTextEdit31: TcxTextEdit;
    cxTextEdit32: TcxTextEdit;
    cxTextEdit33: TcxTextEdit;
    cxTextEdit34: TcxTextEdit;
    cxTextEdit35: TcxTextEdit;
    cxTextEdit36: TcxTextEdit;
    cxTextEdit37: TcxTextEdit;
    cxTextEdit38: TcxTextEdit;
    cxTextEdit39: TcxTextEdit;
    cxTextEdit40: TcxTextEdit;
    cxTextEdit41: TcxTextEdit;
    cxTextEdit42: TcxTextEdit;
    cxTextEdit43: TcxTextEdit;
    cxTextEdit47: TcxTextEdit;
    cxTextEdit48: TcxTextEdit;
    cxTextEdit49: TcxTextEdit;
    EditDate: TcxDateEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    EditMan: TcxTextEdit;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Group3: TdxLayoutGroup;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label34: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    cxTextEdit17: TcxTextEdit;
    cxTextEdit18: TcxTextEdit;
    cxTextEdit19: TcxTextEdit;
    cxTextEdit20: TcxTextEdit;
    cxTextEdit21: TcxTextEdit;
    cxTextEdit22: TcxTextEdit;
    cxTextEdit23: TcxTextEdit;
    cxTextEdit24: TcxTextEdit;
    cxTextEdit25: TcxTextEdit;
    cxTextEdit26: TcxTextEdit;
    cxTextEdit27: TcxTextEdit;
    cxTextEdit28: TcxTextEdit;
    cxTextEdit45: TcxTextEdit;
    cxTextEdit52: TcxTextEdit;
    cxTextEdit53: TcxTextEdit;
    cxTextEdit54: TcxTextEdit;
    Label41: TLabel;
    cxTextEdit55: TcxTextEdit;
    Label42: TLabel;
    cxTextEdit56: TcxTextEdit;
    Label43: TLabel;
    cxTextEdit57: TcxTextEdit;
    Label44: TLabel;
    cxTextEdit58: TcxTextEdit;
    Edt1: TcxTextEdit;
    lbl1: TLabel;
    Edt2: TcxTextEdit;
    lbl2: TLabel;
    Edt3: TcxTextEdit;
    lbl3: TLabel;
    Edt4: TcxTextEdit;
    lbl4: TLabel;
    lbl5: TLabel;
    Edt5: TcxTextEdit;
    lbl9: TLabel;
    Edt9: TcxTextEdit;
    Edt10: TcxTextEdit;
    Edt11: TcxTextEdit;
    lbl17: TLabel;
    Edt19: TcxTextEdit;
    Edt20: TcxTextEdit;
    Edt21: TcxTextEdit;
    Edt22: TcxTextEdit;
    Edt23: TcxTextEdit;
    Edt24: TcxTextEdit;
    lbl18: TLabel;
    Edt25: TcxTextEdit;
    Edt26: TcxTextEdit;
    lbl19: TLabel;
    Edt27: TcxTextEdit;
    Edt28: TcxTextEdit;
    lbl20: TLabel;
    Edt29: TcxTextEdit;
    Edt30: TcxTextEdit;
    lbl6: TLabel;
    Edt6: TcxTextEdit;
    lbl7: TLabel;
    Edt7: TcxTextEdit;
    Edt32: TcxTextEdit;
    lbl22: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditStockPropertiesEditValueChanged(Sender: TObject);
    procedure cxTextEdit17KeyPress(Sender: TObject; var Key: Char);
    procedure cxTextEdit17Exit(Sender: TObject);
    procedure cxTextEdit26Exit(Sender: TObject);
    procedure cxTextEdit23Exit(Sender: TObject);
    procedure cxTextEdit24Exit(Sender: TObject);
    procedure cxTextEdit18Exit(Sender: TObject);
    procedure cxTextEdit28Exit(Sender: TObject);
    procedure cxTextEdit27Exit(Sender: TObject);
  private
    { Private declarations }
    FRecordID: string;
    //合同编号
    FPrefixID: string;
    //前缀编号
    FIDLength: integer;
    //前缀长度
    procedure InitFormData(const nID: string);
    //载入数据
    procedure LoadZMJParam;
    procedure SaveZMJParam;
    procedure GetData(Sender: TObject; var nData: string);
    function SetData(Sender: TObject; const nData: string): Boolean;
    //数据处理
  public
    { Public declarations }
  end;

function ShowStockRecordAddForm: Boolean;
function ShowStockRecordEditForm(const nID: string): Boolean;
procedure ShowStockRecordViewForm(const nID: string);
procedure CloseStockRecordForm;
//入口函数

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, USysDB, USysConst, UDataReport;

var
  gForm: TfFormHYRecord = nil;
  //全局使用

//------------------------------------------------------------------------------
//Desc: 添加
function ShowStockRecordAddForm: Boolean;
begin
  with TfFormHYRecord.Create(Application) do
  begin
    FRecordID := '';
    Caption := '检验记录 - 添加';

    InitFormData('');
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Desc: 修改
function ShowStockRecordEditForm(const nID: string): Boolean;
begin
  with TfFormHYRecord.Create(Application) do
  begin
    FRecordID := nID;
    Caption := '检验记录 - 修改';

    InitFormData(nID);
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Desc: 查看
procedure ShowStockRecordViewForm(const nID: string);
begin
  if not Assigned(gForm) then
  begin
    gForm := TfFormHYRecord.Create(Application);
    gForm.Caption := '检验记录 - 查看';
    gForm.FormStyle := fsStayOnTop;
    gForm.BtnOK.Visible := False;
  end;

  with gForm  do
  begin
    FRecordID := nID;
    InitFormData(nID);
    if not Showing then Show;
  end;
end;

procedure CloseStockRecordForm;
begin
  FreeAndNil(gForm);
end;

//------------------------------------------------------------------------------
procedure TfFormHYRecord.LoadZMJParam;
var nStr: string;
begin
  nStr := 'Select D_Value, D_Memo From %s Where D_Name=''HYZMJParam''';
  nStr := Format(nStr, [sTable_SysDict]);

  with FDM.QueryTemp(nStr) do
  begin
    edt6.text:= Fields[0].AsString;
    edt7.text:= Fields[1].AsString;
  end;
end;

procedure TfFormHYRecord.SaveZMJParam;
var nStr: string;
begin
  nStr := 'UPDate %s Set D_Value=''%s'', D_Memo=''%s''  Where D_Name=''HYZMJParam''';
  nStr := Format(nStr, [sTable_SysDict, Trim(edt6.text), Trim(edt7.text)]);

  FDM.ExecuteSQL(nStr);
end;

procedure TfFormHYRecord.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  ResetHintAllForm(Self, 'E', sTable_StockRecord);
  //重置表名称
  
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    FPrefixID := nIni.ReadString(Name, 'IDPrefix', 'SN');
    FIDLength := nIni.ReadInteger(Name, 'IDLength', 8);
    LoadZMJParam;
  finally
    nIni.Free;
  end;
end;

procedure TfFormHYRecord.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  gForm := nil;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

procedure TfFormHYRecord.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormHYRecord.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end else

  if Key = VK_DOWN then
  begin
    Key := 0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end else

  if Key = VK_UP then
  begin
    Key := 0;
    Perform(WM_NEXTDLGCTL, 1, 0);
  end;
end;

procedure TfFormHYRecord.cxTextEdit17KeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormHYRecord.GetData(Sender: TObject; var nData: string);
begin
  if Sender = EditDate then nData := DateTime2Str(EditDate.Date);
end;

function TfFormHYRecord.SetData(Sender: TObject; const nData: string): Boolean;
begin
  if Sender = EditDate then
  begin
    EditDate.Date := Str2DateTime(nData);
    Result := True;
  end else Result := False;
end;

//Date: 2009-6-2
//Parm: 记录编号
//Desc: 载入nID供应商的信息到界面
procedure TfFormHYRecord.InitFormData(const nID: string);
var nStr: string;
begin
  EditDate.Date := Now;
  EditMan.Text := gSysParam.FUserID;
  
  if EditStock.Properties.Items.Count < 1 then
  begin
    nStr := 'P_ID=Select P_ID,P_Name From %s';
    nStr := Format(nStr, [sTable_StockParam]);

    FDM.FillStringsData(EditStock.Properties.Items, nStr, -1, '、');
    AdjustStringsItem(EditStock.Properties.Items, False);
  end;

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_StockRecord, nID]);
    LoadDataToForm(FDM.QuerySQL(nStr), Self, '', SetData);
  end;
end;

//Desc: 设置类型
procedure TfFormHYRecord.EditStockPropertiesEditValueChanged(Sender: TObject);
var nStr: string;
begin
  if FRecordID = '' then
  begin
    nStr := 'Select * From %s Where R_PID=''%s''';
    nStr := Format(nStr, [sTable_StockParamExt, GetCtrlData(EditStock)]);
    LoadDataToCtrl(FDM.QueryTemp(nStr), wPanel);
  end;

  nStr := 'Select P_Stock From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_StockParam, GetCtrlData(EditStock)]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       nStr := GetPinYinOfStr(Fields[0].AsString)
  else nStr := '';                                    

  if Pos('kzf', nStr) > 0 then //矿渣粉
  begin
    Label24.Caption := '密度g/cm:';
    Label19.Caption := '流动度比:';
    Label22.Caption := '含 水 量:';
    Label21.Caption := '石膏掺量:';
    Label34.Caption := '助 磨 剂:';
    Label18.Caption := '7天活性指数:';
    Label26.Caption := '28天活性指数:';
  end else
  begin
    Label24.Caption := '氧 化 镁:';
    Label19.Caption := '碱 含 量:';
    Label22.Caption := '细    度:';
    Label21.Caption := '稠    度:';
    Label34.Caption := '游 离 钙:';
    Label18.Caption := '3天抗折强度:';
    Label26.Caption := '28天抗折强度:';
  end;
end;

//Desc: 生成随机编号
procedure TfFormHYRecord.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := FDM.GetSerialID(FPrefixID, sTable_StockRecord, 'R_SerialNo');
end;

//Desc: 保存数据
procedure TfFormHYRecord.BtnOKClick(Sender: TObject);
var nStr, nSQL, nHValue: string;
function GetHHValue(nHHStr:string):string;
var
  I: Integer;
  nValue : Double;
  nStrs : TStrings;
begin
  Result:= '';
  nStrs:= TStringList.Create;
  try
    nStrs.Delimiter := ',';
    nStrs.DelimitedText := nHHStr;
    try
      for I := 0 to nStrs.Count-1 do
        nValue:= nValue + StrToFloatDef(nStrs[I], 0);

      Result:= FloatToStr(nValue);
    except
      ShowMsg('请填写数字或英文逗号  ,  ', sHint);
    end;
  finally
    nStrs.Free;
  end;
end;

begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    EditID.SetFocus;
    ShowMsg('请填写有效的水泥编号', sHint); Exit;
  end;

  if EditStock.ItemIndex < 0 then
  begin
    EditStock.SetFocus;
    ShowMsg('请填写有效的品种', sHint); Exit;
  end;

  if FRecordID = '' then
  begin
    nStr := 'Select Count(*) From %s Where R_SerialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord, EditID.Text]);
    //查询编号是否存在

    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger > 0 then
    begin
      EditID.SetFocus;
      ShowMsg('该编号的记录已经存在', sHint); Exit;
    end;

    nSQL := MakeSQLByForm(Self, sTable_StockRecord, '', True, GetData);
  end else
  begin
    EditID.Text := FRecordID;
    nStr := 'R_ID=''' + FRecordID + '''';
    nSQL := MakeSQLByForm(Self, sTable_StockRecord, nStr, False, GetData);
  end;

  //{$IFDEF SWAS}
  nSQL:= StringReplace(nSQL, '''''', '''—''', [rfReplaceAll]);
  //{$ENDIF}
  FDM.ExecuteSQL(nSQL);


  nSQL:= 'UPDate S_StockRecord Set R_HHCValueBak=Replace(R_HHCValue,'','',CHAR(10)) Where ';
  if FRecordID = '' then
    nSQL:= nSQL + ' R_SerialNo='''+Trim(EditID.Text)+''''
  else nSQL:= nSQL + ' R_ID='''+FRecordID+'''';

  FDM.ExecuteSQL(nSQL);

  nHValue:= GetHHValue(Trim(cxTextEdit58.Text));
  nSQL:= 'UPDate S_StockRecord Set R_HHCValueHJ='+nHValue+' Where ';
  if FRecordID = '' then
    nSQL:= nSQL + ' R_SerialNo='''+Trim(EditID.Text)+''''
  else nSQL:= nSQL + ' R_ID='''+FRecordID+'''';
  FDM.ExecuteSQL(nSQL);

  SaveZMJParam;

  ModalResult := mrOK;
  ShowMsg('数据已保存', sHint);
end;

procedure TfFormHYRecord.cxTextEdit17Exit(Sender: TObject);
begin
  if StrToFloatDef(Trim(cxTextEdit17.Text), 0)>5 then
    ShowMsg('氧化镁参数输入超标请确认', '提示');
end;

procedure TfFormHYRecord.cxTextEdit26Exit(Sender: TObject);
begin
  if StrToFloatDef(Trim(cxTextEdit26.Text), 0)<300 then
    ShowMsg('表比面积参数输入超标请确认', '提示');
end;

procedure TfFormHYRecord.cxTextEdit23Exit(Sender: TObject);
begin
  if StrToFloatDef(Trim(cxTextEdit23.Text), 0)>3.5 then
    ShowMsg('三氧化硫参数输入超标请确认', '提示');
end;

procedure TfFormHYRecord.cxTextEdit24Exit(Sender: TObject);
begin
  if StrToFloatDef(Trim(cxTextEdit24.Text), 0)>5 then
    ShowMsg('烧失量参数输入超标请确认', '提示');
end;

procedure TfFormHYRecord.cxTextEdit18Exit(Sender: TObject);
begin
  if StrToFloatDef(Trim(cxTextEdit18.Text), 0)>5 then
    ShowMsg('氯离子参数输入超标请确认', '提示');
end;

procedure TfFormHYRecord.cxTextEdit28Exit(Sender: TObject);
begin
  if StrToFloatDef(Trim(cxTextEdit28.Text), 0)<45 then
    ShowMsg('初凝参数输入超标请确认', '提示');
end;

procedure TfFormHYRecord.cxTextEdit27Exit(Sender: TObject);
begin
  if StrToFloatDef(Trim(cxTextEdit27.Text), 0)>600 then
    ShowMsg('终凝参数输入超标请确认', '提示');
end;

end.
