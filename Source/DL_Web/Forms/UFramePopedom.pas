{*******************************************************************************
  ����: dmzn@163.com 2018-05-28
  ����: Ȩ�޹���
*******************************************************************************}
unit UFramePopedom;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  USysConst, uniGUIFrame, uniGUIAbstractClasses, Data.Win.ADODB, uniGUIForm,
  uniGUITypes, Vcl.Menus, uniMainMenu, uniLabel, uniTreeView, uniGUIClasses,
  uniBasicGrid, uniStringGrid, uniPanel, uniSplitter, uniToolBar, Vcl.Controls,
  Vcl.Forms, uniGUIBaseClasses;

type
  TfFramePopedom = class(TUniFrame)
    PanelWork: TUniContainerPanel;
    UniToolBar1: TUniToolBar;
    BtnAdd: TUniToolButton;
    BtnEdit: TUniToolButton;
    BtnDel: TUniToolButton;
    UniToolButton4: TUniToolButton;
    BtnAddUser: TUniToolButton;
    BtnEditUser: TUniToolButton;
    BtnDelUser: TUniToolButton;
    BtnApply: TUniToolButton;
    UniToolButton11: TUniToolButton;
    UniSplitter1: TUniSplitter;
    PMenu1: TUniPopupMenu;
    N1: TUniMenuItem;
    N2: TUniMenuItem;
    N3: TUniMenuItem;
    N4: TUniMenuItem;
    N5: TUniMenuItem;
    N6: TUniMenuItem;
    N7: TUniMenuItem;
    UniSimplePanel1: TUniSimplePanel;
    Grid1: TUniStringGrid;
    UniSimplePanel2: TUniSimplePanel;
    TreeGroup: TUniTreeView;
    LabelHint: TUniLabel;
    BtnExit: TUniToolButton;
    PMenu2: TUniPopupMenu;
    N8: TUniMenuItem;
    procedure UniFrameCreate(Sender: TObject);
    procedure UniFrameDestroy(Sender: TObject);
    procedure Grid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N1Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure Grid1Click(Sender: TObject);
    procedure TreeGroupClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddUserClick(Sender: TObject);
    procedure BtnEditUserClick(Sender: TObject);
    procedure BtnDelUserClick(Sender: TObject);
    procedure BtnApplyClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure N8Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FDBType: TAdoConnectionType;
    {*��������*}
    FMenuID: string;
    FPopedom: string;
    FGroupSelected: Integer;
    FGroups: TPopedomGroupItems;
    //ȫ�ֱ���
    procedure OnLoadPopedom;
    procedure LoadGroupList(const nLoadPopedom: Boolean = False);
    procedure ClearGroupList;
    procedure BuildGroupTree(const nBuildPopedom: Boolean = False);
    procedure BuildPopedomGrid(const nQuery: TADOQuery);
    function GetItemByColumn(const nCol: Integer): string;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  Vcl.Grids, uniPageControl, MainModule, ULibFun, UFormBase, USysBusiness,
  UManagerGroup, UFormPopedomGroup, UFormPopedomUser, USysDB, USysFun;

const
  giID       = 0;
  giName     = 1;
  //grid info:�������������

procedure TfFramePopedom.UniFrameCreate(Sender: TObject);
var nInt: Integer;
    nIni: TIniFile;
begin
  LabelHint.Height := Grid1.DefaultRowHeight;
  FDBType := ctMain;
  FMenuID := GetMenuByModule(ClassName);

  FPopedom := GetPopedom(FMenuID);
  OnLoadPopedom; //����Ȩ��

  with Grid1 do
  begin
    FixedRows := 0;
    RowCount := 0;
    FixedCols := 1;
    ColCount := 0;

    ShowColumnTitles := True;
    Options := [goVertLine,goHorzLine,goColSizing,goFixedColClick];
  end;

  LoadGroupList(True);
  BuildGroupTree(True);
  //load data

  nIni := nil;
  try
    nIni := UserConfigFile;
    nInt := nIni.ReadInteger(ClassName, 'TreeGroup', 260);
    if nInt > 100 then
      TreeGroup.Width := nInt;
    //xxxxx

    UserDefineStringGrid(Name, Grid1, True, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFramePopedom.UniFrameDestroy(Sender: TObject);
var nIni: TIniFile;
begin
  ClearGroupList;
  //�������

  nIni := nil;
  try
    nIni := UserConfigFile;
    nIni.WriteInteger(ClassName, 'TreeGroup', TreeGroup.Width);
    UserDefineStringGrid(Name, Grid1, False, nIni);
  finally
    nIni.Free;
  end;
end;

//Desc: ��ȡȨ��
procedure TfFramePopedom.OnLoadPopedom;
begin
  BtnAdd.Enabled      := HasPopedom2(sPopedom_Add, FPopedom);
  BtnAddUser.Enabled  := HasPopedom2(sPopedom_Add, FPopedom);
  BtnEdit.Enabled     := HasPopedom2(sPopedom_Edit, FPopedom);
  BtnEditUser.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
  BtnDel.Enabled     := HasPopedom2(sPopedom_Delete, FPopedom);
  BtnDelUser.Enabled := HasPopedom2(sPopedom_Delete, FPopedom);

  BtnApply.Enabled    := HasPopedom2(sPopedom_Add, FPopedom) and
                         HasPopedom2(sPopedom_Edit, FPopedom);
  //˫Ȩ��
end;

procedure TfFramePopedom.BtnExitClick(Sender: TObject);
var nSheet: TUniTabSheet;
begin
  nSheet := Parent as TUniTabSheet;
  nSheet.Close;
end;

//------------------------------------------------------------------------------
//Desc: ����Ȩ�����б�
procedure TfFramePopedom.LoadGroupList(const nLoadPopedom: Boolean);
var nStr: string;
    nIdx,nInt: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    ClearGroupList;
    nQuery := LockDBQuery(FDBType);

    nStr := 'Select * From %s Where G_Flag like ''%%%s%%''';
    nStr := Format(nStr, [sTable_Group, sWebFlag]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(FGroups, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with FGroups[nIdx] do
        begin
          FID       := FieldByName('G_ID').AsString;
          FName     := FieldByName('G_NAME').AsString;
          FDesc     := FieldByName('G_DESC').AsString;

          FUser := nil;
          SetLength(FPopedom, 0);
        end;

        Inc(nIdx);
        Next;
      end;
    end;

    //--------------------------------------------------------------------------
    nStr := 'Select * From ' + sTable_Popedom;
    //Ȩ�ޱ�

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      for nIdx := Low(FGroups) to High(FGroups) do
      with FGroups[nIdx] do
      begin
        nInt := 0;
        First;

        while not Eof do
        begin
          if FieldByName('P_Group').AsString = FID then
            Inc(nInt);
          Next;
        end;

        SetLength(FPopedom, nInt);
        nInt := 0;
        First;

        while not Eof do
        begin
          if FieldByName('P_Group').AsString = FID then
          begin
            with FPopedom[nInt] do
            begin
              FItem := FieldByName('P_Item').AsString;
              FPopedom := FieldByName('P_Popedom').AsString;
            end;

            Inc(nInt);
          end;

          Next;
        end;
      end;
    end;    

    //--------------------------------------------------------------------------
    nStr := 'Select U_Name,U_Group From ' + sTable_User;
    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        nStr := FieldByName('U_Group').AsString;
        for nIdx := Low(FGroups) to High(FGroups) do
        with FGroups[nIdx] do
        begin
          if FID <> nStr then Continue;
          if not Assigned(FUser) then
            FUser := TStringList.Create;
          //xxxxx

          FUser.Add(FieldByName('U_Name').AsString);
          Break;
        end;

        Next;
      end;
    end;

    if nLoadPopedom then    
      BuildPopedomGrid(nQuery);
    //xxxxx
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Desc: ������б�
procedure TfFramePopedom.ClearGroupList;
var nIdx: Integer;
begin
  for nIdx := Low(FGroups)  to High(FGroups) do
  begin
    if Assigned(FGroups[nIdx].FUser) then
      FGroups[nIdx].FUser.Free;
    FGroups[nIdx].FUser := nil;
  end;

  FGroupSelected := -1;
  SetLength(FGroups, 0);
  LabelHint.Caption := '�����б�ѡ����,�༭����Ȩ.';
end;

//Desc: �������б�
procedure TfFramePopedom.BuildGroupTree(const nBuildPopedom: Boolean);
var nStr: string;
    i,nIdx: Integer;
    nItem,nChild: TuniTreeNode;

  procedure EnumChild(const nP: TuniTreeNode; const nLevel: Integer);
  begin
    nChild := nP.GetFirstChild;
    while Assigned(nChild) do
    begin
      Inc(nIdx);
      i := NativeInt(nChild.Data);

      Grid1.Cells[giID, nIdx] := gAllMenus[i].FMenuID;
      nStr := '|' + StringOfChar('-', 3 * nLevel) + gAllMenus[i].FTitle;
      Grid1.Cells[giName, nIdx] := nStr;

      if nChild.HasChildren then
        EnumChild(nChild, nLevel + 1);
      nChild := nChild.GetNextSibling;
    end;
  end;
begin
  TreeGroup.BeginUpdate;
  try
    if nBuildPopedom then
    begin
      TreeGroup.Items.Clear;  
      BuidMenuTree(TreeGroup, '');
      Grid1.RowCount := TreeGroup.Items.Count;

      nItem := TreeGroup.Items.GetFirstNode ;
      nIdx := 0;

      while Assigned(nItem) do
      begin
        i := NativeInt(nItem.Data);
        Grid1.Cells[giID, nIdx] := gAllMenus[i].FMenuID;
        Grid1.Cells[giName, nIdx] := gAllMenus[i].FTitle;

        if nItem.HasChildren then
          EnumChild(nItem, 1);
        nItem := nItem.GetNextSibling;

        if Assigned(nItem) then
          Inc(nIdx);
        //xxxxx
      end;
    end;

    TreeGroup.Items.Clear;
    for nIdx := Low(FGroups) to High(FGroups) do
    with FGroups[nIdx] do
    begin
      nItem := TreeGroup.Items.Add(nil, FName);
      nItem.Data := Pointer(nIdx+1);
      if not Assigned(FUser) then Continue;

      for i := 0 to FUser.Count-1 do
      begin
        nChild := TreeGroup.Items.Add(nItem, FUser[i]);
        nChild.Data := nil;
      end;
    end;
  finally
    TreeGroup.EndUpdate;
  end;
end;

//Desc: ����Ȩ����
procedure TfFramePopedom.BuildPopedomGrid(const nQuery: TADOQuery);
var nStr: string;
    nCol: TUniGridColumn;
begin
  Grid1.BeginUpdate;
  try
    Grid1.Columns.Clear;
    nCol := Grid1.Columns.Add as TUniGridColumn;
    with nCol do
    begin
      Title.Caption := 'ģ���ʶ';
      Width := 100;
    end;

    nCol := Grid1.Columns.Add as TUniGridColumn;
    with nCol do
    begin
      Title.Caption := 'ģ������';
      Width := 200;
    end;

    nStr := 'Select * From ' + sTable_PopItem;
    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        nCol := Grid1.Columns.Add as TUniGridColumn;
        with nCol do
        begin
          nStr := FieldByName('P_Name').AsString;
          Title.Caption := Format('%s[%s]', [nStr, FieldByName('P_ID').AsString]);
          Width := 92;
        end;

        Next;
      end;
    end;

    Grid1.ColCount := Grid1.Columns.Count;
    //ȫ������
  finally
    Grid1.EndUpdate;
  end;
end;

//Date: 2018-05-28
//Parm: ��
//Desc: ��ȡGrid.nCol�е�Ȩ����
function TfFramePopedom.GetItemByColumn(const nCol: Integer): string;
var nL,nR: Integer;
begin
  Result := Grid1.Columns[nCol].Title.Caption;
  nL := Pos('[', Result);
  nR := Pos(']', Result);

  if (nL > 1) and (nR > 1) and (nR > nL) then
       Result := Copy(Result, nL + 1, nR - nL - 1)
  else Result := '';
end;

//------------------------------------------------------------------------------
procedure TfFramePopedom.Grid1Click(Sender: TObject);
begin
  with Grid1 do
  begin
    if Col < 2 then Exit;
    //system col
    
    if Grid1.Cells[Col, Row] = sCheckFlag then
         Grid1.Cells[Col, Row] := ''
    else Grid1.Cells[Col, Row] := sCheckFlag;
  end;
end;

procedure TfFramePopedom.Grid1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, Grid1);
end;

//Desc: ȫ������
procedure TfFramePopedom.N1Click(Sender: TObject);
var nTag,nRow,nCol: Integer;
begin
  nTag := TComponent(Sender).Tag;
  Grid1.BeginUpdate;
  try
    for nRow := Grid1.RowCount - 1 downto 0 do
     for nCol := Grid1.ColCount - 1 downto 2 do
     begin
       case nTag of
        10: Grid1.Cells[nCol, nRow] := sCheckFlag;
        20: Grid1.Cells[nCol, nRow] := '';
        30:
         begin
           if Grid1.Cells[nCol, nRow] = sCheckFlag then
                Grid1.Cells[nCol, nRow] := ''
           else Grid1.Cells[nCol, nRow] := sCheckFlag;
         end;
       end;
     end;
  finally
    Grid1.EndUpdate;
  end;
end;

//Desc: �в���
procedure TfFramePopedom.N5Click(Sender: TObject);
var nTag,nRow: Integer;
begin
  if Grid1.Col < 2 then Exit;
  nTag := TComponent(Sender).Tag;

  Grid1.BeginUpdate;
  try
    for nRow := Grid1.RowCount - 1 downto 0 do
    begin
     case nTag of
      10: Grid1.Cells[Grid1.Col, nRow] := sCheckFlag;
      20: Grid1.Cells[Grid1.Col, nRow] := '';
      30:
       begin
         if Grid1.Cells[Grid1.Col, nRow] = sCheckFlag then
              Grid1.Cells[Grid1.Col, nRow] := ''
         else Grid1.Cells[Grid1.Col, nRow] := sCheckFlag;
       end;
     end;
    end;
  finally
    Grid1.EndUpdate;
  end;
end;

//Desc: ����ѡ�����Ȩ��
procedure TfFramePopedom.TreeGroupClick(Sender: TObject);
var nStr: string;
    i,nIdx,nRow,nCol: Integer;
begin
  if not (Assigned(TreeGroup.Selected) and
          Assigned(TreeGroup.Selected.Data)) then Exit;
  //invalid group
  
  FGroupSelected := NativeInt(TreeGroup.Selected.Data) - 1;
  with FGroups[FGroupSelected] do
  try
    LabelHint.Caption := Format('��ǰ��:[ %s ] ����:[ %s ]', [FName, FDesc]);
    N1Click(N2); //ȫ��ȡ��
    Grid1.BeginUpdate;

    for nIdx := Low(FPopedom) to High(FPopedom) do
    begin
      nRow := -1;
      for i := Grid1.RowCount-1 downto 0 do
      begin
        nStr := MakeMenuID('MAIN', Grid1.Cells[0, i]);
        if CompareText(nStr, FPopedom[nIdx].FItem) = 0 then
        begin
          nRow := i; Break;
        end;
      end;

      if nRow < 0 then Continue;
      //no match item

      for nCol := Grid1.ColCount-1 downto 2 do
      begin
        nStr := GetItemByColumn(nCol);
        if Pos(nStr, FPopedom[nIdx].FPopedom) > 0 then
          Grid1.Cells[nCol, nRow] := sCheckFlag;
        //xxxxx
      end;
    end;
  finally
    Grid1.EndUpdate;
  end;
end;

//Desc: �����
procedure TfFramePopedom.BtnAddClick(Sender: TObject);
begin
  ShowPopedomGroupForm('',
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      LoadGroupList(False);
      BuildGroupTree(False);
    end);
  //show form
end;

//Desc: �޸���
procedure TfFramePopedom.BtnEditClick(Sender: TObject);
begin
  if FGroupSelected < 0 then
  begin
    ShowMessage('��ѡ��Ҫ�༭����');
    Exit;
  end;

  ShowPopedomGroupForm(FGroups[FGroupSelected].FID,
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      LoadGroupList(False);
      BuildGroupTree(False);
    end);
  //show form
end;

//Desc: ɾ����
procedure TfFramePopedom.BtnDelClick(Sender: TObject);
var nStr: string;
    nQuery: TADOQuery;
begin
  if FGroupSelected < 0 then
  begin
    ShowMessage('��ѡ��Ҫɾ������');
    Exit;
  end;

  nStr := FGroups[FGroupSelected].FName;
  nStr := Format('ȷ��Ҫɾ������Ϊ[ %s ]������?', [nStr]);
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    begin
      if Res <> mrYes then Exit;
      //cancel

      nQuery := nil;
      try
        nQuery := LockDBQuery(FDBType);
        nStr := 'Select Count(*) From %s Where U_Group=%s';
        nStr := Format(nStr, [sTable_User, FGroups[FGroupSelected].FID]);

        with DBQuery(nStr, nQuery) do
        if Fields[0].AsInteger > 0 then
        begin
          nStr := '��������[ %d ]���û�,����ɾ��.';
          nStr := Format(nStr, [Fields[0].AsInteger]);
          ShowMessage(nStr);
          Exit;
        end;

        nStr := 'Select G_CANDEL From %s Where G_ID=%s';
        nStr := Format(nStr, [sTable_Group, FGroups[FGroupSelected].FID]);

        with DBQuery(nStr, nQuery) do
        if RecordCount > 0 then
        begin
          if Fields[0].AsInteger = 1 then
          begin
            ShowMessage('����Ա���ø��鲻����ɾ��');
            Exit;
          end;

          nStr := 'Delete From %s Where G_ID=%s';
          nStr := Format(nStr, [sTable_Group, FGroups[FGroupSelected].FID]);
          DBExecute(nStr, nQuery);

          LoadGroupList(False);
          BuildGroupTree(False);
        end;

        ShowMessage('�ѳɹ�ɾ����¼');
      finally
        ReleaseDBQuery(nQuery);
      end;
    end);
  //xxxxx
end;

//Desc: ����û�
procedure TfFramePopedom.BtnAddUserClick(Sender: TObject);
begin
  ShowPopedomUserForm('',
  procedure(const nResult: Integer; const nParam: PFormCommandParam)
  begin
    LoadGroupList(False);
    BuildGroupTree(False);
  end);
//show form
end;

//Desc: �޸��û�
procedure TfFramePopedom.BtnEditUserClick(Sender: TObject);
var nStr: string;
begin
  if Assigned(TreeGroup.Selected) and
     (not Assigned(TreeGroup.Selected.Data)) then
       nStr := TreeGroup.Selected.Text
  else nStr := '';

  if nStr = '' then
  begin
    ShowMessage('��ѡ��Ҫ�༭���û�');
    Exit;
  end;

  ShowPopedomUserForm(nStr,
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      LoadGroupList(False);
      BuildGroupTree(False);
    end);
  //show form
end;

//Desc: ɾ���û�
procedure TfFramePopedom.BtnDelUserClick(Sender: TObject);
var nStr,nID: string;
begin
  if Assigned(TreeGroup.Selected) and
     (not Assigned(TreeGroup.Selected.Data)) then
       nID := TreeGroup.Selected.Text
  else nID := '';

  if nID = '' then
  begin
    ShowMessage('��ѡ��Ҫ�༭���û�');
    Exit;
  end;

  nStr := Format('ȷ��Ҫɾ������Ϊ[ %s ]���û���?', [nID]);
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    begin
      if Res <> mrYes then Exit;
      //cancel

      nStr := 'Delete From %s Where U_Name=''%s''';
      nStr := Format(nStr, [sTable_User, nID]);
      DBExecute(nStr, nil, FDBType);

      LoadGroupList(False);
      BuildGroupTree(False);
    end);
  //xxxxx
end;

//Desc: ��Ȩ
procedure TfFramePopedom.BtnApplyClick(Sender: TObject);
var nStr,nP: string;
    nRow,nCol: Integer;
    nList: TStrings;
begin
  if FGroupSelected < 0 then
  begin
    ShowMessage('��ѡ��Ҫ��Ȩ����');
    Exit;
  end;

  nList := nil;
  try
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nStr := 'Delete From %s Where P_Group=%s';
    nStr := Format(nStr, [sTable_Popedom, FGroups[FGroupSelected].FID]);
    nList.Add(nStr); //clear all

    for nRow := 0 to Grid1.RowCount - 1 do
    begin
      nP := '';
      for nCol := 2 to Grid1.ColCount - 1 do
       if Grid1.Cells[nCol, nRow] = sCheckFlag then
        nP := nP + GetItemByColumn(nCol);
      if nP = '' then Continue; //no selected

      with TSQLBuilder do
      nStr := MakeSQLByStr([SF('P_Group', FGroups[FGroupSelected].FID, sfVal),
        SF('P_Item', MakeMenuID('MAIN', Grid1.Cells[giID, nRow])),
        SF('P_Popedom', nP)], sTable_Popedom, '', True);
      nList.Add(nStr);
    end;

    DBExecute(nList, nil, FDBType);
    LoadGroupList(False);
    BuildGroupTree(False);
    ShowMessage('��Ȩ�ɹ�');
  finally
    gMG.FObjectPool.Release(nList);
  end;
end;

//Desc: ������Ч
procedure TfFramePopedom.N8Click(Sender: TObject);
var nStr: string;
begin
  nStr := 'ȷ��Ҫ���������µ�Ȩ����?';
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    begin
      if Res <> mrYes then Exit;
      //cancel

      GlobalSyncLock;
      try
        LoadPopedomList(True);
        //����Ȩ���б�
      finally
        GlobalSyncRelease;
      end;

      ShowMessage('��Ȩ������Ч');
    end);
  //xxxxx
end;

initialization
  RegisterClass(TfFramePopedom);
end.
