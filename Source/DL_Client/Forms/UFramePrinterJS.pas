unit UFramePrinterJS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, dxSkinsdxLCPainter, cxContainer, Menus, ADODB,
  cxLabel, UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin;

type
  TfFramePrinterJS = class(TfFrameNormal)
    pm1: TPopupMenu;
    N1: TMenuItem;
    procedure N1Click(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
  public
    class function FrameID: integer; override;
  end;

var
  fFramePrinterJS: TfFramePrinterJS;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter;

class function TfFramePrinterJS.FrameID: integer;
begin
  Result := cFI_FramePrinterJs;
end;

//Desc: ���ݲ�ѯSQL
function TfFramePrinterJS.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  Result := 'Select * From Sys_PrintTotle ';
end;

procedure TfFramePrinterJS.N1Click(Sender: TObject);
var nStr : string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'UPDate %s Set P_CurrNum=0 Where R_ID=%s';
    nStr := Format(nStr, [sTable_PrintTotle, SQLQuery.FieldByName('R_ID').AsString]);
    FDM.ExecuteSQL(nStr);

    InitFormData(FWhere);
    ShowMsg('�����øĴ�ӡ������', sHint);
  end;
end;

procedure TfFramePrinterJS.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  CreateBaseFormItem(cFI_FormPrinterJs, PopedomItem, @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFramePrinterJS.BtnDelClick(Sender: TObject);
var nRid, nStr:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nRid:= SQLQuery.FieldByName('R_id').AsString;
  if nRid='' then
  begin
    ShowMsg('��Ч�Ĵ�ӡ����ʾ��������ѡ��', sHint); Exit;
  end;

  nStr := 'ȷ��Ҫɾ��[ %s ]�ļ���ô?';
  nStr := Format(nStr, [SQLQuery.FieldByName('P_PrinterName').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  nStr := Format('Delete %s Where R_id=%s ', [sTable_PrintTotle, nRid]);
  FDM.ExecuteSQL(nStr);

  InitFormData(FWhere);
  ShowMsg('��ɾ��', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFramePrinterJS, TfFramePrinterJS.FrameID);

end.
