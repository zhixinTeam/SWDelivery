unit UFramePurOrderImport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, dxSkinsdxLCPainter, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, StdCtrls, cxTextEdit,
  cxMaskEdit, cxButtonEdit;

type
  TfFramePurOrderImport = class(TfFrameNormal)
    dxlytmLayout1Item1: TdxLayoutItem;
    Edt_Name: TcxButtonEdit;
    btn1: TButton;
    dxlytmLayout1Item11: TdxLayoutItem;
    dlgOpen1: TOpenDialog;
    Qry_1: TADOQuery;
    procedure Edt_NameClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
    FListA : TStrings;
  private
    procedure ImportExcel;
  protected
      function InitFormDataSQL(const nWhere: string): string; override;
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFramePurOrderImport: TfFramePurOrderImport;

implementation

{$R *.dfm}


uses
  ULibFun, UMgrControl,UDataModule, UFrameBase, UFormBase, USysBusiness,
  USysConst, USysDB, UFormDateFilter, UFormInputbox, ComObj;


class function TfFramePurOrderImport.FrameID: integer;
begin
  Result := cFI_FrameOrderImport;
end;

procedure TfFramePurOrderImport.ImportExcel;
function GetRNum:string;
begin
  Randomize;
  Result:= IntToStr(Random(23));
end;
const
  BeginRow = 2; BeginCol = 1;  
var
  Excel: OleVariant;
  iRow, iCol, nIdx, nMark : integer;
  xlsFilename, nSQL, nTime, nMan: string;
begin
  FListA:= TStringList.Create;   nMark:= -1;  nIdx:= 1;  nMan:= '';
  FListA.Clear;
  try
    dlgOpen1.Title := '请选择正确的excel文件';
    dlgOpen1.Filter := 'Excel(*.xls)|*.xls';
    if dlgOpen1.Execute then
      Edt_Name.Text := dlgOpen1.FileName;

    if (trim(Edt_Name.Text) = '') then
    begin
      GetActiveWindow();
      showmessage( '请选择正确的excel路径');  
      exit;
    end;  
    xlsFilename := trim(Edt_Name.Text);

    try  
      Excel := CreateOLEObject('Excel.Application');
    except  
      showmessage('你的电脑尚未安装Excel');  
      Exit;  
    end;
  
    Excel.Visible := false;
    Excel.WorkBooks.Open(xlsFilename);
    //ExcelRowCount := Excel.WorkSheets[1].UsedRange.Rows.Count;
    //showmessage(inttoStr(ExcelRowCount));
    try
      iRow := Excel.ActiveSheet.UsedRange.Rows.count;;
      iCol := BeginCol;

      while (Trim(Excel.WorkSheets[1].Cells[nIdx, 1].value) <> '')and(nIdx<=iRow) do
      begin
        nSQl:= '';
        //Fields[0].AsString := trim(Excel.WorkSheets[1].Cells[iRow,iCol].value);
        nSQl:= Trim(Excel.WorkSheets[1].Cells[nIdx,iCol].value);
        nMan:= StringReplace(Trim(Excel.WorkSheets[1].Cells[nIdx, 9].value), '?', '', [rfReplaceAll]);

        if (nIdx mod (iRow div 23))=0 then nMark:= 0
        else nMark:= nMark + 1;

        nTime:= Trim(Excel.WorkSheets[1].Cells[nIdx, 1].value) +' '+ intToStr(nMark) + ':00:00';


        nSQl:= ' Insert Into P_OrderDtlImportTemp(D_Truck, D_ProName, D_ProPY, D_Type, D_StockName, D_Status, D_NextStatus, D_InTime, D_InMan, D_PValue, D_PDate, D_PMan, '+
                                                 'D_MValue, D_MDate, D_MMan, D_YTime, D_YMan, D_Value, D_KZValue, D_YSResult, D_OutFact) '+
                   ' Select '''+Trim(Excel.WorkSheets[1].Cells[nIdx, 3].value)+''', '''+ Trim(Excel.WorkSheets[1].Cells[nIdx, 2].value)+''', '''+
                                GetPinYinOfStr(Trim(Excel.WorkSheets[1].Cells[nIdx, 2].value))+''', ''S'', '''+
                                Trim(Excel.WorkSheets[1].Cells[nIdx, 4].value)+''', ''O'', '''', '''+ nTime+''', '''+
                                nMan+''', '''+ Trim(Excel.WorkSheets[1].Cells[nIdx, 7].value)+''', '''+ nTime+''', '''+ nMan+''', '''+
                                Trim(Excel.WorkSheets[1].Cells[nIdx, 6].value)+''', '''+ nTime+''', '''+ nMan+''', '''+ nTime+''', '''+
                                nMan+''', '''+ Trim(Excel.WorkSheets[1].Cells[nIdx, 8].value)+''', ''0'', ''Y'', '''+nTime+'''';
          FListA.Add(nSQL);

          nIdx := nIdx + 1;
      end;
      Excel.Quit;

      //----------------------------------------------------------------------------
      try
        FDM.ExecuteSQL('Delete P_OrderDtlImportTemp');
        
        for nIdx:=0 to FListA.Count - 1 do
          FDM.ExecuteSQL(FListA[nIdx]);

      except
        ShowMsg(Format('执行保存操作出错、记录编号 %d ', [nIdx]), '提示');
      end;
    except
      ShowMsg('导入数据出错', '提示');
      //Exit;
    end;
    ShowMsg('数据导入成功', '提示');

    FDM.ExecuteSQL('UPDate P_OrderDtlImportTemp Set D_InTime= DATEADD(MI, 3, D_InTime)');
    FDM.ExecuteSQL('UPDate P_OrderDtlImportTemp Set D_MDate= DATEADD(MI, 5, D_InTime) ');
    FDM.ExecuteSQL('UPDate P_OrderDtlImportTemp Set D_YTime= DATEADD(MI, 7, D_MDate)  ');
    FDM.ExecuteSQL('UPDate P_OrderDtlImportTemp Set D_PDate= DATEADD(MI, 6, D_YTime)  ');
    FDM.ExecuteSQL('UPDate P_OrderDtlImportTemp Set D_OutFact= DATEADD(MI, 7, D_PDate)');
    FDM.ExecuteSQL('UPDate P_OrderDtlImportTemp Set D_BId=B_Id, D_ProId=B_ProId From P_OrderBase Where D_ProName=B_ProName And B_StockName=D_StockName ');
  finally
    FreeAndNil(FListA);
    Excel.Quit;
    BtnRefresh.Click;
  end;
end;

function TfFramePurOrderImport.InitFormDataSQL(const nWhere: string): string;
begin
  Result := ' Select Right(CONVERT(VARCHAR(10),GETDATE(),112), 6)+Right(Cast(''00000000000''+Rtrim(ROW_NUMBER() OVER(ORDER BY D_InMan)) as varchar(20)),6) D_ID, '+
            '        ''S''+Right(CONVERT(VARCHAR(10),GETDATE(),112), 6)+Right(Cast(''00000000000''+Rtrim(ROW_NUMBER() OVER(ORDER BY D_InMan)) as varchar(20)),5) D_OID, * '+
            ' From   $PurOrderDtlTemp ';

  Result := MacroValue(Result, [MI('$PurOrderDtlTemp', sTable_OrderDtlTemp)]);
  //xxxxx
end;

procedure TfFramePurOrderImport.Edt_NameClick(Sender: TObject);
begin
  ImportExcel;
end;

procedure TfFramePurOrderImport.btn1Click(Sender: TObject);
var nStr : string;
begin
  if MessageBox(Handle, '确定已核对数据无误、要执行导入操作么？', '信息提示', MB_OKCANCEL + MB_ICONQUESTION) =IDOK then
  begin
    //****************
    try
      nStr:= 'INSERT INTO %s(O_ID, O_BID, O_CType, O_Value, O_ProID, O_ProName, O_ProPY, O_Type, O_StockNo, O_StockName,O_Truck, O_Man, O_Date) '+
             'Select ''S''+Right(CONVERT(VARCHAR(10),GETDATE(),112), 6)+Right(Cast(''00000000000''+Rtrim(ROW_NUMBER() OVER(ORDER BY D_InMan)) as varchar(20)),5),  '+
                     'D_BID, ''L'', 0, D_ProID, D_ProName, D_ProPY, D_Type, D_StockNo, D_StockName, D_Truck, D_InMan, DATEADD(SS, -1, D_InTime)  '+
             'From   %s ';

      nStr:= Format(nStr, [sTable_Order, sTable_OrderDtlTemp]);
      FDM.ExecuteSQL(nStr);
      //****************************************
      nStr:= 'INSERT INTO %s(D_ID, D_OID, D_Truck, D_ProID, D_ProName, D_ProPY, D_Type, D_StockNo, D_StockName, D_Status, D_NextStatus, D_InTime, D_InMan, '+
             '               D_PValue, D_PDate, D_PMan, D_MValue, D_MDate, D_MMan, D_YTime, D_YMan, D_Value, D_KZValue, D_YSResult, D_OutFact,  D_OutMan)  '+
             'Select Right(CONVERT(VARCHAR(10),GETDATE(),112), 6)+Right(Cast(''00000000000''+Rtrim(ROW_NUMBER() OVER(ORDER BY D_InMan)) as varchar(20)),6),  '+
                    '''S''+Right(CONVERT(VARCHAR(10),GETDATE(),112), 6)+Right(Cast(''00000000000''+Rtrim(ROW_NUMBER() OVER(ORDER BY D_InMan)) as varchar(20)),5),  '+
                    'D_Truck, D_ProID, D_ProName, D_ProPY, D_Type, D_StockNo, D_StockName, D_Status, D_NextStatus, D_InTime, '''', D_PValue, D_PDate,   '+
                    'D_PMan, D_MValue, D_MDate, D_MMan, D_YTime, D_YMan, D_Value, D_KZValue, D_YSResult, D_OutFact,  '''' '+
             'From   %s  ';

      nStr:= Format(nStr, [sTable_OrderDtl, sTable_OrderDtlTemp]);
      FDM.ExecuteSQL(nStr);
//      //****************************************
//      nStr:= 'INSERT INTO %s(P_ID, P_Type, P_Order, P_Truck, P_CusID, P_CusName, P_MID, P_MName, P_MType, P_LimValue, P_PValue, P_PDate, P_PMan,   '+
//                              'P_MValue, P_MDate, P_MMan, P_FactID, P_PStation, P_MStation, P_PModel, P_Status, P_Valid, P_PrintNum, P_KZValue)    '+
//             'Select ''P''+Right(CONVERT(VARCHAR(10),GETDATE(),112), 6)+Right(Cast(''00000000000''+Rtrim(ROW_NUMBER() OVER(ORDER BY D_InMan)) as varchar(20)),5),  '+
//                    '''P'', Right(CONVERT(VARCHAR(10),GETDATE(),112), 6)+Right(Cast(''00000000000''+Rtrim(ROW_NUMBER() OVER(ORDER BY D_InMan)) as varchar(20)),6), '+
//                    'D_Truck, D_ProID, D_ProName, D_StockNo, D_StockName, D_Type, 0, D_PValue, D_PDate, D_PMan, D_MValue, D_MDate, D_MMan, ''SXSW'', ''SW01'', ''SW02'', '+
//                    '''P'', ''P'', ''Y'', 1, D_KZValue '+
//             'From  %s ';
//
//      nStr:= Format(nStr, [sTable_PoundLog, sTable_OrderDtlTemp]);
//      nStr:= nStr;
//      FDM.ExecuteSQL(nStr);
    except
      ShowMsg('导入失败', '提示');
    end;
    FDM.ExecuteSQL('Delete  P_OrderDtlImportTemp ');
  end;
end;

initialization
  gControlManager.RegCtrl(TfFramePurOrderImport, TfFramePurOrderImport.FrameID);


end.
