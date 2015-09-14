unit AFelicaClient;

interface

uses
  Controls, AFelicaCardRW, SysUtils;

type
  TFelicaClientStatus = (FelicaClientStatusNone, FelicaClientStatusBarcode, FelicaClientStatusIDM);

  TFelicaClient = class
  private
    FIDM: String;
    FIDMModifiedTime: TDateTime;
    oCardRW: TCardRW;
    FBarcode: String;

    procedure SetBarcode(const Value: String);
    procedure SetIDM(const Value: String);

    function GetStatus: TFelicaClientStatus;

  public
    constructor Create;
    destructor Destroy; override;

  public
    procedure Reset;

    function GetIDM: Boolean;
    function RunWebTo(sIDM: String): Boolean;

  published
    property Barcode: String read FBarcode write SetBarcode;
    property IDM: String read FIDM write SetIDM;
    property IDMModifiedTime: TDateTime read FIDMModifiedTime;

    property Status: TFelicaClientStatus read GetStatus;
  end;

  function FelicaClient: TFelicaClient;

  procedure CloseFeliCaClient;

implementation

uses AFelicaReaderWnd;

var
  FFelicaClient: TFelicaClient;

function FelicaClient: TFelicaClient;
begin
  if Assigned(FFelicaClient) = False then
    FFelicaClient := TFelicaClient.Create;

  Result := FFelicaClient;
end;

procedure CloseFeliCaClient;
begin
  if Assigned(FFelicaClient) then
    FreeAndNil(FFelicaClient);
end;

{ TFelicaClient }

procedure TFelicaClient.SetBarcode(const Value: String);
begin
  FBarcode := Value;
  FIDM := '';
  FIDMModifiedTime  := Now;
end;

procedure TFelicaClient.SetIDM(const Value: String);
begin
  FBarcode := '';
  FIDM := Value;
  FIDMModifiedTime  := Now;
end;

function TFelicaClient.GetStatus: TFelicaClientStatus;
begin
  Result := FelicaClientStatusNone;

  if FBarcode <> '' then
    Result := FelicaClientStatusBarcode;

  if FIDM <> '' then
    Result := FelicaClientStatusIDM;
end;

constructor TFelicaClient.Create;
begin
  if not assigned(oCardRW) then begin
    oCardRW := TCardRW.Create;
    if oCardRW.LoadDLL('felica.dll') = false then begin
      FreeAndNil(oCardRW);
    end;
  end;
end;

destructor TFelicaClient.Destroy;
begin
  if assigned(oCardRW) then begin
    oCardRW.FreeCardRW;
    FreeAndNil(oCardRW);
  end;

  inherited;
end;

procedure TFelicaClient.Reset;
begin
  FBarcode := '';
  FIDM := '';
  FIDMModifiedTime  := 0;
end;

function TFelicaClient.GetIDM: Boolean;
var
  bRtn: Boolean;
begin
  bRtn := False;

  FelicaReaderWnd := TFelicaReaderWnd.Create(nil);
  FelicaReaderWnd.oCardRW := oCardRW;
  try
    FelicaReaderWnd.ShowModal;

    if FelicaReaderWnd.ModalResult = mrOK then begin
      IDM := FelicaReaderWnd.sBarcode;
      bRtn := true;
    end;
  finally
    FelicaReaderWnd.Free;
  end;

  Result := bRtn;
end;

function TFelicaClient.RunWebTo(sIDM: String): Boolean;
var
  bRtn: Boolean;
begin
  bRtn := false;

  try
    if assigned(oCardRW) then
      bRtn := oCardRW.RWPush(sIDM);
  finally
  end;

  Result := bRtn;
end;

end.
