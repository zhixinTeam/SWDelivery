unit UfrmViewReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, USysBusiness,
  Controls, Forms, Dialogs, uniGUITypes, uniGUIAbstractClasses, UFormBase,
  uniGUIClasses, uniGUIForm, uniButton, uniGUIBaseClasses, uniURLFrame,
  ServerModule;

type
  TfrmViewReport = class(TfFormBase)
    UniURLFrame1: TUniURLFrame;
  private
    { Private declarations }
    FPDFUrl : string;
  private
    procedure SetURLFrameURL(nUrl: string);
  public
    { Public declarations }
    ID, RepName: string;
  public
    property ReportPDfUrl: string read FPDFUrl write SetURLFrameURL;
  end;

  TFormViewReportResult = procedure (const nRe: Boolean) of object;
  //结果回调

procedure ShowViewReportForm(const nPDFDir: string;
  const nResult: TFormViewReportResult);


implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication;


procedure ShowViewReportForm(const nPDFDir: string; const nResult: TFormViewReportResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfrmViewReport', True);
  if not Assigned(nForm) then Exit;
  try
    with nForm as TfrmViewReport do
    begin
      SetURLFrameURL(nPDFDir);
      //load data

      ShowModal(
        procedure(Sender: TComponent; Result:Integer)
        begin
          nResult(True);
        end);
    end;
  finally
  end;
end;

//function frmViewReport: TfrmViewReport;
//begin
//  Result := TfrmViewReport(UniMainModule.GetFormInstance(TfrmViewReport));
//end;

procedure TfrmViewReport.SetURLFrameURL(nUrl: string);
begin
  FPDFUrl:= nUrl;
  UniURLFrame1.URL := nUrl;
end;

initialization
  RegisterClass(TfrmViewReport);

end.
