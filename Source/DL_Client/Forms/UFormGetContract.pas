{*******************************************************************************
  ����: dmzn@163.com 2010-3-9
  ����: ѡ���ͬ
*******************************************************************************}
unit UFormGetContract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxLabel,
  cxListView, cxButtonEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  dxLayoutControl, StdCtrls;

type
  TfFormGetContract = class(TfFormNormal)
    EditSMan: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    EditCustom: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditCID: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    ListContract: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListContractKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditSManPropertiesEditValueChanged(Sender: TObject);
    procedure EditCustomPropertiesEditValueChanged(Sender: TObject);
    procedure ListContractDblClick(Sender: TObject);
    procedure EditCustomKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FSelectedID: string;
    //ѡ�б�ʶ
    FLastQuery: Int64;
    //�ϴβ�ѯ
    procedure InitFormData(const nID: string);
    //��ʼ������
    function QueryContract(const nType: Byte): Boolean;
    //��ѯ��ͬ
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UAdjustForm, UFormCtrl, UFormBase, USysGrid,
  USysDB, USysConst, USysBusiness, UDataModule;

class function TfFormGetContract.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetContract.Create(Application) do
  begin
    Caption := 'ѡ���ͬ';
    InitFormData(nP.FParamA);
    nP.FParamA := ShowModal;

    nP.FCommand := cCmd_ModalResult;
    if nP.FParamA = mrOK then
      nP.FParamB := FSelectedID;
    Free;
  end;
end;

class function TfFormGetContract.FormID: integer;
begin
  Result := cFI_FormGetContract;
end;

procedure TfFormGetContract.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  FLastQuery := 0;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListContract, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormGetContract.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListContract, nIni);
  finally
    nIni.Free;
  end;

  ReleaseCtrlData(Self);
end;

//Desc: ��ʼ����������
procedure TfFormGetContract.InitFormData(const nID: string);
var nStr: string;
begin
  if EditSMan.Properties.Items.Count < 1 then
  begin
    nStr := 'S_ID=Select S_ID,S_PY,S_Name From %s ' +
            'Where S_InValid<>''%s'' Order By S_PY';
    nStr := Format(nStr, [sTable_Salesman, sFlag_Yes]);

    FDM.FillStringsData(EditSMan.Properties.Items, nStr, -1,
                        '.', DSA(['S_ID']));
    AdjustStringsItem(EditSMan.Properties.Items, False);
    EditSMan.Properties.Items.Insert(0, '');
  end;

  if nID <> '' then
  begin
    EditCID.Text := nID;
    if QueryContract(10) then ActiveControl := ListContract;
  end else ActiveControl := EditCustom;
end;

//Date: 2010-3-9
//Parm: ��ѯ����(10: �����;20: ����Ա)
//Desc: ��ָ�����Ͳ�ѯ��ͬ
function TfFormGetContract.QueryContract(const nType: Byte): Boolean;
var nStr,nWhere: string;
begin
  Result := False;
  if csDestroying in ComponentState then Exit;
  if GetTickCount - FLastQuery < 1000 then Exit;

  nWhere := '';
  ListContract.Items.Clear;

  if nType = 10 then
  begin
    nWhere := 'sc.C_ID Like ''%$ID%''';
  end else

  if nType = 20 then
  begin
    if EditCustom.ItemIndex < 1 then
      EditCustom.Text := Trim(EditCustom.Text);
    //xxxxx
    
    if (EditSMan.ItemIndex < 1) and ((EditCustom.ItemIndex < 1) and
       (EditCustom.Text = '')) then Exit;
    //�޲�ѯ����

    if EditSMan.ItemIndex > 0 then
      nWhere := 'sc.C_SaleMan=''$SID''';
    //xxxxx

    if EditCustom.ItemIndex > 0 then
    begin
      if nWhere <> '' then
        nWhere := nWhere + ' And ';
      nWhere := nWhere + 'sc.C_Customer=''$CID''';
    end else
    begin
      if nWhere <> '' then
        nWhere := nWhere + ' And ';
      nWhere := nWhere + 'cus.C_PY Like ''%$CPY%''';
    end;
  end;

  nStr := 'Select sc.*,S_Name,C_Name From $SC sc ' +
          ' Left Join $SM sm On sm.S_ID=sc.C_SaleMan' +
          ' Left Join $Cus cus On cus.C_ID=sc.C_Customer ' +
          'Where IsNull(C_Freeze,'''')<>''$Yes''';
  //xxxxx
  
  if nWhere <> '' then
    nStr := nStr + ' And (' + nWhere + ')';
  nStr := nStr + ' Order By sc.C_ID';

  nStr := MacroValue(nStr, [MI('$SC', sTable_SaleContract),
          MI('$SM', sTable_Salesman), MI('$Cus', sTable_Customer),
          MI('$ID', EditCID.Text), MI('$SID', GetCtrlData(EditSMan)),
          MI('$Yes', sFlag_Yes), MI('$CID', GetCtrlData(EditCustom)),
          MI('$CPY', EditCustom.Text)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    with ListContract.Items.Add do
    begin
      Caption := FieldByName('C_ID').AsString;
      SubItems.Add(FieldByName('S_Name').AsString);
      SubItems.Add(FieldByName('C_Name').AsString);
      SubItems.Add(FieldByName('C_Project').AsString);

      ImageIndex := cItemIconIndex;
      Next;
    end;

    ListContract.ItemIndex := 0;
    Result := True;
  end;

  FLastQuery := GetTickCount;
  //xxxxx
end;

procedure TfFormGetContract.ListContractKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if ListContract.ItemIndex > -1 then
    begin
      FSelectedID := ListContract.Selected.Caption;
      ModalResult := mrOk;
    end;
  end;
end;

procedure TfFormGetContract.ListContractDblClick(Sender: TObject);
begin
  if ListContract.ItemIndex > -1 then
  begin
    FSelectedID := ListContract.Selected.Caption;
    ModalResult := mrOk;
  end;
end;

procedure TfFormGetContract.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditCID.Text := Trim(EditCID.Text);
  if (EditCID.Text <> '') and QueryContract(10) then ListContract.SetFocus;
end;

//Desc: ҵ��Ա���,��ȡ��ؿͻ�
procedure TfFormGetContract.EditSManPropertiesEditValueChanged(
  Sender: TObject);
var nStr: string;
begin
  if EditSMan.ItemIndex > 0 then
  begin
    AdjustStringsItem(EditCustom.Properties.Items, True);
    nStr := 'C_ID=Select C_ID,C_Name From %s Where C_SaleMan=''%s''';
    nStr := Format(nStr, [sTable_Customer, GetCtrlData(EditSMan)]);

    FDM.FillStringsData(EditCustom.Properties.Items, nStr, -1, '.');
    AdjustStringsItem(EditCustom.Properties.Items, False);
    EditCustom.Properties.Items.Insert(0, '');
  end;

  if QueryContract(20) then ListContract.SetFocus;
end;

procedure TfFormGetContract.EditCustomPropertiesEditValueChanged(
  Sender: TObject);
begin
  if QueryContract(20) then ListContract.SetFocus;
end;

procedure TfFormGetContract.EditCustomKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if QueryContract(20) then ListContract.SetFocus;
  end;
end;

procedure TfFormGetContract.BtnOKClick(Sender: TObject);
begin
  if ListContract.ItemIndex > -1 then
  begin
    FSelectedID := ListContract.Selected.Caption;
    ModalResult := mrOk;
  end else ShowMsg('���ڲ�ѯ�����ѡ��', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormGetContract, TfFormGetContract.FormID);
end.
