unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdCustomHTTPServer,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdHTTPServer, Server.Runner,
  Vcl.StdCtrls, IdTCPConnection, IdTCPClient, IdHTTP, IdAuthentication,
  Vcl.ExtCtrls, Vcl.Mask, Registry, System.UITypes, IdHashMessageDigest,
  System.JSON;

type
  THCIAwsSecManCli = class(TForm)
    IdHTTP1: TIdHTTP;
    Timer1: TTimer;
    MaskEdit1: TMaskEdit;
    Label1: TLabel;
    ButtonSalvar: TButton;
    ButtonTeste: TButton;
    ButtonAtualizacao: TButton;
    IdHTTPServer1: TIdHTTPServer;

    procedure FormCreate(ASender: TObject);
    function GetUpdateVersion(): string;
    procedure DoUpdate();
    procedure Timer1Fired(Sender: TObject);
    procedure ButtonSalvarClick(Sender: TObject);
    procedure SaveToRegistry(keyToSave: string; valueToSave: string);
    function ReadFromRegistry(KeyName: string): string;
    function isCNPJ(CNPJ: string): boolean;
    function MD5(const texto: string): string;
    function DateTimeToStrUs(dt: TDatetime): string;
    procedure ButtonAtualizacaoClick(Sender: TObject);
    function DownloadUpdate(RemoteVersion: String): boolean;
    function RunCommand(const ACommand, AParameters: String): String;
    function AccessServerTest(CNPJ: String): String;
    function AccessServer(CNPJ: String; Hash: String): String;
    procedure ButtonTesteClick(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure DoUpdateAccess();

  private

  public
    class var RegistryKey: String;
    class var RegistryKeyToRead: String;
    class var AppVersion: String;
    class var AppPath: String;
    class var AppCNPJ: String;
    class var URLS3Version: String;
    class var URLS3Exe: String;
    class var ExeName: String;
    class var URLServicoAWSSecManTeste: String;
    class var URLServicoAWSSecMan: String;

  end;

var
  HCIAwsSecManCli: THCIAwsSecManCli;

implementation

{$R *.dfm}

procedure THCIAwsSecManCli.FormCreate(ASender: TObject);
var
  hashClient: string;
  timeStamp: string;
  AppVersionRegistry: string;
begin

  RegistryKey := 'SOFTWARE\HCISISTEMAS\AWSSECMAN\';

{$IFDEF WIN32}
  RegistryKeyToRead := 'SOFTWARE\WOW6432Node\HCISISTEMAS\AWSSECMAN';
{$ENDIF$}
{$IFDEF WIN64}
  RegistryKeyToRead := RegistryKey;
{$ENDIF}
  AppPath := ReadFromRegistry('AppPath');

  // AppPath := 'c:\Users\jpmonoo\Documents\reps\hci_aws_sec_manager_clients\';

  if (AppPath.IsEmpty) then
  begin
    SaveToRegistry('AppPath', ExtractFilePath(Application.ExeName));
    AppPath := ExtractFilePath(Application.ExeName);
  end;

  AppVersionRegistry := ReadFromRegistry('AppVersion');

  if (AppVersionRegistry.IsEmpty) then
  begin
    SaveToRegistry('AppVersion', '0');
    AppVersion := '0';
  end
  else
    AppVersion := AppVersionRegistry;

  AppCNPJ := ReadFromRegistry('Numerocnpj');

  MaskEdit1.Text := AppCNPJ;

  hashClient := ReadFromRegistry('hashClient');

  if (hashClient.IsEmpty) then
  begin
    timeStamp := DateTimeToStrUs(now);
    hashClient := MD5(timeStamp);
    SaveToRegistry('hashClient', hashClient);
  end;

  if not RunningAsService then
  else
  begin
    Timer1.Interval := 5000;
    Timer1.Enabled := true;
  end;

end;

procedure THCIAwsSecManCli.DoUpdateAccess();
begin
  AccessServer(ReadFromRegistry('Numerocnpj'), ReadFromRegistry('hashClient'));
  DoUpdate();

end;

procedure THCIAwsSecManCli.Timer1Fired(Sender: TObject);

begin
  Timer1.Enabled := false;
  try
    try
      DoUpdateAccess();
    except

    end;
  finally
    Timer1.Interval := 5000;
    Timer1.Enabled := true;
  end;
end;

procedure THCIAwsSecManCli.ButtonAtualizacaoClick(Sender: TObject);
begin

  if not RunningAsService then
    Screen.Cursor := crHourglass;

  DoUpdateAccess();

  if not RunningAsService then
    Screen.Cursor := crDefault;
end;

procedure THCIAwsSecManCli.ButtonSalvarClick(Sender: TObject);
var
  CpnjDigitado: String;
  CpnjSalvo: String;
begin

  CpnjDigitado := MaskEdit1.Text;

  if (CpnjDigitado.Trim.IsEmpty) then
  begin
    MessageDlg('Digite o CNPJ e clique em Salvar', mtError, mbOKCancel, 0);
    Exit();
  end;

  if not(isCNPJ(CpnjDigitado.Trim)) then
  begin
    MessageDlg('Digite um CNPJ valido e clique em Salvar', mtError,
      mbOKCancel, 0);
    Exit();
  end;

  SaveToRegistry('Numerocnpj', CpnjDigitado);

  CpnjSalvo := ReadFromRegistry('Numerocnpj');

  if not(CpnjSalvo.Equals(CpnjDigitado)) then
  begin
    MessageDlg('Não foi possivel salvar a chave no registro. [' + CpnjDigitado +
      ']', mtError, mbOKCancel, 0);
    Exit();
  end
  else
  begin
    MessageDlg('CNPJ salvo com sucesso no registro.', mtInformation,
      mbOKCancel, 0);
    Exit();
  end;

end;

procedure THCIAwsSecManCli.ButtonTesteClick(Sender: TObject);
begin
  AccessServerTest(ReadFromRegistry('Numerocnpj'));
end;

procedure THCIAwsSecManCli.DoUpdate();
var
  RemoteVersion: String;
begin

  try
    try

      RemoteVersion := GetUpdateVersion();

      if not(RemoteVersion.Equals(AppVersion)) then
      begin
        if (DownloadUpdate(RemoteVersion)) then
        begin
          RenameFile(AppPath + ExeName, AppPath + ExeName + '_' + AppVersion);

          RenameFile(AppPath + ExeName + '_' + RemoteVersion,
            AppPath + ExeName);

          AppVersion := RemoteVersion;

          SaveToRegistry('AppVersion', AppVersion);

          if RunningAsService then
            RunCommand('powershell.exe',
              '-NonInteractive -ExecutionPolicy Unrestricted -command "Restart-Service HCIAwsSecManagerClients -Force"');

        end;
      end;

    except

    end;

  finally

  end;

end;

function THCIAwsSecManCli.DownloadUpdate(RemoteVersion: String): boolean;
var
  fileDownload: TFileStream;
  lURL: String;
begin
  try

    try

      fileDownload := TFileStream.Create(AppPath + ExeName + '_' +
        RemoteVersion, fmCreate);

      lURL := URLS3Exe + ExeName;
      IdHTTP1.Get(lURL, fileDownload);

      Result := true;
    except
      Result := false;
    end;

  finally
    FreeAndNil(fileDownload);

  end;
end;

function THCIAwsSecManCli.GetUpdateVersion(): string;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  RemoteVersion: String;
begin

  lResponse := TStringStream.Create('');

  try
    try

      lURL := URLS3Version;
      IdHTTP1.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);

      RemoteVersion := JSonValue.GetValue<string>('version');

      Result := RemoteVersion;

      JSonValue.Free;

    except

    end;

  finally
    lResponse.Free();

  end;

end;

procedure THCIAwsSecManCli.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin

  try
    AResponseInfo.ContentText := ReadFromRegistry('AppVersion');
  except

  end;

end;

function THCIAwsSecManCli.AccessServerTest(CNPJ: String): String;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  RetornoChamada: String;

begin

  lResponse := TStringStream.Create('');
  try
    try

      Screen.Cursor := crHourglass;

      lURL := URLServicoAWSSecManTeste + CNPJ;
      IdHTTP1.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);

      RetornoChamada := JSonValue.GetValue<string>('response');
      JSonValue.Free;

      if (RetornoChamada.Equals('true')) then
        MessageDlg('Teste efetuado com sucesso. CNPJ é válido.', mtInformation,
          mbOKCancel, 0)
      else
        MessageDlg('Teste falhou. CNPJ não é válido. [' + CNPJ + ']', mtError,
          mbOKCancel, 0);

    except
      MessageDlg('Teste falhou', mtError, mbOKCancel, 0);
    end;

  finally
    Screen.Cursor := crDefault;
    lResponse.Free();

  end;

end;

function THCIAwsSecManCli.AccessServer(CNPJ: String; Hash: String): String;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
begin

  lResponse := TStringStream.Create('');
  try
    try
      lURL := URLServicoAWSSecMan + CNPJ + '/hash/' + Hash;
      IdHTTP1.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);

      JSonValue.Free;

      if not RunningAsService then
        MessageDlg('Atualização de IP efetuada com sucesso', mtInformation,
          mbOKCancel, 0);

    except

      if not RunningAsService then
        MessageDlg('Erro executando atualização de IP', mtError, mbOKCancel, 0);
    end;

  finally
    lResponse.Free();

  end;

end;


// ####################################################################################

function THCIAwsSecManCli.RunCommand(const ACommand,
  AParameters: String): String;
const
  CReadBuffer = 2400;
var
  saSecurity: TSecurityAttributes;
  hRead: THandle;
  hWrite: THandle;
  suiStartup: TStartupInfo;
  piProcess: TProcessInformation;
  pBuffer: array [0 .. CReadBuffer] of AnsiChar;
  dRead: DWord;
  dRunning: DWord;
  Retorno: String;
begin
  Retorno := '';
  saSecurity.nLength := SizeOf(TSecurityAttributes);
  saSecurity.bInheritHandle := true;
  saSecurity.lpSecurityDescriptor := nil;

  if CreatePipe(hRead, hWrite, @saSecurity, 0) then
  begin
    FillChar(suiStartup, SizeOf(TStartupInfo), #0);
    suiStartup.cb := SizeOf(TStartupInfo);
    suiStartup.hStdInput := hRead;
    suiStartup.hStdOutput := hWrite;
    suiStartup.hStdError := hWrite;
    suiStartup.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    suiStartup.wShowWindow := SW_HIDE;

    if CreateProcess(nil, PChar(ACommand + ' ' + AParameters), @saSecurity,
      @saSecurity, true, NORMAL_PRIORITY_CLASS, nil, nil, suiStartup, piProcess)
    then
    begin
      repeat
        dRunning := WaitForSingleObject(piProcess.hProcess, 100);
        Application.ProcessMessages();
        repeat
          dRead := 0;
          ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);
          pBuffer[dRead] := #0;

          OemToAnsi(pBuffer, pBuffer);
          Retorno := Retorno + String(pBuffer);
        until (dRead < CReadBuffer);
      until (dRunning <> WAIT_TIMEOUT);
      CloseHandle(piProcess.hProcess);
      CloseHandle(piProcess.hThread);
    end;

    CloseHandle(hRead);
    CloseHandle(hWrite);

    Result := Retorno;
  end;
end;

procedure THCIAwsSecManCli.SaveToRegistry(keyToSave: string;
  valueToSave: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    { Define a chave-raiz do registro }
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    { Abre a chave (path). Se não existir, cria e abre. }
    Reg.OpenKey(RegistryKey, true);
    { Escreve uma string }
    Reg.WriteString(keyToSave, valueToSave);

  finally
    Reg.Free;
  end;
end;

function THCIAwsSecManCli.ReadFromRegistry(KeyName: string): string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.KeyExists(RegistryKey) then
    begin
      Reg.OpenKey(RegistryKey, false);

      if Reg.ValueExists(KeyName) then
        Result := Reg.ReadString(KeyName);

    end
  finally
    Reg.Free;
  end;

end;

function THCIAwsSecManCli.isCNPJ(CNPJ: string): boolean;
var
  dig13, dig14: string;
  sm, i, r, peso: Integer;
begin
  // length - retorna o tamanho da string do CNPJ (CNPJ é um número formado por 14 dígitos)
  if ((CNPJ = '00000000000000') or (CNPJ = '11111111111111') or
    (CNPJ = '22222222222222') or (CNPJ = '33333333333333') or
    (CNPJ = '44444444444444') or (CNPJ = '55555555555555') or
    (CNPJ = '66666666666666') or (CNPJ = '77777777777777') or
    (CNPJ = '88888888888888') or (CNPJ = '99999999999999') or
    (length(CNPJ) <> 14)) then
  begin
    isCNPJ := false;
    Exit;
  end;

  // "try" - protege o código para eventuais erros de conversão de tipo através da função "StrToInt"
  try
    { *-- Cálculo do 1o. Digito Verificador --* }
    sm := 0;
    peso := 2;
    for i := 12 downto 1 do
    begin
      // StrToInt converte o i-ésimo caractere do CNPJ em um número
      sm := sm + (StrToInt(CNPJ[i]) * peso);
      peso := peso + 1;
      if (peso = 10) then
        peso := 2;
    end;
    r := sm mod 11;
    if ((r = 0) or (r = 1)) then
      dig13 := '0'
    else
      str((11 - r): 1, dig13);
    // converte um número no respectivo caractere numérico

    { *-- Cálculo do 2o. Digito Verificador --* }
    sm := 0;
    peso := 2;
    for i := 13 downto 1 do
    begin
      sm := sm + (StrToInt(CNPJ[i]) * peso);
      peso := peso + 1;
      if (peso = 10) then
        peso := 2;
    end;
    r := sm mod 11;
    if ((r = 0) or (r = 1)) then
      dig14 := '0'
    else
      str((11 - r): 1, dig14);

    { Verifica se os digitos calculados conferem com os digitos informados. }
    if ((dig13 = CNPJ[13]) and (dig14 = CNPJ[14])) then
      isCNPJ := true
    else
      isCNPJ := false;
  except
    isCNPJ := false
  end;
end;

function THCIAwsSecManCli.DateTimeToStrUs(dt: TDatetime): string;
var
  us: string;
begin
  // Spit out most of the result: '20160802 11:34:36.'
  Result := FormatDateTime('yyyymmddhhnnss', dt);

  // extract the number of microseconds
  dt := Frac(dt); // fractional part of day
  dt := dt * 24 * 60 * 60; // number of seconds in that day
  us := IntToStr(Round(Frac(dt) * 1000000));

  // Add the us integer to the end:
  // '20160801 11:34:36.' + '00' + '123456'
  Result := Result + StringOfChar('0', 6 - length(us)) + us;
end;

function THCIAwsSecManCli.MD5(const texto: string): string;
var
  idmd5: TIdHashMessageDigest5;
begin
  idmd5 := TIdHashMessageDigest5.Create;
  try
    Result := idmd5.HashStringAsHex(texto);
  finally
    idmd5.Free;
  end;
end;

initialization

THCIAwsSecManCli.URLS3Version :=
  'http://hci-aws-sec-man-cli-updates.s3-website-us-east-1.amazonaws.com/version.json';

THCIAwsSecManCli.URLS3Exe :=
  'http://hci-aws-sec-man-cli-updates.s3-website-us-east-1.amazonaws.com/';

THCIAwsSecManCli.ExeName := 'HCIAwsSecManagerClients.exe';

THCIAwsSecManCli.URLServicoAWSSecManTeste :=
  'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/testconn/cnpj/';

THCIAwsSecManCli.URLServicoAWSSecMan :=
  'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/cnpj/';

// 04076778000488

// C:\Users\jpmonoo\Documents\reps\hci_aws_sec_manager_clients\Win32\Release

// 33914971000449

end.
