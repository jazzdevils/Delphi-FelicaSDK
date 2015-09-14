unit AFelicaReaderWnd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AdvGlassButton, StdCtrls, GradientLabel, Patterns, AFelicaCardRW,
  ExtCtrls, MMSystem;

type
  TFelicaReaderWnd = class(TForm)
    GradientLabel1: TGradientLabel;
    Label13: TLabel;
    ctlCancelButton: TAdvGlassButton;
    Timer1: TTimer;
    procedure ctlCancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }


    procedure WriteFelicaLogs(sType, sData: String);
    function PrepareCardRW: Boolean;
  public
    { Public declarations }
    oCardRW: TCardRW;
    sBarcode: String;
  end;

  CFelicaReaderWnd = class(TController)
  protected
    procedure DoCommand(Command: string; const args: TObject); override;

  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  FelicaReaderWnd: TFelicaReaderWnd;

implementation
Uses
  ACommandListUnit, AMember, AFelicaType;

{$R *.dfm}

{ CFelicaReaderWnd }

constructor CFelicaReaderWnd.Create;
begin
  inherited
end;

destructor CFelicaReaderWnd.Destroy;
begin
  inherited
end;

procedure CFelicaReaderWnd.DoCommand(Command: string; const args: TObject);
var
  oMember: TMember;
begin
  //SaleWnd1
  if Command = CMD_CALL_FELICA_READER then begin
    FelicaReaderWnd := TFelicaReaderWnd.Create(nil);
    try
      FelicaReaderWnd.ShowModal;
      if FelicaReaderWnd.ModalResult = mrOK then begin
        oMember := TMember.Create;
        oMember.Barcode := FelicaReaderWnd.sBarcode;
        ControlCenter.SendCommand(CMD_GET_BARCODE_FELICA_READER, oMember);
      end;
    finally
      FelicaReaderWnd.Free;
    end;
  end;
  //AMembersAddWnd1
  if Command = CMD_CALL_FELICA_READER_FOR_MEM then begin
    FelicaReaderWnd := TFelicaReaderWnd.Create(nil);
    try
      FelicaReaderWnd.ShowModal;
      if FelicaReaderWnd.ModalResult = mrOK then begin
        oMember := TMember.Create;
        oMember.Barcode := FelicaReaderWnd.sBarcode;
        ControlCenter.SendCommand(CMD_GET_BARCODE_FELICA_READER_FOR_MEM, oMember);
      end;
    finally
      FelicaReaderWnd.Free;
    end;
  end;
end;

procedure TFelicaReaderWnd.ctlCancelButtonClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFelicaReaderWnd.FormShow(Sender: TObject);
begin
  Timer1.Enabled := false;
  
  if PrepareCardRW = true then begin
    Label13.Caption := 'Felicaリーダーにて、読込処理を行って下さい。';
    Timer1.Enabled := true;
  end
  else begin
    Label13.Caption := 'Felicaリーダーが認識できませんでした。';
  end;
end;

function TFelicaReaderWnd.PrepareCardRW: Boolean;
var
  bRtn: Boolean;
begin
  bRtn := true;

  if not assigned(oCardRW) then begin
    oCardRW := TCardRW.Create;
    try
      bRtn := oCardRW.LoadDLL('felica.dll');
    except
      bRtn := false;
    end;
  end;

  Result := bRtn;
end;

procedure TFelicaReaderWnd.Timer1Timer(Sender: TObject);
var
  IDM_Info: TIDM_Info;
  sMobileUrl: String;

  function GetSoundFile: String;
  begin
    Result := ExtractFilePath(Application.ExeName) + 'bell.wav';
  end;
begin
  if assigned(oCardRW) then begin
    if oCardRW.GetIDM(IDM_Info) = true then begin
      Timer1.Enabled := false;
      FelicaReaderWnd.Caption := 'IDM: ' + IDM_Info.sIDM + '   ' + 'PMM: ' + IDM_Info.sPMM;
      PlaySound(PChar(GetSoundFile),0,SND_ASYNC or SND_NODEFAULT or SND_FILENAME);
      sBarcode := IDM_Info.sIDM;
      WriteFelicaLogs('RWPush', sMobileUrl); //log
      ModalResult := mrOK;
    end;
  end;
end;

procedure TFelicaReaderWnd.WriteFelicaLogs(sType, sData: String);
var
  oFelicaMember: TFelicaMember;
begin
  oFelicaMember := TFelicaMember.Create;
  try
    oFelicaMember.WriteFelicaLog(sType, sData);
  finally
    oFelicaMember.Free;
  end;
end;

initialization
  ControlCenter.RegController(CFelicaReaderWnd.Create);
end.

