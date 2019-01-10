unit UFormCtlCusbd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinsdxLCPainter, cxContainer, cxEdit, ComCtrls, cxListView,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, dxLayoutControl, StdCtrls;

type
  TfFormCtlCusbd = class(TfFormNormal)
    dxlytmLayout1Item3: TdxLayoutItem;
    EditCustom: TcxComboBox;
    dxlytmLayout1Item31: TdxLayoutItem;
    ListCustom: TcxListView;
    dxlytmLayout1Item32: TdxLayoutItem;
    btn1: TButton;
    dxLayout1Group2: TdxLayoutGroup;
    procedure cbbEditCustomPropertiesEditValueChanged(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    nTruck:string;
  private
    function QueryCustom(const nType: Byte): Boolean;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormCtlCusbd: TfFormCtlCusbd;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UAdjustForm, UFormCtrl, UFormBase, USysGrid,
  USysDB, USysConst, USysBusiness, UDataModule;


class function TfFormCtlCusbd.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormCtlCusbd.Create(Application) do
  begin
    nP.FCommand := cCmd_ModalResult;
    nTruck:= nP.FParamB;
      QueryCustom(10);
    nP.FParamA := ShowModal;

    Free;
  end;
end;

//Date: 2010-3-9
//Parm: 查询类型(10: 按名称;20: 按人员)
//Desc: 按指定类型查询合同
function TfFormCtlCusbd.QueryCustom(const nType: Byte): Boolean;
var nStr,nWhere: string;
begin
  Result := False;
  nWhere := '';
  ListCustom.Items.Clear;

  nWhere := '(T_CName Like ''%$ID%'' or T_CID=''$ID'') And T_Truck=''$Truck'' ';

  nStr := 'Select R_ID,T_Truck,T_CID,T_CName From $TRCus ';
  if nWhere <> '' then
    nStr := nStr + ' Where (' + nWhere + ')';
  nStr := nStr + ' Order By T_CID';

  nStr := MacroValue(nStr, [MI('$TRCus', sTable_TruckCus), MI('$Truck', nTruck),
                            MI('$ID', GetCtrlData(EditCustom))]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    with ListCustom.Items.Add do
    begin
      Caption := FieldByName('R_ID').AsString;
      SubItems.Add(FieldByName('T_CID').AsString);
      SubItems.Add(FieldByName('T_CName').AsString);

      ImageIndex := cItemIconIndex;
      Next;
    end;

    ListCustom.Column[1].Width:= 70;
    ListCustom.ItemIndex := 0;
    Result := True;
  end;
end;

procedure TfFormCtlCusbd.cbbEditCustomPropertiesEditValueChanged(
  Sender: TObject);
begin
  QueryCustom(10);
end;

class function TfFormCtlCusbd.FormID: integer;
begin
  Result := cFI_FormCtlCusbd;
end;

procedure TfFormCtlCusbd.btn1Click(Sender: TObject);
begin
  QueryCustom(10);
end;

procedure TfFormCtlCusbd.BtnOKClick(Sender: TObject);
var nStr, nRId:string;
begin
  if ListCustom.ItemIndex > -1 then
  begin
    nRId:= ListCustom.Selected.Caption;
    nStr:= ' Delete %s Where R_ID=%s ';
    nStr:= Format(nStr, [sTable_TruckCus, nRId]);
        //xxxxxx

    FDM.ExecuteSQL(nStr);

    ModalResult := mrOk;
  end
  else ShowMsg('请选择要解除绑定关系的客户记录', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormCtlCusbd, TfFormCtlCusbd.FormID);


end.
