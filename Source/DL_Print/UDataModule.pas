{*******************************************************************************
  ����: dmzn@163.com 2012-5-3
  ����: ����ģ��
*******************************************************************************}
unit UDataModule;

interface

uses
  SysUtils, Classes, DB, ADODB, USysLoger;

type
  TFDM = class(TDataModule)
    ADOConn: TADOConnection;
    SQLQuery1: TADOQuery;
    SQLTemp: TADOQuery;
    Qry_1: TADOQuery;
    Qry_OPer: TADOQuery;
  private
    { Private declarations }
  public
    { Public declarations }
    function SQLQuery(const nSQL: string; const nQuery: TADOQuery): TDataSet;
    //��ѯ���ݿ�
    function QuerySQL(const nSQL: string; const nUseBackdb: Boolean = False): TDataSet;
    function ExecuteSQL(const nSQL: string): integer;
    {*ִ��д����*}
  end;

var
  FDM: TFDM;

implementation

{$R *.dfm}

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TFDM, '����ģ��', nEvent);
end;

//Date: 2012-5-3
//Parm: SQL;�Ƿ񱣳�����
//Desc: ִ��SQL���ݿ��ѯ
function TFDM.SQLQuery(const nSQL: string; const nQuery: TADOQuery): TDataSet;
var nInt: Integer;
begin
  Result := nil;
  nInt := 0;

  while nInt < 2 do
  try
    if not ADOConn.Connected then
      ADOConn.Connected := True;
    //xxxxx

    with nQuery do
    begin
      Close;
      SQL.Text := nSQL;
      Open;
    end;

    Result := nQuery;
    Exit;
  except
    on E:Exception do
    begin
      ADOConn.Connected := False;
      Inc(nInt);
      WriteLog(E.Message);
    end;
  end;
end;

function TFDM.QuerySQL(const nSQL: string;
  const nUseBackdb: Boolean): TDataSet;
var nInt: Integer;
begin
  Result := nil;
  nInt := 0;

  while nInt < 2 do
  try
    if not ADOConn.Connected then
      ADOConn.Connected := True;
    //xxxxx

    SQLQuery1.Close;
    SQLQuery1.SQL.Text := nSQL;
    SQLQuery1.Open;

    Result := SQLQuery1;
    Exit;
  except
    ADOConn.Connected := False;
    Inc(nInt);
  end;
end;

//Desc: ִ��nSQLд����
function TFDM.ExecuteSQL(const nSQL: string): integer;
var nStep: Integer;
begin
  Result := -1;
  nStep := 0;
  
  while nStep <= 2 do
  try
    Qry_OPer.Close;
    Qry_OPer.SQL.Text := nSQL;
    Result := Qry_OPer.ExecSQL;

    Break;
  except
    on E:Exception do
    begin
      Inc(nStep);
      WriteLog(E.Message+' SQl:'+ nSQL);
      raise Exception.Create(E.Message);
    end;
  end;
end;


end.
