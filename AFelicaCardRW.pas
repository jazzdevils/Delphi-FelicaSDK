unit AFelicaCardRW;

interface
Uses
  Windows, SysUtils, StrUtils, AFelicaType;

type
  TInputDumb = Record
    time_out: Integer;
    retry_count: Integer;
    lngCardCommandPacketData: Integer;
    lngCardCommandPacketLength: Integer;
  End;

  TOutputDumb = Record
    lngCardResponsePacketData: Integer;
    lngResponsePacketLength: Integer;
  End;

  TPolling = Record
    lngSystemCode : ^Byte;
    bytTimeSlot   : Byte;
  End;

  TCardInformation = Record
    lngCardIdm: ^Byte;
    lngCardPmm: ^Byte;
  End;

  TIDM_Info = Record
    ErrorMsg: String;
    sIDM: String;
    sPMM: String;
    mIDM: array[0..7] of Byte;
  End;

  TCardRW = class
    constructor Create;
    destructor Destroy; override;

  private
    hFelicaInstance: THandle;

    function InitializeLibrary: Boolean;							// ライブラリの初期化
//    function PreparePlugIn(sPath: String): Boolean;
    function OpenReaderWriterAuto: Boolean;
    function FreeDLL: Boolean;
    function CloseReaderWriter: Boolean;
    function DisposeLibrary: Boolean;
    function GetSiteUrl(sIDM: String): String;
    function GetCheckSum(Data: array of Byte): Short;
  public
    ErrorMsg: String;

	  function LoadDLL(dll_path: pAnsiChar): Boolean;  		// DLLの読み込み
    function GetIDM(var IDM_Info: TIDM_Info): Boolean;
    function RWPush(IDM_Info: TIDM_Info; Var sMobileUrl: String): Boolean; overload; //Mobile WebBrowser起動
    function RWPush(sIDM: String): Boolean; overload; //Mobile WebBrowser起動
    function FreeCardRW: Boolean;
  end;

  Tinitialize_library = function (): Boolean; cdecl;
  TSetPluginsHomeDirectory = function (sPath: Pointer): Boolean; cdecl;
  Topen_reader_writer_auto = function (): Boolean; cdecl;
  Tpolling_and_get_card_information = function (Const Polling: Pointer; CardNum: PUChar; CardInformation: Pointer): Boolean; cdecl;
  TClose_Reader_Writer = function (): Boolean; cdecl;
  TDispose_Library = function (): Boolean; cdecl;
  TReader_Writer_IS_Open = function (): Boolean; cdecl;
  TRW_Push = function (Const CardIDM: Pointer ; bSendDataLength: Byte; Const SendData: Pointer): Boolean; cdecl;
  TRW_Activate2 = function (Const CardIDM: Pointer; Const Action_flag: PUChar; Status: PuChar): Boolean; cdecl;

implementation

function TCardRW.CloseReaderWriter: Boolean;
var
  Close_Reader_Writer: TClose_Reader_Writer;
  bRtn: Boolean;
begin
  try
    if hFelicaInstance > 32 then begin
      @Close_Reader_Writer := GetProcAddress(hFelicaInstance, 'close_reader_writer');
      bRtn := Close_Reader_Writer;
    end
    else begin
      bRtn := false;
    end;
  except
    bRtn := false;
  end;

  Result := bRtn;
end;

constructor TCardRW.Create; 
begin
  inherited;
end;

destructor TCardRW.Destroy;
begin
//  FreeCardRW;
  FreeDLL;

  inherited;
end;

function TCardRW.DisposeLibrary: Boolean;
var
  Dispose_Library: TDispose_Library;
  bRtn: Boolean;
begin
  try
    if hFelicaInstance > 32 then begin
      @Dispose_Library := GetProcAddress(hFelicaInstance, 'dispose_library');
      bRtn := Dispose_Library;
    end
    else begin
      bRtn := false;
    end;
  except
    bRtn := false;
  end;

  Result := bRtn;
end;

function TCardRW.FreeCardRW: Boolean;
begin
  if CloseReaderWriter = true then
    DisposeLibrary;

  Result := true;  
end;

function TCardRW.FreeDLL: Boolean;
begin
  if hFelicaInstance > 32 then
    freeLibrary(hFelicaInstance);

  Result := true;  
end;

function TCardRW.GetCheckSum(Data: array of Byte): Short;
var
  i: Integer;
  iSum: Short;
begin
  iSum := 0;
  for i := 0 to High(Data) do begin
    iSum := iSum + Data[i];
  end;

  Result := iSum;
end;

function TCardRW.GetIDM(var IDM_Info: TIDM_Info): Boolean;
var
  Polling: TPolling;
  CardInformation: TCardInformation;
  polling_and_get_card_information: Tpolling_and_get_card_information;
  SystemCode: array[0..1] of Byte;
  CardNum: Byte;
  aIDM: array[0..7] of Byte;
  aPMM: array[0..7] of Byte;     

  i:Integer;
  bRtn: Boolean;
begin
  bRtn := false;

  SystemCode[0] := 255;//Byte($ff);
  SystemCode[1] := 255;//Byte($ff);

  Polling.lngSystemCode := @SystemCode;
  Polling.bytTimeSlot := 0; //Byte($00);
  CardNum := 0; //Byte($00);

  CardInformation.lngCardIdm := @aIDM;
  CardInformation.lngCardPmm := @aPMM;

  try
    @polling_and_get_card_information := GetProcAddress(hFelicaInstance, 'polling_and_get_card_information');

    if polling_and_get_card_information(@Polling, @CardNum, @CardInformation) = true then begin
      bRtn := true;

      IDM_Info.ErrorMsg := '';

      for i := 0 to High(aIDM) do begin
        IDM_Info.sIDM := IDM_Info.sIDM + IntToHex(aIDM[i], 2);
        IDM_Info.sPMM := IDM_Info.sPMM + IntToHex(aPMM[i], 2);
      end;
    end;
  except
    begin
      bRtn := false;
      ErrorMsg := '携帯電話の情報取得に失敗しました。(polling_and_get_card_information)';
    end;
  end;

  Result := bRtn;
end;

function TCardRW.GetSiteUrl(sIDM: String): String;
var
  oFelicaMember: TFelicaMember;
  sRtn: String;
begin
  oFelicaMember := TFelicaMember.Create;
  try
    sRtn := oFelicaMember.SetWebToParam(sIDM);
  finally
    oFelicaMember.Free;
  end;

  Result := sRtn;
end;

function TCardRW.InitializeLibrary: Boolean;
var
  initialize_library: Tinitialize_library;
  bRtn: Boolean;
begin
  try
    if hFelicaInstance > 32 then begin
      @initialize_library := GetProcAddress(hFelicaInstance, 'initialize_library');
      bRtn := initialize_library;
    end
    else begin
      bRtn := false;
    end;
  except
    bRtn := false;
  end;

  Result := bRtn;
end;

//function TCardRW.PreparePlugIn(sPath: String): Boolean;
//var
//  Initialize_PlugIn: TInitialize_PlugIn;
//  SetPluginsHomeDirectory: TSetPluginsHomeDirectory;
//  bRtn: Boolean;
//begin
//  try
//    @SetPluginsHomeDirectory := GetProcAddress(hFelicaInstance, 'set_plugins_home_directory');
//    bRtn := SetPluginsHomeDirectory(PChar(spath));
//    if bRtn = true then begin
//      @Initialize_PlugIn := GetProcAddress(hFelicaInstance, 'initialize_plugins');
//      bRtn := Initialize_PlugIn;
//    end;
//  except
//    bRtn := false;
//  end;
//
//  Result := true;//bRtn;
//end;

function TCardRW.LoadDLL(dll_path: pAnsiChar): Boolean;
var
  bRtn: boolean;
begin
  try
    hFelicaInstance := LoadLibrary(dll_path);

    if hFelicaInstance >= 32 then begin
      bRtn := InitializeLibrary;

      if bRtn = true then
        bRtn := OpenReaderWriterAuto;
    end
    else
      raise Exception.Create('');
  except
    begin
      bRtn := false;
      freeLibrary(hFelicaInstance);
    end;
  end;

  Result := bRtn;
end;

function TCardRW.OpenReaderWriterAuto: Boolean;
var
  open_reader_writer_auto: Topen_reader_writer_auto;
  bRtn: Boolean;
begin
  try
    if hFelicaInstance > 32 then begin
      @open_reader_writer_auto := GetProcAddress(hFelicaInstance, 'open_reader_writer_auto');
      bRtn := open_reader_writer_auto;
    end
    else begin
      bRtn := false;
    end;
  except
    bRtn := false;
  end;

  Result := bRtn;
end;

function TCardRW.RWPush(sIDM: String): Boolean;
var
  RW_Push: TRW_Push;
  RW_Activate2: TRW_Activate2;
  IDM: array[0..7] of Byte;
  Status, ActionFlag: Byte;
  SndData: array of Byte;
  UrlLength: Byte;
  bRtn: Boolean;
  i, inx: Integer;
  sTmp, sUrl: String;
  dSum: Short;
  SumH, SumL: Byte;
begin
  try
    i := 1;
    inx := 0;
    while i <= Length(sIDM) - 1 do begin
      sTmp := sIDM[i] + sIDM[i + 1];
      IDM[inx] := StrToInt('$' + sTmp);
      inc(inx);
      i := i + 2;
    end;

    sUrl := GetSiteUrl(sIDM);
    UrlLength := Length(sUrl);
    SetLength(SndData, UrlLength + 8);
    SndData[0] := 1; //$01;         //header
    SndData[1] := 2; //$02;         //Browser起動
    SndData[2] := Length(sUrl) + 2; //Length include(URL + Length(SndData[0]) + Length(SndData[0])
    SndData[3] := 0; //$00;
    SndData[4] := Length(sUrl);     //Length Url
    SndData[5] := 0; //$00;
    Move(sUrl[1], SndData[6], Length(sUrl));

    dSum := GetCheckSum(SndData);
    dSum := $10000 - dSum;
    SumH := $FF and (dSum Shr 8);
    SumL := $FF and dSum;

    SndData[Length(sUrl) + 6] := SumH;
    SndData[Length(sUrl) + 7] := SumL;

    @RW_Push := GetProcAddress(hFelicaInstance, 'rw_push');
    bRtn := RW_Push(@IDM[0], High(SndData) + 1, @SndData[0]);
    if bRtn = true then begin
      ActionFlag := byte($00);

      @RW_Activate2 := GetProcAddress(hFelicaInstance, 'rw_activate_2');
      bRtn := RW_Activate2(@IDM[0], @ActionFlag, @Status);
    end;
  except
    bRtn := false;
  end;

  Result := bRtn;
end;

function TCardRW.RWPush(IDM_Info: TIDM_Info; Var sMobileUrl: String): Boolean;
var
  RW_Push: TRW_Push;
  RW_Activate2: TRW_Activate2;
  IDM: array[0..7] of Byte;
  Status, ActionFlag: Byte;
  SndData: array of Byte;
  UrlLength: Byte;
  bRtn: Boolean;
  i, inx: Integer;
  sIDM, sTmp, sUrl: String;
  dSum: Short;
  SumH, SumL: Byte;
begin
  try
    i := 1;
    inx := 0;
    while i <= Length(IDM_Info.sIDM) - 1 do begin
      sTmp := IDM_Info.sIDM[i] + IDM_Info.sIDM[i + 1];
      sIDM := sIDM + IntToStr(StrToInt('$' + sTmp));
      IDM[inx] := StrToInt('$' + sTmp);
      inc(inx);
      i := i + 2;
    end;

    sUrl := GetSiteUrl(IDM_Info.sIDM);
    UrlLength := Length(sUrl);
    SetLength(SndData, UrlLength + 8);
    SndData[0] := 1; //$01;         //header
    SndData[1] := 2; //$02;         //Browser起動
    SndData[2] := Length(sUrl) + 2; //Length include(URL + Length(SndData[0]) + Length(SndData[0])
    SndData[3] := 0; //$00;
    SndData[4] := Length(sUrl);     //Length Url
    SndData[5] := 0; //$00;
    Move(sUrl[1], SndData[6], Length(sUrl));

    dSum := GetCheckSum(SndData);
    dSum := $10000 - dSum;
    SumH := $FF and (dSum Shr 8);
    SumL := $FF and dSum;

    SndData[Length(sUrl) + 6] := SumH;
    SndData[Length(sUrl) + 7] := SumL;

    @RW_Push := GetProcAddress(hFelicaInstance, 'rw_push');
    bRtn := RW_Push(@IDM[0], High(SndData) + 1, @SndData[0]);
    if bRtn = true then begin
      ActionFlag := byte($00);
      sMobileUrl := sUrl;

      @RW_Activate2 := GetProcAddress(hFelicaInstance, 'rw_activate_2');
      bRtn := RW_Activate2(@IDM[0], @ActionFlag, @Status);
    end;
  except
    bRtn := false;
  end;

  Result := bRtn;
end;

end.
