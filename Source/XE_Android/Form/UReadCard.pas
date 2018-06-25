unit UReadCard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UAndroidFormBase, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts;

type
  TFrmReadCard = class(TfrmFormBase)
    Label1: TLabel;
    EditCardNO: TEdit;
    BtnOK: TSpeedButton;
    BtnCancel: TSpeedButton;
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowTagID(const nTagID: string);
  end;

var
  FrmReadCard: TFrmReadCard;

implementation

uses
  UNFCManager,FMX.Helpers.Android,Androidapi.Helpers,

  UMainFrom,UShowOrderInfo;

{$R *.fmx}

procedure TFrmReadCard.BtnCancelClick(Sender: TObject);
begin
  inherited;
  EditCardNO.Text := '';
  MainForm.Show;
end;

procedure TFrmReadCard.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  nStr := Trim(EditCardNO.Text);
  if nStr='' then Exit;

  gCardNO := nStr;

  if not Assigned(FrmShowOrderInfo) then
    FrmShowOrderInfo := TFrmShowOrderInfo.Create(nil);
  FrmShowOrderInfo.Show;
end;

procedure TFrmReadCard.FormActivate(Sender: TObject);
begin
  inherited;
  EditCardNO.Text := '';

  with gNFCManager do
  begin
    if HasNFC then
    begin
      DoNFCReceived(SharedActivity.getIntent);
    end else ShowMessage('�豸��NFC����');
  end;
end;

procedure TFrmReadCard.FormCreate(Sender: TObject);
begin
  inherited;
  with gNFCManager do
  begin
    if not HasNFC then raise Exception.Create('�豸��NFC����');
    if not IsNFCEnabled then //raise Exception.Create('����ϵͳ�����п���NFC����');
      SetNFCEnabled;

    ShowTagIDEvent := ShowTagID;
  end;
end;

procedure TFrmReadCard.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  {if Key = vkHardwareBack then//������������ؼ�
  begin
    MessageDlg('ȷ���˳���', System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbOK, System.UITypes.TMsgDlgBtn.mbCancel], -1,

      procedure(const AResult: TModalResult)
      begin
        if AResult = mrOK then BtnCancelClick(Self);
      end
      );
      //�˳�����

    Key := 0;//����ģ���Ȼ����Ҳ���˳�
    Exit;
  end;  }
end;

procedure TFrmReadCard.ShowTagID(const nTagID: string);
begin
  EditCardNO.Text := nTagID;
end;

end.
