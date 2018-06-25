{*******************************************************************************
  ����: dmzn@163.com 2009-6-12
  ����: ���ۺ�ͬ����
*******************************************************************************}
unit UFrameSaleContract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameSaleContract = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl,UDataModule, UFrameBase, UFormBase, USysBusiness,
  USysConst, USysDB;

//------------------------------------------------------------------------------
class function TfFrameSaleContract.FrameID: integer;
begin
  Result := cFI_FrameSaleContract;
end;

//Desc: ���ݲ�ѯSQL
function TfFrameSaleContract.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select con.*,sm.S_Name,sm.S_PY,cus.C_Name as Cus_Name,' +
            'cus.C_PY From $Con con' +
            ' Left Join $SM sm On sm.S_ID=con.C_SaleMan' +
            ' Left Join $Cus cus On cus.C_ID=con.C_Customer';
  //xxxxx

  if nWhere = '' then
       Result := Result + ' Where IsNull(C_Freeze, '''')<>''$Yes'''
  else Result := Result + ' Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$Con', sTable_SaleContract),
            MI('$SM', sTable_Salesman),
            MI('$Cus', sTable_Customer), MI('$Yes', sFlag_Yes)]);
  //xxxxx
end;

//Desc: �ر�
procedure TfFrameSaleContract.BtnExitClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if not IsBusy then
  begin
    nParam.FCommand := cCmd_FormClose;
    CreateBaseFormItem(cFI_FormSaleContract, '', @nParam); Close;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ���
procedure TfFrameSaleContract.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormSaleContract, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: �޸�
procedure TfFrameSaleContract.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
  CreateBaseFormItem(cFI_FormSaleContract, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: ɾ��
procedure TfFrameSaleContract.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('C_ID').AsString;
  nSQL := 'Select Count(*) From %s Where Z_CID=''%s''';
  nSQL := Format(nSQL, [sTable_ZhiKa, nStr]);

  with FDM.QueryTemp(nSQL) do
  if Fields[0].AsInteger > 0 then
  begin
    ShowMsg('�ú�ͬ������ɾ��', '�Ѱ�ֽ��'); Exit;
  end;

  if not QueryDlg('ȷ��Ҫɾ�����Ϊ[ ' + nStr + ' ]�ĺ�ͬ��?', sAsk) then Exit;
  FDM.ADOConn.BeginTrans;
  try
    nSQL := 'Delete From %s Where C_ID=''%s''';
    nSQL := Format(nSQL, [sTable_SaleContract, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where E_CID=''%s'' ';
    nSQL := Format(nSQL, [sTable_SContractExt, nStr]);
    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('�ѳɹ�ɾ����¼', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('ɾ����¼ʧ��', 'δ֪����');
  end;
end;

//Desc: �鿴����
procedure TfFrameSaleContract.cxView1DblClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nParam.FCommand := cCmd_ViewData;
    nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
    CreateBaseFormItem(cFI_FormSaleContract, PopedomItem, @nParam);
  end;
end;

//Desc: ִ�в�ѯ
procedure TfFrameSaleContract.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'con.C_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'C_PY like ''%%%s%%'' Or C_Name like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'S_PY like ''%%%s%%'' Or S_Name like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: ��ӡ��ͬ
procedure TfFrameSaleContract.N1Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('C_ID').AsString;
    PrintSaleContractReport(nStr, False);
  end;
end;

//Desc: �鿴��ۼ�¼
procedure TfFrameSaleContract.N3Click(Sender: TObject);
var nStr: string;
    nParam: TFrameCommandParam;
begin
  nParam.FCommand := cCmd_ViewSysLog;
  nParam.FParamA := '2008-08-08';
  nParam.FParamB := '2050-12-12';

  nStr := 'L_Group=''$Group'' And L_ItemID=''$ID''';
  nParam.FParamC := MacroValue(nStr, [MI('$Group', sFlag_ContractItem),
                    MI('$ID', SQLQuery.FieldByName('C_ID').AsString)]);
  //��������

  CreateBaseFrameItem(cFI_FrameSysLog, Parent, 'MAIN_A02');
  BroadcastFrameCommand(Self, Integer(@nParam));
end;

//Desc: ����,�ⶳ��ͬ
procedure TfFrameSaleContract.N5Click(Sender: TObject);
var nStr,nSQL: string;
begin
  if Sender = N7 then
  begin
    InitFormData('1=1');
    Exit;
  end; //query all

  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    case TComponent(Sender).Tag of
      10: nStr := sFlag_Yes;
      20: nStr := sFlag_No;
    end;

    nSQL := 'Update %s Set C_Freeze=''%s'' Where C_ID=''%s''';
    nSQL := Format(nSQL, [sTable_SaleContract, nStr,
                          SQLQuery.FieldByName('C_ID').AsString]);
    //xxxxx
    
    FDM.ExecuteSQL(nSQL);
    InitFormData(FWhere);
    ShowMsg('�����ɹ�', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameSaleContract, TfFrameSaleContract.FrameID);
end.
