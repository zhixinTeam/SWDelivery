{*******************************************************************************
  ����: dmzn@163.com 2010-3-8
  ����: ֽ������

  ��ע:
  *.ĳ�ͻ�ԭ���оɵ�ֽ��,��������ֽ��ʱ,��Ҫ�Ծ�ֽ�����ʵ�����.
  *.��������������:1.����ֽ������,�����µ�ֽ��,ԭֽ�������дſ��Զ����̵���ֽ��
    ����;2.ԭֽ������,�����п��ý�ת����ֽ����,���ƾ�ֽ���Ŀ������;3.�¾�
    ֽ��ͬʱʹ��.
*******************************************************************************}
unit UFormZhiKaAdjust;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxListView,
  cxLabel, StdCtrls, cxRadioGroup, dxLayoutControl;

type
  TfFormZhiKaAdjust = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    Radio3: TcxRadioButton;
    dxLayout1Item3: TdxLayoutItem;
    Radio1: TcxRadioButton;
    dxLayout1Item4: TdxLayoutItem;
    Radio2: TcxRadioButton;
    dxLayout1Item5: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    cxLabel3: TcxLabel;
    dxLayout1Item8: TdxLayoutItem;
    cxLabel4: TcxLabel;
    dxLayout1Item9: TdxLayoutItem;
    ListZK: TcxListView;
    dxLayout1Item10: TdxLayoutItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListZKDblClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    procedure InitFormData;
    //��������
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    class function LoadZhiKaList(const nCusID: string): Boolean;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UAdjustForm, UFormCtrl, UFormBase, UFrameBase,
  USysGrid, USysDB, USysConst, USysBusiness, UDataModule;

type
  TCommonInfo = record
    FCusID: string;
    FSQLRes: string;
  end;

  TZhiKaItem = record
    FZhiKa: string;
    FLading: string;
    FMan: string;
    FDate: string;
  end;

var
  gInfo: TCommonInfo;
  gZKItems: array of TZhiKaItem;
  //ȫ��ʹ��

//------------------------------------------------------------------------------
class function TfFormZhiKaAdjust.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  nP.FCommand := cCmd_ModalResult;
  gInfo.FCusID := nP.FParamA;

  if not TfFormZhiKaAdjust.LoadZhiKaList(gInfo.FCusID) then
  begin
    nP.FParamA := mrOk;
    nP.FParamB := ''; Exit;
  end;

  with TfFormZhiKaAdjust.Create(Application) do
  begin
    Caption := '�ɿ�����';
    InitFormData;
    nP.FParamA := ShowModal;
    nP.FParamB := gInfo.FSQLRes;
    Free;
  end;
end;

class function TfFormZhiKaAdjust.FormID: integer;
begin
  Result := cFI_FormZhiKaAdjust;
end;

procedure TfFormZhiKaAdjust.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListZK, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormZhiKaAdjust.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListZK, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ����������
procedure TfFormZhiKaAdjust.InitFormData;
var nIdx: Integer;
begin
  ListZK.Clear;
  ListZK.SmallImages := FDM.ImageBar;

  for nIdx:=Low(gZKItems) to High(gZKItems) do
  with ListZK.Items.Add,gZKItems[nIdx] do
  begin
    Caption := FZhiKa;
    if FLading = sFlag_SongH then
         SubItems.Add('�ͻ�')
    else SubItems.Add('����');
    
    SubItems.Add(FMan);
    SubItems.Add(FDate);
    ImageIndex := cItemIconIndex;
  end;

  if ListZK.Items.Count > 1 then
       ListZK.ItemIndex := -1
  else ListZK.ItemIndex := 0; //����һ��ʱ���û�ѡ��
end;

//Desc: ����nCusID�ͻ�ʹ�ù����˻��ʽ��ֽ��
class function TfFormZhiKaAdjust.LoadZhiKaList(const nCusID: string): Boolean;
var nStr: string;
    nIdx: integer;
begin
  Result := False;
  gInfo.FSQLRes := '';
  SetLength(gZKItems, 0);

  nStr := 'Select * From %s Where Z_Customer=''%s'' and ' +
          '(Z_OnlyMoney Is Null and Z_InValid Is Null) and ' +
          'Z_ValidDays>%s Order By Z_ID';
  nStr := Format(nStr, [sTable_ZhiKa, nCusID, FDM.SQLServerNow]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    SetLength(gZKItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with gZKItems[nIdx] do
    begin
      FZhiKa := FieldByName('Z_ID').AsString;
      FLading := FieldByName('Z_Lading').AsString;
      FMan := FieldByName('Z_Man').AsString;
      FDate := DateTime2Str(FieldByName('Z_Date').AsDateTime);

      Inc(nIdx);
      Next;
    end;

    Result := True;
  end;
end;

//Desc: �鿴ѡ�дſ�
procedure TfFormZhiKaAdjust.ListZKDblClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if ListZK.ItemIndex > -1 then
  begin
    nP.FCommand := cCmd_ViewData;
    nP.FParamA := gZKItems[ListZK.ItemIndex].FZhiKa;
    CreateBaseFormItem(cFI_FormZhiKa, '', @nP);
  end;
end;

//Desc: ȷ�ϵ���ģʽ
procedure TfFormZhiKaAdjust.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if (Radio2.Checked or Radio3.Checked) and (ListZK.Items.Count > 0) and
     (ListZK.ItemIndex < 0) then
  begin
    ListZK.SetFocus;
    ShowMsg('��ѡ��Ҫ������ֽ��', sHint); Exit;
  end;

  nStr := 'ע��: �ò��������Գ���,��������!' + #13#10 + 'Ҫ������?';
  if not QueryDlg(nStr, sAsk, Handle) then Exit;

  if Radio1.Checked then
  begin
    gInfo.FSQLRes := '';
  end else
  
  if Radio2.Checked then
  begin
    nStr := 'Update $ZK Set Z_FixedMoney=$Money,Z_OnlyMoney=''$Yes'' ' +
            'Where Z_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$Yes', sFlag_Yes),
            MI('$ID', gZKItems[ListZK.ItemIndex].FZhiKa)]);
    gInfo.FSQLRes := nStr;
  end else

  if Radio3.Checked then
  begin
    nStr := 'Update $ZK Set Z_InValid=''$Yes'' Where Z_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$Yes', sFlag_Yes),
            MI('$ID', gZKItems[ListZK.ItemIndex].FZhiKa)]);
    gInfo.FSQLRes := nStr;
  end;

  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormZhiKaAdjust, TfFormZhiKaAdjust.FormID);
end.
