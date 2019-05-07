unit UFromUPDateBindBillZhiKa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinsdxLCPainter, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxLabel, cxTextEdit, cxMaskEdit, cxButtonEdit, cxMemo;

type
  TfFormUPDateBindBillZhika = class(TfFormNormal)
    dxLayout1Item3: TdxLayoutItem;
    Edt_NCOrder: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    edt_PValue: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    edt_MValue: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Item5: TdxLayoutItem;
    edt_StockName: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    edt_StockNo: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    edt_CusName: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    edt_CusId: TcxTextEdit;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Item4: TdxLayoutItem;
    edt_Truck: TcxTextEdit;
    dxLayout1Group7: TdxLayoutGroup;
    dxLayout1Item11: TdxLayoutItem;
    edt_YunFei: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    edt_Price: TcxTextEdit;
    dxLayout1Group8: TdxLayoutGroup;
    dxLayout1Item14: TdxLayoutItem;
    edt_Bill: TcxTextEdit;
    dxLayout1Group6: TdxLayoutGroup;
    procedure EditCustomerPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FZKPK, FPKDtl, FOldOrder, FNewOrder: string;
    FNeedSync:Boolean;
  private
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function  LoadBill(nId:string):Boolean;
    function  LoadZhiKaInfo(nId:string):Boolean;
  public
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormUPDateBindBillZhika: TfFormUPDateBindBillZhika;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysPopedom, USysBusiness, USysDB, USysGrid, USysConst, NativeXml,
  UFormCtrl, UFormWait;


function GetLeftStr(SubStr, Str: string): string;
begin
   Result := Copy(Str, 1, Pos(SubStr, Str) - 1);
end;

function GetRightStr(SubStr, Str: string): string;
var
   i: integer;
begin
   i := pos(SubStr, Str);
   if i > 0 then
     Result := Copy(Str
       , i + Length(SubStr)
       , Length(Str) - i - Length(SubStr) + 1)
   else
     Result := '';
end;


class function TfFormUPDateBindBillZhika.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nBool: Boolean;
    nP: PFormCommandParam;
begin
  Result := nil;
  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  with TfFormUPDateBindBillZhika.Create(Application) do
  try
    FZKPK:= ''; FPKDtl:= '';
    LoadBill(nP.FParamA);

    ShowModal;
  finally
    Free;
  end;
end;

class function TfFormUPDateBindBillZhika.FormID: integer;
begin
  Result := cFI_FormUPDateBindBillZhika;
end;

procedure TfFormUPDateBindBillZhika.FormCreate(Sender: TObject);
var nStr: string;
    nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nStr := nIni.ReadString(Name, 'FQLabel', '');
    if nStr <> '' then
      dxLayout1Item5.Caption := nStr;
    //xxxxx

  finally
    nIni.Free;
  end;
end;

procedure TfFormUPDateBindBillZhika.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ReleaseCtrlData(Self);
end;

function TfFormUPDateBindBillZhika.LoadBill(nId:string):Boolean;
var nStr : string;
begin
  nStr := ' Select * From S_Bill Where L_id='''+nId+''' ';
  //信息
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      Edt_NCOrder.Text  := FieldByName('L_ZhiKa').AsString;
      edt_Bill.Text     := FieldByName('L_ID').AsString;
      edt_CusId.Text    := FieldByName('L_CusID').AsString;
      edt_CusName.Text  := FieldByName('L_CusName').AsString;

      edt_StockNo.Text  := FieldByName('L_StockNo').AsString;
      edt_StockName.Text:= FieldByName('L_StockName').AsString;
      edt_Price.Text    := FieldByName('L_Price').AsString;
      edt_YunFei.Text   := FieldByName('L_YunFei').AsString;

      edt_Truck.Text   := FieldByName('L_Truck').AsString;
      edt_PValue.Text   := FieldByName('L_PValue').AsString;
      edt_MValue.Text   := FieldByName('L_MValue').AsString;

      FZKPK := FieldByName('L_PkZK').AsString;
      FPKDtl:= FieldByName('L_PKDtl').AsString;
      FNeedSync:= FieldByName('L_Status').AsString='O';
    end;
  end;

  FOldOrder:= Format('%s %s %s %s 皮重 %s 毛重 %s ', [Edt_NCOrder.Text, edt_Truck.Text,
        edt_CusId.Text, edt_CusName.Text, edt_PValue.Text, edt_MValue.Text]);
end;

function TfFormUPDateBindBillZhika.LoadZhiKaInfo(nId:string):Boolean;
var nStr : string;
begin
  nStr := ' Select * From S_Zhika Left Join S_ZhikaDtl On Z_ID=D_ZID '+
          'Left Join S_Customer On Z_Customer=C_ID Where Z_ID='''+nId+''' ';
  //信息
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      Edt_NCOrder.Text  := FieldByName('Z_ID').AsString;
      edt_CusId.Text    := FieldByName('C_ID').AsString;
      edt_CusName.Text  := FieldByName('C_Name').AsString;

      edt_StockNo.Text  := FieldByName('D_StockNo').AsString;
      edt_StockName.Text:= FieldByName('D_StockName').AsString;
      edt_Price.Text    := FieldByName('D_Price').AsString;
      edt_YunFei.Text   := FieldByName('D_YunFei').AsString;

      FZKPK := FieldByName('Z_PKzk').AsString;
      FPKDtl:= FieldByName('D_PKDtl').AsString;
    end;
  end;
end;

procedure TfFormUPDateBindBillZhika.EditCustomerPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nP: PFormCommandParam;
begin
  try
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);

    CreateBaseFormItem(cFI_FormGetZhika, '', nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then
      Exit;

    LoadZhiKaInfo(nP.FParamB);
  finally
    Dispose(nP);
  end;
end;

function GetBillDtlInfo(nId : string): string;
var nList : TStrings;
begin
  Result:= '';
  nList:= TStringList.Create;
  try
    //***********
    nList.Values['Proc'] := 'delete';
    nList.Values['ID'] := nId;

    Result:= EncodeBase64(nList.Text);
  finally
    nList.Free;
  end;
end;

procedure TfFormUPDateBindBillZhika.BtnOKClick(Sender: TObject);
var nSQL, nStr, nMsg, nData, nS, nY: string;
    nVal : Double;
begin
  nVal := StrToFloatDef(edt_MValue.Text, 0)-StrToFloatDef(edt_PValue.Text, 0);
  IF nVal<0 then
  begin
    ShowMsg('操作失败：请检查毛重、皮重是否正确', sError);
    Exit;
  end;
  if (Trim(EditMemo.Text)='')then
  begin
    ShowMsg('请填写修改订单原因', sError);
    Exit;
  end;
  if (FZKPK='')or(FPKDtl='')then
  begin
    ShowMsg('操作失败：无效的 NC 订单信息、请检查', sError);
    Exit;
  end;

  nStr := 'Select N_OrderNo, N_Status From %s Where N_OrderNo=''%s'' And N_Status=0 ' +
          'Union  ' +
          'Select N_OrderNo, N_Status From %s Where N_OrderNo=''%s'' And N_Status=0 ';

  nStr := Format(nStr, [sTable_UPLoadOrderNc, edt_Bill.Text, sTable_UPLoadOrderNcHistory, edt_Bill.Text]);
  with FDM.QueryTemp(nStr) do
  begin
    FNeedSync:= (RecordCount > 0);
    if RecordCount > 0 then
    begin
      nData := GetBillDtlInfo(edt_Bill.Text);
      if nData<>'' then
      if not SendDeleteBillMsgToNc(nData, nMsg) then
      begin
        ShowMsg('操作失败：' + nMsg, sError);
        Exit;
      end;

      nSQL := 'Insert Into S_UPLoadOrderNcHistory(N_OrderNo, N_Type, N_Status, N_Proc, N_SyncNum) ' +
              '  Select ''%s'', ''S'', 0, ''Delete'', 1 ';
      nSQL := Format(nSQL, [edt_Bill.Text]);
      FDM.ExecuteSQL(nSQL);
    end;                      
  end;

  FDM.ADOConn.BeginTrans;
  try
    nSQL := 'UPDate S_Bill Set L_ZhiKa=''%s'', L_PkZK=''%s'', L_PkDtl=''%s'', L_Price=%s, L_YunFei=%s, L_CusId=''%s'', L_CusName=''%s'', '+
                              'L_StockNo=''%s'', L_StockName=''%s'', L_PValue=%g, L_MValue=%g, L_DelReson=''%s'' '+
            'Where L_ID=''%s'' ';
    nSQL := Format(nSQL, [Edt_NCOrder.Text, FZKPK, FPKDtl, edt_Price.Text, edt_YunFei.Text, edt_CusId.Text, edt_CusName.Text,
                          edt_StockNo.Text, edt_StockName.Text, StrToFloatDef(edt_PValue.Text, 0), StrToFloatDef(edt_MValue.Text, 0),
                          EditMemo.Text, edt_Bill.Text]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'UPDate S_Bill Set L_Value=L_MValue-L_PValue Where ' +GetRightStr('Where',nSQL);
    FDM.ExecuteSQL(nSQL);

    nSQL := MakeSQLByStr([SF('P_CusID', edt_CusId.Text),
            SF('P_CusName', edt_CusName.Text),
            SF('P_MID', edt_StockNo.Text),
            SF('P_MName', edt_StockName.Text),
            SF('P_Truck', edt_Truck.Text),
            SF('P_PValue', StrToFloatDef(edt_PValue.Text, 0), sfVal),
            SF('P_MValue', StrToFloatDef(edt_MValue.Text, 0), sfVal)
            ], sTable_PoundLog, SF('P_Bill', edt_Bill.Text), False);
    FDM.ExecuteSQL(nSQL);
    //更新磅单

    nSQL:= Format('Delete S_UPLoadOrderNc Where N_OrderNo=''%s'' ', [edt_Bill.Text]);
    FDM.ExecuteSQL(nSQL);

    IF (nVal>0) and FNeedSync then
    begin
      nSQL:= Format('Insert into S_UPLoadOrderNc(N_OrderNo, N_Type, N_Status, N_Proc, N_SyncNum) '+
                    'Select ''%s'',''S'',-1,''add'',0 ', [edt_Bill.Text]);
      FDM.ExecuteSQL(nSQL);
    end;

    FNewOrder:= Format('%s %s %s %s 皮重 %s 毛重 %s ', [Edt_NCOrder.Text, edt_Truck.Text,
                          edt_CusId.Text, edt_CusName.Text, edt_PValue.Text, edt_MValue.Text]);
    nStr:= Format(' %s 修改销售单 调整前[ %s ] 调整后[ %s ]',
                  [gSysParam.FUserName, FOldOrder, FNewOrder]);
    FDM.WriteSysLog(sFlag_BillItem, '', nStr, False);

    FDM.ADOConn.CommitTrans;
    ModalResult := mrOK;
    ShowMsg('修改成功、稍后将上传 NC、请留意上传状态', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('数据保存失败', '未知原因');
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormUPDateBindBillZhika, TfFormUPDateBindBillZhika.FormID);

end.
