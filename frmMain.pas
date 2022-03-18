unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdCustomHTTPServer,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdHTTPServer, Server.Runner,
  Vcl.StdCtrls, IdTCPConnection, IdTCPClient, IdHTTP, IdAuthentication,
  Vcl.ExtCtrls, Vcl.Mask, Registry, System.UITypes, IdHashMessageDigest,
  System.JSON, Vcl.ComCtrls, IniFiles;

type
  THCIAwsSecManCli = class(TForm)
    IdHTTP1: TIdHTTP;
    Timer1: TTimer;
    MaskEdit1: TMaskEdit;
    Label1: TLabel;
    ButtonSalvar: TButton;
    ButtonTeste: TButton;
    ButtonAtualizacao: TButton;
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    ListBoxUser: TListBox;
    ButtonLogin: TButton;
    Button2: TButton;
    ButtonListUsers: TButton;
    EditUserName: TEdit;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    EditServer: TEdit;
    EditToken: TEdit;
    StaticText3: TStaticText;
    ButtonSalvarToken: TButton;

    procedure FormCreate(ASender: TObject);
    function GetUpdateVersion(): string;
    procedure DoUpdate();
    procedure Timer1Fired(Sender: TObject);
    procedure ButtonSalvarClick(Sender: TObject);

    function isCNPJ(CNPJ: string): boolean;
    function MD5(const texto: string): string;
    function DateTimeToStrUs(dt: TDatetime): string;
    procedure ButtonAtualizacaoClick(Sender: TObject);
    function DownloadUpdate(RemoteVersion: String): boolean;
    function RunCommand(const ACommand, AParameters: String): String;
    function AccessServerTest(CNPJ: String): String;
    function AccessServer(CNPJ: String; Hash: String): String;
    procedure ButtonTesteClick(Sender: TObject);
    procedure DoUpdateAccess();
    procedure ListUsers();
    procedure ButtonListUsersClick(Sender: TObject);

    procedure GravaIni(Secao: String; Chave: String; Valor: String);

    function LeIni(Secao: String; Chave: String): String;

  private

  public
    class var AppVersion: String;
    class var AppPath: String;
    class var AppToken: String;
    class var AppIniFile: String;
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
  AppVersionTemp: string;

begin

  AppPath := LeIni('Config', 'AppPath');

  if (AppPath.equals('error')) then
  begin
    GravaIni('Config', 'AppPath', ExtractFilePath(Application.ExeName));
    AppPath := ExtractFilePath(Application.ExeName);
  end;

  AppVersionTemp := LeIni('Config', 'AppVersion');

  if (AppVersionTemp.equals('error')) then
  begin
    GravaIni('Config', 'AppVersion', '0');
    AppVersion := '0';
  end
  else
    AppVersion := AppVersionTemp;

  AppToken := LeIni('Config', 'Token');

  hashClient := LeIni('Config', 'hashClient');

  if (hashClient.equals('error')) then
  begin
    timeStamp := DateTimeToStrUs(now);
    hashClient := MD5(timeStamp);
    GravaIni('Config', 'hashClient', hashClient);
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
  AccessServer(LeIni('Config', 'Numerocnpj'), LeIni('Config', 'hashClient'));
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
    Timer1.Interval := 300000;
    Timer1.Enabled := true;
  end;
end;

procedure THCIAwsSecManCli.ListUsers();

var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  JSonUserValue: TJSonValue;
  JSonObject: TJSonObject;
  RemoteVersion: String;
  Resultado: String;
  i: Integer;
  UserName: String;
begin
  lResponse := TStringStream.Create('');
  JSonObject := TJSonObject.Create;

  ListBoxUser.Clear;

  try
    try

      lURL := 'http://sistema.hci.com.br:9998/ListUsers';
      IdHTTP1.Request.CustomHeaders.AddValue('Authorization',
        'Basic dXNlcjpRVzVoT0ZNdVdUUkhLVEluWG1JK1VRPT0=');
      IdHTTP1.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := JSonObject.ParseJSONValue(Resposta);

      Resultado := (JSonValue as TJSonObject).Get('result').JSonValue.Value;

      if Resultado.Equals('ok') then
      begin

        JSonValue := (JSonValue as TJSonObject).Get('users').JSonValue;
        if (JSonValue is TJSONArray) then

          for i := 0 to (JSonValue as TJSONArray).Count - 1 do
          begin
            JSonUserValue :=
              ((JSonValue as TJSONArray).Items[i] as TJSonObject);

            UserName := JSonUserValue.GetValue<string>('nome');

            ListBoxUser.Items.Add(UserName);

          end;

      end;

    except

    end;

  finally
    lResponse.Free();
    JSonObject.Free;

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

procedure THCIAwsSecManCli.ButtonListUsersClick(Sender: TObject);
begin

  ButtonListUsers.Enabled := false;
  Screen.Cursor := crHourglass;

  StatusBar1.Panels[0].Text := 'Por favor, aguarde, buscando usuários';

  Application.ProcessMessages;

  ListUsers();

  StatusBar1.Panels[0].Text := '';

  ButtonListUsers.Enabled := true;
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

  GravaIni('Config', 'Numerocnpj', CpnjDigitado);

end;

procedure THCIAwsSecManCli.ButtonTesteClick(Sender: TObject);
begin
  // AccessServerTest(ReadFromRegistry('Numerocnpj'));
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

          // SaveToRegistry('AppVersion', AppVersion);

          if RunningAsService then
            RunCommand('powershell.exe',
              '-NonInteractive -ExecutionPolicy Unrestricted -command "Restart-Service HCIAwsSecManagerClients -Force"');

        end;
      end;

    except

      on E: Exception do
      begin

        if not RunningAsService then
          MessageDlg('Erro executando atualização do software ' + E.Message,
            mtError, mbOKCancel, 0);

      end;

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

      on E: Exception do
      begin
        MessageDlg('Teste falhou ' + E.Message, mtError, mbOKCancel, 0);
      end;

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
      lURL := URLServicoAWSSecMan + CNPJ + '/hash/' + Hash + '/version/' +
        LeIni('Config', 'AppVersion');
      IdHTTP1.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);

      JSonValue.Free;

      if not RunningAsService then
        MessageDlg('Atualização de IP efetuada com sucesso', mtInformation,
          mbOKCancel, 0);

    except

      on E: Exception do
      begin

        if not RunningAsService then
          MessageDlg('Erro executando atualização de IP ' + E.Message, mtError,
            mbOKCancel, 0);

      end;

    end;

  finally
    lResponse.Free();

  end;

end;


// ####################################################################################

procedure THCIAwsSecManCli.GravaIni(Secao: String; Chave: String;
  Valor: String);
var
  ArquivoINI: TIniFile;
begin

  ArquivoINI := TIniFile.Create(ExtractFilePath(Application.ExeName) + '\' +
    AppIniFile);
  ArquivoINI.WriteString(Secao, Chave, Valor);

  ArquivoINI.Free;

end;

function THCIAwsSecManCli.LeIni(Secao: String; Chave: String): String;
var
  ArquivoINI: TIniFile;
var
  retorno: string;
begin

  ArquivoINI := TIniFile.Create(ExtractFilePath(Application.ExeName) + '\' +
    AppIniFile);
  retorno := ArquivoINI.ReadString(Secao, Chave, 'error');
  ArquivoINI.Free;

  Result := retorno;

end;

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
  retorno: String;
begin
  retorno := '';
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
          retorno := retorno + String(pBuffer);
        until (dRead < CReadBuffer);
      until (dRunning <> WAIT_TIMEOUT);
      CloseHandle(piProcess.hProcess);
      CloseHandle(piProcess.hThread);
    end;

    CloseHandle(hRead);
    CloseHandle(hWrite);

    Result := retorno;
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

THCIAwsSecManCli.AppIniFile := 'hciconfig.ini';

THCIAwsSecManCli.URLS3Version :=
  'http://hci-aws-sec-man-cli-updates.s3-website-us-east-1.amazonaws.com/version.json';

THCIAwsSecManCli.URLS3Exe :=
  'http://hci-aws-sec-man-cli-updates.s3-website-us-east-1.amazonaws.com/';

THCIAwsSecManCli.ExeName := 'HCIAwsLauncher.exe';

THCIAwsSecManCli.URLServicoAWSSecManTeste :=
  'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/testconn/cnpj/';

THCIAwsSecManCli.URLServicoAWSSecMan :=
  'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/cnpj/';

// 04076778000488

// C:\Users\jpmonoo\Documents\reps\hci_aws_sec_manager_clients\Win32\Release

// 33914971000449

end.
