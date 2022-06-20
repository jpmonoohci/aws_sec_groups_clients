unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdCustomHTTPServer,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdHTTPServer, Server.Runner,
  Vcl.StdCtrls, IdTCPConnection, IdTCPClient, IdHTTP, IdAuthentication,
  Vcl.ExtCtrls, Vcl.Mask, Registry, System.UITypes, IdHashMessageDigest,
  System.JSON, Vcl.ComCtrls, IniFiles, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg,
  ShellApi, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,
  IdSSLOpenSSL, System.Zip, IOUtils, Vcl.Menus, ClipBrd, FrmLogin, Data.DB,
  Vcl.Grids, Vcl.DBGrids, Datasnap.DBClient, Datasnap.Provider,
  System.ImageList, Vcl.ImgList, FileCtrl;

type
  THCIAwsSecManCli = class(TForm)
    IdHTTP1: TIdHTTP;
    Timer1: TTimer;
    MaskEdit1: TMaskEdit;
    ButtonSalvar: TButton;
    ButtonTeste: TButton;
    ButtonAtualizacao: TButton;
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    ListBoxUser: TListBox;
    ButtonExecutarHCI: TButton;
    Button2: TButton;
    ButtonListUsers: TButton;
    EditUserName: TEdit;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    EditServer: TEdit;
    EditToken: TEdit;
    StaticText3: TStaticText;
    ButtonSalvarToken: TButton;
    ButtonTestarToken: TButton;
    ButtonLigarServer: TButton;
    ButtonAtualizarStatusServer: TButton;
    Image1: TImage;
    StaticText4: TStaticText;
    EditVersion: TEdit;
    ButtonLoginWeb: TButton;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    PopupMenu1: TPopupMenu;
    DesconectarUsurio1: TMenuItem;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    EditName: TEdit;
    EditIP: TEdit;
    EditGroup: TEdit;
    Label1: TLabel;
    ButtonTesteConexao: TButton;
    TabSheet4: TTabSheet;
    FaturasDataSet: TClientDataSet;
    FaturasDataSource: TDataSource;
    DBGrid1: TDBGrid;
    FaturasDataSetData: TStringField;
    FaturasDataSetDocumento: TStringField;
    FaturasDataSetValor: TStringField;
    FaturasDataSetBoleto: TStringField;
    FaturasDataSetXML: TStringField;
    ImageList1: TImageList;
    FaturasDataSetPDF: TStringField;

    procedure FormCreate(ASender: TObject);
    function GetUpdateVersion(): string;
    function VerifyUpdateAvailable(): Boolean;
    procedure Timer1Fired(Sender: TObject);

    function isCNPJ(CNPJ: string): Boolean;
    function MD5(const texto: string): string;
    function DateTimeToStrUs(dt: TDatetime): string;

    function DownloadUpdate(RemoteVersion: String): Boolean;
    function RunCommand(const ACommand, AParameters: String): String;
    function AccessServerTest(Token: String): String;
    function AccessServer(Token: String; Hash: String): String;

    function StartServer(Token: String): String;
    function VerifyStatusServer(Token: String): String;
    function VerifyStatusServerSemToken(): String;

    procedure ListServerUsers();
    procedure DisconnectServerUser(User: String);
    procedure ButtonListUsersClick(Sender: TObject);
    function PingServer(): Boolean;

    procedure GravaIni(Secao: String; Chave: String; Valor: String);

    function LeIni(Secao: String; Chave: String): String;
    procedure ButtonExecutarHCIClick(Sender: TObject);
    procedure ButtonTokenSalvarClick(Sender: TObject);
    procedure ButtonTestarTokenClick(Sender: TObject);
    procedure ButtonLigarServerClick(Sender: TObject);
    procedure ButtonAtualizarStatusServerClick(Sender: TObject);
    procedure ListBoxUserDblClick(Sender: TObject);
    procedure ButtonLoginWebClick(Sender: TObject);
    procedure ListBoxUserMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DesconectarUsurio1Click(Sender: TObject);
    procedure EditServerChange(Sender: TObject);
    procedure ButtonTesteConexaoClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure CarregaFaturas(CNPJ: String);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    function DownloadFile(URL: String; ArquivoDestino: String): Boolean;

  private

  public
    class var AppVersion: String;
    class var AppPath: String;
    class var AppToken: String;
    class var AppIniFile: String;
    class var URLS3Version: String;
    class var URLS3Root: String;
    class var ExeName: String;
    class var URLServicoAWSSecManTeste: String;
    class var URLServicoAWSSecMan: String;
    class var URLServicoStartServer: String;
    class var URLServicoStatusServer: String;
    class var URLServicoBuscaFaturas: String;
    class var ServerIP: String;
    class var ServerGroup: String;
    class var TimeoutConexao: Integer;
    class var TimeoutLeitura: Integer;
    class var UpdatePackageName: String;
    class var ListUserBoxSelectedItem: String;
    class var IgnoreUpdates: Boolean;
    class var HasAdminRights: Boolean;
    class var ClientTSPlus: String;
    class var DebugExec: Boolean;
    class var LoggedOnPortal: Boolean;
    class var URLServicoLoginPortal: String;
    class var CNPJCliente: String;

  end;

var
  HCIAwsSecManCli: THCIAwsSecManCli;

implementation

{$R *.dfm}

procedure THCIAwsSecManCli.FormCreate(ASender: TObject);
var
  hashClient: string;
  timeStamp: string;
  Username: string;
  Token: string;
  IgnorarAtualizacao: string;
  TemDireitosAdmin: string;
  DebugString: string;

begin

  EditVersion.Text := AppVersion;

  DebugString := LeIni('Config', 'DebugExec');

  if (DebugString.equals('error')) then
    DebugExec := false
  else
  begin
    if (DebugString.equals('True')) then
      DebugExec := true;
  end;

  AppPath := LeIni('Config', 'AppPath');

  if (AppPath.equals('error')) then
  begin
    GravaIni('Config', 'AppPath', ExtractFilePath(Application.ExeName));
    AppPath := ExtractFilePath(Application.ExeName);
  end;

  IgnorarAtualizacao := LeIni('Config', 'IgnoreUpdates');

  if (IgnorarAtualizacao.equals('error')) then
  begin
    GravaIni('Config', 'IgnoreUpdates', 'False');
    AppPath := ExtractFilePath(Application.ExeName);
  end
  else
  begin
    if (IgnorarAtualizacao.equals('True')) then
      IgnoreUpdates := true;

  end;

  TemDireitosAdmin := LeIni('Config', 'HasAdminRights');

  if (TemDireitosAdmin.equals('True')) then
    HasAdminRights := true;

  AppToken := LeIni('Config', 'Token');

  hashClient := LeIni('Config', 'HashClient');

  if (hashClient.equals('error')) then
  begin
    timeStamp := DateTimeToStrUs(now);
    hashClient := MD5(timeStamp);
    GravaIni('Config', 'HashClient', hashClient);
  end;

  Username := LeIni('Config', 'Username');

  if (not Username.equals('error')) then
  begin
    EditUserName.Text := Username;
  end;

  Token := LeIni('Config', 'Token');

  if (not Token.equals('error')) then
  begin
    EditToken.Text := Token;

    PageControl1.Pages[0].Enabled := true;
    PageControl1.Pages[1].Enabled := true;
    PageControl1.ActivePageIndex := 0;

  end
  else
  begin
    PageControl1.Pages[0].Enabled := false;
    PageControl1.Pages[1].Enabled := false;
    PageControl1.ActivePageIndex := 2;
  end;

  PageControl1.Pages[1].TabVisible := true;

end;

procedure THCIAwsSecManCli.Timer1Fired(Sender: TObject);
var
  Token: String;
  StatusServer: String;

begin
  Timer1.Enabled := false;
  try
    try

      Token := LeIni('Config', 'Token');

      if (not Token.Trim.IsEmpty) then
      begin
        VerifyStatusServer(Token);
        StatusServer := EditServer.Text;

        if (StatusServer.equals('Ligando')) then
        begin
          Timer1.Enabled := true;
        end;
      end;
    except

    end;
  except
    Timer1.Enabled := true;
  end;
end;

procedure THCIAwsSecManCli.ListBoxUserDblClick(Sender: TObject);
var
  User: String;
begin
  User := ListBoxUser.Items[ListBoxUser.ItemIndex];

  if (User.EndsWith(' (Conectado)')) then
    User := User.Substring(0, User.Length - 12);

  EditUserName.Text := User;
  PageControl1.ActivePageIndex := 0;
end;

procedure THCIAwsSecManCli.ListBoxUserMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  PopupPos: TPoint;
begin
  inherited;

  if (not HasAdminRights) then
    Exit();

  if (Button = mbRight) then
  begin
    I := ListBoxUser.ItemAtPos(Point(X, Y), true);

    ListBoxUser.ItemIndex := I;

    if (I >= 0) then
    begin

      ListUserBoxSelectedItem := ListBoxUser.Items.Strings
        [ListBoxUser.ItemIndex];

      PopupPos := ListBoxUser.ClientToScreen(Point(X, Y));

      PopupMenu1.Popup(PopupPos.X, PopupPos.Y);

    end;
  end;
end;

procedure THCIAwsSecManCli.ListServerUsers();

var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  JSonUserValue: TJSonValue;
  JSonObject: TJSonObject;
  Resultado: String;
  I: Integer;
  Username: String;
  Connected: String;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;

begin
  lResponse := TStringStream.Create('');
  JSonObject := TJSonObject.Create;

  ListBoxUser.Clear;

  try
    try

      StatusBar1.Panels[0].Text := 'Por favor aguarde, buscando usuários';
      Application.ProcessMessages;

      lURL := 'http://' + ServerIP + ':9998/ListUsersByGroup?group=' +
        ServerGroup;

      Http := TIdHTTP.Create(nil);

      Http.Request.CustomHeaders.AddValue('Authorization',
        'Basic dXNlcjpRVzVoT0ZNdVdUUkhLVEluWG1JK1VRPT0=');

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := JSonObject.ParseJSONValue(Resposta);

      Resultado := (JSonValue as TJSonObject).Get('result').JSonValue.Value;

      if Resultado.equals('ok') then
      begin

        JSonValue := (JSonValue as TJSonObject).Get('users').JSonValue;
        if (JSonValue is TJSONArray) then

          for I := 0 to (JSonValue as TJSONArray).Count - 1 do
          begin
            JSonUserValue :=
              ((JSonValue as TJSONArray).Items[I] as TJSonObject);

            Username := JSonUserValue.GetValue<string>('nome');

            Connected := JSonUserValue.GetValue<string>('connected');

            if (Connected.equals('True')) then
              Connected := ' (Conectado)'
            else
              Connected := '';

            ListBoxUser.Items.Add(Username + Connected);

          end;

        StatusBar1.Panels[0].Text := 'Listagem de usuários completa.';
        Application.ProcessMessages;

      end;

    except

      StatusBar1.Panels[0].Text := 'Erro buscando usuários';
      Application.ProcessMessages;
    end;

  finally
    lResponse.Free();
    JSonObject.Free;

    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

procedure THCIAwsSecManCli.DisconnectServerUser(User: String);
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  JSonUserValue: TJSonValue;
  JSonObject: TJSonObject;
  Resultado: String;
  I: Integer;
  Username: String;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;

begin
  lResponse := TStringStream.Create('');
  JSonObject := TJSonObject.Create;

  try
    try

      StatusBar1.Panels[0].Text := 'Por favor aguarde, desconectando usuário';
      Application.ProcessMessages;

      lURL := 'http://' + ServerIP + ':9998/DisconnectUser?user=' + User;

      Http := TIdHTTP.Create(nil);

      Http.Request.CustomHeaders.AddValue('Authorization',
        'Basic dXNlcjpRVzVoT0ZNdVdUUkhLVEluWG1JK1VRPT0=');

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura * 30;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, lResponse);

      StatusBar1.Panels[0].Text := 'Usuário desconectado';
      Application.ProcessMessages;

    except

      StatusBar1.Panels[0].Text := 'Erro desconectando usuário';
      Application.ProcessMessages;
    end;

  finally
    lResponse.Free();
    JSonObject.Free;

    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

procedure THCIAwsSecManCli.PageControl1Change(Sender: TObject);
var
  FormLogin: TLogin;
  RetornoLogin: Integer;
begin

  if ((PageControl1.ActivePageIndex = 3) and (LoggedOnPortal = false)) then
  begin

    FormLogin := TLogin.Create(self);
    FormLogin.AppToken := AppToken;

    FormLogin.TimeoutConexao := TimeoutConexao;
    FormLogin.TimeoutLeitura := TimeoutLeitura;

    try
      FormLogin.ShowModal;
      RetornoLogin := FormLogin.ModalResult;

      if (RetornoLogin = mrOk) then
      begin
        LoggedOnPortal := true;
        CNPJCliente := FormLogin.CNPJCliente;

        CarregaFaturas(CNPJCliente);
      end
      else
        PageControl1.ActivePageIndex := 0;

    finally
      FormLogin.Free;
    end;

  end;

end;

procedure THCIAwsSecManCli.CarregaFaturas(CNPJ: String);
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  RetornoChamada: String;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;
  JSonObj: TJSonObject;
  JSonArray: TJSONArray;
  I: Integer;
  FaturaObj: TJSonObject;
  JSonValue: TJSonValue;

  Teste: String;

begin

  StatusBar1.Panels[0].Text := 'Buscando faturas';

  Application.ProcessMessages;

  FaturasDataSet.EmptyDataSet;

  lResponse := TStringStream.Create('');
  try
    try
      lURL := URLServicoBuscaFaturas + CNPJ;

      Http := TIdHTTP.Create(nil);

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, lResponse);

      Resposta := UTF8Decode(lResponse.DataString);

      JSonObj := TJSonObject.ParseJSONValue(Resposta) as TJSonObject;

      JSonValue := JSonObj.Get('Faturas').JSonValue;

      JSonArray := JSonValue as TJSONArray;

      for I := 0 to JSonArray.Size - 1 do
      begin

        FaturaObj := (JSonArray.Get(I) as TJSonObject);

        FaturasDataSet.Append;

        JSonValue := FaturaObj.Get(3).JSonValue;

        FaturasDataSetData.AsString := JSonValue.Value;

        JSonValue := FaturaObj.Get(1).JSonValue;
        FaturasDataSetDocumento.AsString := JSonValue.Value;

        JSonValue := FaturaObj.Get(2).JSonValue;
        FaturasDataSetValor.AsString := JSonValue.Value;

        JSonValue := FaturaObj.Get(4).JSonValue;
        FaturasDataSetBoleto.AsString := JSonValue.Value;

        JSonValue := FaturaObj.Get(5).JSonValue;
        FaturasDataSetPDF.AsString := JSonValue.Value;

        JSonValue := FaturaObj.Get(9).JSonValue;
        FaturasDataSetXML.AsString := JSonValue.Value;

        FaturasDataSet.Post;

      end;

      FaturasDataSet.First;

      JSonObj.Free;

      StatusBar1.Panels[0].Text := 'Busca de faturas efetuada';

      Application.ProcessMessages;

    except

      on E: Exception do
      begin

        StatusBar1.Panels[0].Text := 'Erro buscando faturas ' + E.Message;

      end;

    end;

  finally
    lResponse.Free();

    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

function THCIAwsSecManCli.PingServer(): Boolean;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  JSonUserValue: TJSonValue;
  JSonObject: TJSonObject;
  Resultado: String;
  I: Integer;
  Username: String;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;

begin
  lResponse := TStringStream.Create('');
  JSonObject := TJSonObject.Create;

  try
    try

      StatusBar1.Panels[0].Text := 'Aguardando servidor ficar online';
      Application.ProcessMessages;

      lURL := 'http://' + ServerIP + ':9998/PingServer';

      Http := TIdHTTP.Create(nil);

      Http.Request.CustomHeaders.AddValue('Authorization',
        'Basic dXNlcjpRVzVoT0ZNdVdUUkhLVEluWG1JK1VRPT0=');

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, lResponse);

      StatusBar1.Panels[0].Text := 'Servidor está online';
      Application.ProcessMessages;

      Result := true;

    except

      Result := false;

    end;

  finally
    lResponse.Free();
    JSonObject.Free;

    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

procedure THCIAwsSecManCli.ButtonTestarTokenClick(Sender: TObject);
var
  Token: String;
begin

  Token := LeIni('Config', 'Token');

  if (Token.Trim.IsEmpty) then
  begin
    MessageDlg('Digite o Token e clique em Salvar.', mtError, [mbOk], 0);
    Exit();
  end;

  PageControl1.Pages[0].Enabled := true;
  PageControl1.Pages[1].Enabled := true;

  AccessServerTest(Token);

  VerifyStatusServer(Token);

end;

procedure THCIAwsSecManCli.ButtonTesteConexaoClick(Sender: TObject);
var
  URL: String;
begin

  URL := 'http://hcisistemasintegrados.speedtestcustom.com';

  ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);

end;

procedure THCIAwsSecManCli.ButtonAtualizarStatusServerClick(Sender: TObject);

var
  Token: string;
begin

  Token := LeIni('Config', 'Token');

  if (not Token.equals('error')) then
  begin

    ButtonAtualizarStatusServer.Enabled := false;

    VerifyStatusServer(Token);

    ButtonAtualizarStatusServer.Enabled := true;

  end

end;

procedure THCIAwsSecManCli.ButtonLigarServerClick(Sender: TObject);

var
  Token: string;
begin

  Token := LeIni('Config', 'Token');

  if (not Token.equals('error')) then
  begin

    ButtonLigarServer.Enabled := false;
    StartServer(Token);

  end

end;

procedure THCIAwsSecManCli.ButtonListUsersClick(Sender: TObject);
var
  ServerStatus: String;
  Token: String;
  hashClient: String;
  ContaPing: Integer;
begin

  ServerStatus := EditServer.Text;

  if (not ServerStatus.equals('Ligado')) then
  begin
    MessageDlg('Por favor, antes ligue seu servidor.', mtError, [mbOk], 0);
    Exit();
  end;

  if ServerGroup.equals('') then
  begin
    MessageDlg('Nome do Grupo inválido.', mtError, [mbOk], 0);
    Exit();
  end;

  Token := LeIni('Config', 'Token');
  hashClient := LeIni('Config', 'HashClient');

  if (not Token.equals('error')) then
  begin
    AccessServer(Token, hashClient);
  end
  else
  begin
    MessageDlg('Por favor, configure o Token.', mtError, [mbOk], 0);
    Exit();
  end;

  ButtonListUsers.Enabled := false;
  Screen.Cursor := crHourglass;

  ContaPing := 1;
  while (ContaPing < 20) do
  begin

    Application.ProcessMessages;

    if PingServer() then
      break;

    Application.ProcessMessages;

    sleep(10);

    ContaPing := ContaPing + 1;

  end;

  Screen.Cursor := crDefault;

  Application.ProcessMessages;

  if (ContaPing >= 20) then
  begin

    MessageDlg('Erro conectando ao servidor, por favor tente novamente.',
      mtError, [mbOk], 0);
    ButtonListUsers.Enabled := false;
    Exit();
  end;

  ListServerUsers();

  ButtonListUsers.Enabled := true;
  Screen.Cursor := crDefault;
end;

procedure THCIAwsSecManCli.ButtonExecutarHCIClick(Sender: TObject);
var
  Username: String;
  Password: String;
  Server: String;
  ServerStatus: String;
  Token: String;
  hashClient: String;
  ParametersCommand: String;
  ContaPing: Integer;
begin

  ButtonExecutarHCI.Enabled := false;

  Server := ServerIP;

  Username := EditUserName.Text;

  Password := '0101';

  if (Username.Trim.IsEmpty) then
  begin

    ButtonExecutarHCI.Enabled := true;
    MessageDlg('Digite o Username e clique em Executar HCI.', mtError,
      [mbOk], 0);
    Exit();
  end;

  GravaIni('Config', 'Username', Username.Trim);

  ServerStatus := EditServer.Text;

  if (not ServerStatus.equals('Ligado')) then
  begin
    ButtonExecutarHCI.Enabled := true;
    MessageDlg('Por favor, antes ligue seu servidor.', mtError, [mbOk], 0);
    Exit();
  end;

  Token := LeIni('Config', 'Token');
  hashClient := LeIni('Config', 'HashClient');

  if (not Token.equals('error')) then
  begin
    AccessServer(Token, hashClient);
  end
  else
  begin
    ButtonExecutarHCI.Enabled := true;
    MessageDlg('Por favor, configure o Token.', mtError, [mbOk], 0);
    Exit();
  end;

  Screen.Cursor := crHourglass;

  ContaPing := 1;
  while (ContaPing < 20) do
  begin

    Application.ProcessMessages;

    if PingServer() then
      break;

    Application.ProcessMessages;

    sleep(10);

    ContaPing := ContaPing + 1;

  end;

  Screen.Cursor := crDefault;

  Application.ProcessMessages;

  if (ContaPing >= 20) then
  begin
    ButtonExecutarHCI.Enabled := true;
    MessageDlg('Erro conectando ao servidor, por favor tente novamente.',
      mtError, [mbOk], 0);
    Exit();
  end;

  try

    StatusBar1.Panels[0].Text := 'Conectando ao servidor';
    Application.ProcessMessages;

    ParametersCommand := ' -user ' + Username + ' -psw ' + Password +
      ' -server ' + Server;

    if (DebugExec) then
    begin

      Clipboard.AsText := AppPath + ClientTSPlus + ' ' + ParametersCommand;

      MessageDlg(AppPath + ClientTSPlus + ' ' + ParametersCommand,
        mtInformation, [mbOk], 0);
    end;

    RunCommand(AppPath + ClientTSPlus, ParametersCommand);

    StatusBar1.Panels[0].Text := 'Conexão executada.';

    ButtonExecutarHCI.Enabled := true;

    Application.ProcessMessages;

  finally

  end;

end;

procedure THCIAwsSecManCli.ButtonLoginWebClick(Sender: TObject);
var
  URL: string;
  Server: string;
  Username: string;
  ServerStatus: string;
  Token: string;
  hashClient: string;
  Password: string;
begin

  Server := ServerIP;

  Username := EditUserName.Text;

  Password := '0101';

  if (Username.Trim.IsEmpty) then
  begin
    MessageDlg('Digite o Username e clique em Executar HCI.', mtError,
      [mbOk], 0);
    Exit();
  end;

  GravaIni('Config', 'Username', Username.Trim);

  ServerStatus := EditServer.Text;

  if (not ServerStatus.equals('Ligado')) then
  begin
    MessageDlg('Por favor, antes ligue seu servidor.', mtError, [mbOk], 0);
    Exit();
  end;

  Token := LeIni('Config', 'Token');
  hashClient := LeIni('Config', 'HashClient');

  if (not Token.equals('error')) then
  begin
    AccessServer(Token, hashClient);
  end
  else
  begin
    MessageDlg('Por favor, configure o Token.', mtError, [mbOk], 0);
    Exit();
  end;

  URL := 'http://' + Server;
  ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
end;

procedure THCIAwsSecManCli.ButtonTokenSalvarClick(Sender: TObject);
var
  Token: String;
begin

  Token := EditToken.Text;

  if (Token.Trim.IsEmpty) then
  begin
    MessageDlg('Digite o Token e clique em Salvar.', mtError, [mbOk], 0);
    Exit();
  end;

  GravaIni('Config', 'Token', Token.Trim);

  MessageDlg('Token salvo com sucesso.', mtInformation, [mbOk], 0);

  PageControl1.Pages[0].Enabled := true;
  PageControl1.Pages[1].Enabled := true;

  AccessServerTest(Token);

  VerifyStatusServer(Token);

end;

function THCIAwsSecManCli.VerifyUpdateAvailable(): Boolean;
var
  RemoteVersion: String;
  ZipFile: String;
  FilePath: String;
  FileName: String;
  FileNameLen: Integer;
begin

  try
    try

      if (IgnoreUpdates) then
      begin
        Result := false;
        Exit;
      end;

      StatusBar1.Panels[0].Text := 'Verificando atualizações';

      Application.ProcessMessages;

      RemoteVersion := GetUpdateVersion();

      if (not RemoteVersion.equals(AppVersion) and not RemoteVersion.IsEmpty)
      then
      begin

        StatusBar1.Panels[0].Text := 'Atualização encontrada (v' +
          RemoteVersion + ')';

        Application.ProcessMessages;

        ZipFile := AppPath + 'update_' + RemoteVersion + '\' +
          UpdatePackageName;

        if (FileExists(ZipFile)) then
          DeleteFile(ZipFile);

        if (DownloadUpdate(RemoteVersion)) then
        begin

          if TZipFile.IsValid(ZipFile) then
          begin
            TZipFile.ExtractZipFile(ZipFile, AppPath + 'update_' +
              RemoteVersion);

            DeleteFile(ZipFile);
          end
          else
          begin
            MessageDlg('Erro executando atualização. Zip file inválido',
              mtError, [mbOk], 0);
            Exit();
          end;

          for FilePath in TDirectory.GetFiles(AppPath + 'update_' +
            RemoteVersion) do
          begin

            FileName := ExtractFileName(FilePath);

            if (FileExists(AppPath + FileName)) then
              RenameFile(AppPath + FileName, AppPath + FileName + '_' +
                AppVersion);

            CopyFile(PWideChar(FilePath), PWideChar(AppPath + FileName), false);

          end;

          for FilePath in TDirectory.GetFiles(AppPath) do
          begin

            FileName := ExtractFileName(FilePath);
            FileNameLen := FileName.Length;

            if ((FileName.Substring(FileNameLen - 2, 1).equals('_')) and
              (not FileName.Substring(FileNameLen - 1, 1).equals(AppVersion)))
            then
            begin
              DeleteFile(FilePath);
            end;

          end;

          Result := true;

          MessageDlg
            ('Atualização efetuada com sucesso. Reinicie a aplicação. (v' +
            RemoteVersion + ')', mtInformation, [mbOk], 0);

          Application.ProcessMessages;

          StatusBar1.Panels[0].Text := 'Encerrando aplicação.';

          Application.ProcessMessages;

          Application.Terminate;

        end;
      end
      else
        Result := false;

    except

      on E: Exception do
      begin

        Result := false;

        MessageDlg('Erro executando atualização do software ' + E.Message,
          mtError, [mbOk], 0);

      end;

    end;

  finally

  end;

end;

function THCIAwsSecManCli.DownloadUpdate(RemoteVersion: String): Boolean;
var
  fileDownload: TFileStream;
  lURL: String;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;
begin
  try

    try

      StatusBar1.Panels[0].Text := 'Baixando atualização. v(' +
        AppVersion + ')';

      Application.ProcessMessages;

      if (not DirectoryExists(AppPath + 'update_' + RemoteVersion)) then
      begin

        if (not CreateDir(AppPath + 'update_' + RemoteVersion)) then
        begin

          MessageDlg('Erro criando diretório de atualização. ' + AppPath +
            'update_' + RemoteVersion, mtError, [mbOk], 0);
          Exit();

        end;

      end;

      if (FileExists(AppPath + 'update_' + RemoteVersion + '\' +
        UpdatePackageName)) then
        DeleteFile(AppPath + 'update_' + RemoteVersion + '\' +
          UpdatePackageName);

      fileDownload := TFileStream.Create(AppPath + 'update_' + RemoteVersion +
        '\' + UpdatePackageName, fmCreate);

      lURL := URLS3Root + RemoteVersion + '/' + UpdatePackageName;

      Http := TIdHTTP.Create(nil);

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura * 20;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, fileDownload);

      if (not FileExists(AppPath + 'update_' + RemoteVersion + '\' +
        UpdatePackageName)) then
      begin
        Result := false;
        MessageDlg('Falha efetuando download de atualização. ' + AppPath +
          'update_' + RemoteVersion + '\' + UpdatePackageName, mtError,
          [mbOk], 0);

        Exit;

      end;

      Result := true;
    except
      MessageDlg('Falha efetuando download de atualização. ' + AppPath +
        'update_' + RemoteVersion + '\' + UpdatePackageName, mtError,
        [mbOk], 0);
      Result := false;
    end;

  finally
    FreeAndNil(fileDownload);
    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;
end;

procedure THCIAwsSecManCli.EditServerChange(Sender: TObject);
var
  StatusServer: String;
begin

  StatusServer := EditServer.Text;

  if StatusServer.equals('Ligado') then

    EditServer.Color := clLime

  else if StatusServer.equals('Desligado') then

    EditServer.Color := clLtGray

  else if StatusServer.equals('Ligando') then

    EditServer.Color := clYellow

  else if StatusServer.equals('Desligando') then

    EditServer.Color := clYellow
  else

    EditServer.Color := clWhite;

end;

function THCIAwsSecManCli.GetUpdateVersion(): string;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  RemoteVersion: String;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;
begin

  lResponse := TStringStream.Create('');

  try
    try

      lURL := URLS3Version;

      Http := TIdHTTP.Create(nil);

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);

      RemoteVersion := JSonValue.GetValue<string>('version');

      Result := RemoteVersion;

      JSonValue.Free;

    except

    end;

  finally
    lResponse.Free();
    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

function THCIAwsSecManCli.AccessServerTest(Token: String): String;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  RetornoChamada: String;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;

begin

  lResponse := TStringStream.Create('');
  try
    try

      Screen.Cursor := crHourglass;

      lURL := URLServicoAWSSecManTeste + Token;

      Http := TIdHTTP.Create(nil);

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);

      RetornoChamada := JSonValue.GetValue<string>('response');
      JSonValue.Free;

      if (RetornoChamada.equals('true')) then
        MessageDlg('Validação efetuada com sucesso. Token é válido.',
          mtInformation, [mbOk], 0)
      else
        MessageDlg('Validação falhou. Token não é válido. [' + Token + ']',
          mtError, [mbOk], 0);

    except

      on E: Exception do
      begin
        MessageDlg('Validação falhou ' + E.Message, mtError, [mbOk], 0);
      end;

    end;

  finally
    Screen.Cursor := crDefault;
    lResponse.Free();

    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

function THCIAwsSecManCli.AccessServer(Token: String; Hash: String): String;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;

begin

  lResponse := TStringStream.Create('');
  try
    try
      lURL := URLServicoAWSSecMan + Token + '/hash/' + Hash + '/version/' +
        AppVersion;

      Http := TIdHTTP.Create(nil);

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);

      JSonValue.Free;

      StatusBar1.Panels[0].Text := 'Atualização de IP efetuada com sucesso';

      Application.ProcessMessages;

    except

      on E: Exception do
      begin

        StatusBar1.Panels[0].Text := 'Erro executando atualização de IP ' +
          E.Message;

      end;

    end;

  finally
    lResponse.Free();
    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

function THCIAwsSecManCli.VerifyStatusServerSemToken(): String;
var
  Token: String;
begin

  Token := LeIni('Config', 'Token');

  if (not Token.Trim.IsEmpty) then
    VerifyStatusServer(Token);

end;

function THCIAwsSecManCli.VerifyStatusServer(Token: String): String;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  RetornoChamada: String;
  StatusServer: String;
  IPServer: String;
  NameServer: String;
  GroupServer: String;
  JSonValue: TJSonValue;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;

begin

  StatusBar1.Panels[0].Text := 'Verificando Status do Servidor';

  Application.ProcessMessages;

  IPServer := '';
  NameServer := '';
  GroupServer := '';

  lResponse := TStringStream.Create('');
  try
    try
      lURL := URLServicoStatusServer + Token;

      Http := TIdHTTP.Create(nil);

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);

      RetornoChamada := JSonValue.GetValue<string>('response');

      if (RetornoChamada.equals('true')) then
      begin
        StatusServer := JSonValue.GetValue<string>('status');

        try
          GroupServer := JSonValue.GetValue<string>('group');
          ServerGroup := GroupServer;
        except
        end;

        if StatusServer.equals('running') then
        begin
          StatusServer := 'Ligado';
          ServerIP := JSonValue.GetValue<string>('ip');

          IPServer := JSonValue.GetValue<string>('ip');
          NameServer := JSonValue.GetValue<string>('name');

        end
        else if StatusServer.equals('stopped') then
        begin
          StatusServer := 'Desligado';

        end
        else if StatusServer.equals('pending') then
        begin
          StatusServer := 'Ligando';

        end
        else if StatusServer.equals('stopping') then
        begin
          StatusServer := 'Desligando';

        end;

      end
      else
      begin
        StatusServer := '';
      end;

      EditServer.Text := StatusServer;
      EditIP.Text := ServerIP;
      EditName.Text := NameServer;
      EditGroup.Text := GroupServer;

      if (StatusServer.equals('Desligado')) then
        ButtonLigarServer.Enabled := true
      else
        ButtonLigarServer.Enabled := false;

      JSonValue.Free;

      StatusBar1.Panels[0].Text := 'Status do Servidor: ' + StatusServer;

      Application.ProcessMessages;

    except

      on E: Exception do
      begin

        StatusBar1.Panels[0].Text := 'Erro verificando Status do Servidor ' +
          E.Message;

      end;

    end;

  finally
    lResponse.Free();

    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

function THCIAwsSecManCli.StartServer(Token: String): String;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;
begin

  lResponse := TStringStream.Create('');
  try
    try
      lURL := URLServicoStartServer + Token;

      Http := TIdHTTP.Create(nil);

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);

      JSonValue.Free;

      EditServer.Text := 'Ligando';

      Timer1.Enabled := true;

      StatusBar1.Panels[0].Text := 'Aguarde, ligando Servidor.';

      Application.ProcessMessages;

    except

      on E: Exception do
      begin

        StatusBar1.Panels[0].Text := 'Erro ligando Servidor ' + E.Message;

      end;

    end;

  finally
    lResponse.Free();

    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

procedure THCIAwsSecManCli.DesconectarUsurio1Click(Sender: TObject);
var
  User: String;
begin

  User := ListUserBoxSelectedItem;

  if (User.EndsWith(' (Conectado)')) then
    User := User.Substring(0, User.Length - 12);

  if ((ListUserBoxSelectedItem.IsEmpty) or
    (Application.MessageBox(PChar('Deseja realmente desconectar o usuário (' +
    User + ') ?'), 'Atenção!', mb_IconQuestion + MB_DEFBUTTON2 + mb_YesNo)
    = idNo)) then
    Exit();

  Screen.Cursor := crHourglass;

  DisconnectServerUser(User);

  ButtonListUsers.Enabled := true;

  Screen.Cursor := crDefault;

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
      // begin
      // repeat
      // dRunning := WaitForSingleObject(piProcess.hProcess, 100);
      // Application.ProcessMessages();
      // repeat
      // dRead := 0;
      // ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);
      // pBuffer[dRead] := #0;
      //
      // OemToAnsi(pBuffer, pBuffer);
      // retorno := retorno + String(pBuffer);
      // until (dRead < CReadBuffer);
      // until (dRunning <> WAIT_TIMEOUT);
      // CloseHandle(piProcess.hProcess);
      // CloseHandle(piProcess.hThread);
      // end;

      CloseHandle(hRead);
    CloseHandle(hWrite);

    Result := retorno;
  end;
end;

function THCIAwsSecManCli.isCNPJ(CNPJ: string): Boolean;
var
  dig13, dig14: string;
  sm, I, r, peso: Integer;
begin
  // length - retorna o tamanho da string do CNPJ (CNPJ é um número formado por 14 dígitos)
  if ((CNPJ = '00000000000000') or (CNPJ = '11111111111111') or
    (CNPJ = '22222222222222') or (CNPJ = '33333333333333') or
    (CNPJ = '44444444444444') or (CNPJ = '55555555555555') or
    (CNPJ = '66666666666666') or (CNPJ = '77777777777777') or
    (CNPJ = '88888888888888') or (CNPJ = '99999999999999') or
    (Length(CNPJ) <> 14)) then
  begin
    isCNPJ := false;
    Exit;
  end;

  // "try" - protege o código para eventuais erros de conversão de tipo através da função "StrToInt"
  try
    { *-- Cálculo do 1o. Digito Verificador --* }
    sm := 0;
    peso := 2;
    for I := 12 downto 1 do
    begin
      // StrToInt converte o i-ésimo caractere do CNPJ em um número
      sm := sm + (StrToInt(CNPJ[I]) * peso);
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
    for I := 13 downto 1 do
    begin
      sm := sm + (StrToInt(CNPJ[I]) * peso);
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
  Result := Result + StringOfChar('0', 6 - Length(us)) + us;
end;

function THCIAwsSecManCli.DownloadFile(URL: String;
  ArquivoDestino: String): Boolean;
var
  fileDownload: TFileStream;
  lURL: String;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;
begin
  try

    try

      StatusBar1.Panels[0].Text := 'Baixando arquivo';

      Application.ProcessMessages;

      fileDownload := TFileStream.Create(ArquivoDestino, fmCreate);

      lURL := URL;

      Http := TIdHTTP.Create(nil);

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura * 20;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      Http.Get(lURL, fileDownload);

      StatusBar1.Panels[0].Text := '';

      Application.ProcessMessages;

      if (not FileExists(ArquivoDestino)) then
      begin
        Result := false;
        MessageDlg('Erro efetuando download', mtError, [mbOk], 0);
        Exit;
      end
      else
      begin
        Result := true;
        MessageDlg('Arquivo salvo em ' + ArquivoDestino, mtInformation,
          [mbOk], 0);
        Exit;
      end;

    except
      on E: Exception do
      begin

        MessageDlg('Erro efetuando download ' + E.Message, mtError, [mbOk], 0);
        Result := false;

      end;

    end;

  finally
    FreeAndNil(fileDownload);
    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;
end;

procedure THCIAwsSecManCli.DBGrid1CellClick(Column: TColumn);
var
  InitialDir: String;
  DownloadDir: String;
  ArquivoDestino: String;
  URL: String;
begin

  DownloadDir := '';
  ArquivoDestino := '';

  if (Column.Index < 3) or (Column.Index > 5) then
    Exit();

  InitialDir := GetEnvironmentVariable('USERPROFILE') + '\Downloads';

  if Win32MajorVersion >= 6 then
    with TFileOpenDialog.Create(nil) do
      try
        Title := 'Selecione a pasta destino';
        Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];
        OkButtonLabel := 'Selecione';
        DefaultFolder := InitialDir;
        FileName := '';
        if Execute then
          DownloadDir := FileName;
      finally
        Free;
      end
  else if SelectDirectory('Selecione a pasta destino', InitialDir, InitialDir,
    [sdNewUI, sdNewFolder]) then
  begin
    DownloadDir := InitialDir;
  end;

  if (DownloadDir = '') then
    Exit();

  if (Column.Index = 3) then
  begin
    ArquivoDestino := DownloadDir + '\boleto_' +
      FaturasDataSetDocumento.AsString + '.pdf';
    URL := FaturasDataSetBoleto.AsString;
  end
  else if (Column.Index = 4) then
  begin
    ArquivoDestino := DownloadDir + '\NFSE_' +
      FaturasDataSetDocumento.AsString + '.pdf';
    URL := FaturasDataSetPDF.AsString;
  end
  else
  begin
    ArquivoDestino := DownloadDir + '\XML_NFSE__' +
      FaturasDataSetDocumento.AsString + '.xml';
    URL := FaturasDataSetXML.AsString;
  end;

  DownloadFile(URL, ArquivoDestino);

end;

procedure THCIAwsSecManCli.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
Var
  xValue: Variant;
  Bitmap: TBitmap;
  fixRect: TRect;
  bmpWidth: Integer;
  imgIndex: Integer;
  vvLargura, vvLeft: Integer;
begin
  vvLargura := 25;
  vvLeft := 1;

  if not odd(DBGrid1.DataSource.DataSet.RecNo) then // se for ímpar
  begin
    if not(gdSelected in State) then // se a célula não está selecionada
    begin
      DBGrid1.Canvas.Brush.Color := $00D2FFFF; // define uma cor de fundo
    end;
  end
  else
  begin
    if not(gdSelected in State) then
    // se a célula não está selecionada
    begin
      DBGrid1.Canvas.Brush.Color := clWhite; // define uma cor de fundo
    end;
  end;

  If gdSelected in State Then
    DBGrid1.Canvas.Brush.Color := claqua;

  IF (not FaturasDataSetData.AsString.IsEmpty) then
  begin
    if FaturasDataSetData.asdatetime < Date() then
      DBGrid1.Canvas.Font.Color := clRed
    Else
      DBGrid1.Canvas.Font.Color := clBlack;
  end
  else
    DBGrid1.Canvas.Font.Color := clBlack;

  if Column.Field.Value = Null then
  begin
    if Column.Field.DataType in [FtFloat, ftInteger] then
      xValue := 0
    else
      xValue := ''
  end
  else
    xValue := Column.Field.Value;

  if Column.Field.DataType in [FtFloat, ftInteger] then
    // xValue := ALLTRIM(formata(strtofloat(xValue), Column.Field.DisplayWidth, Column.Field.Tag))
  else
    xValue := Column.Field.AsString;

  DBGrid1.Canvas.FillRect(Rect);

  fixRect := Rect;
  if UpperCase(Column.FieldName) = 'BOLETO' then
  begin
    Bitmap := TBitmap.Create;
    try
      ImageList1.GetBitmap(0, Bitmap);
      bmpWidth := vvLargura + 4;
      fixRect.Left := Rect.Left + 10;
      fixRect.Right := Rect.Left + bmpWidth;
      if Bitmap <> nil then
        DBGrid1.Canvas.StretchDraw(fixRect, Bitmap);
    finally
      Bitmap.Free;
    end;
    fixRect := Rect;
    fixRect.Left := fixRect.Left + bmpWidth;
  end;
  fixRect := Rect;

  if UpperCase(Column.FieldName) = 'PDF' then
  begin
    Bitmap := TBitmap.Create;
    try
      ImageList1.GetBitmap(1, Bitmap);
      bmpWidth := vvLargura;
      fixRect.Left := Rect.Left + vvLeft;
      fixRect.Right := Rect.Left + bmpWidth;
      if Bitmap <> nil then
        DBGrid1.Canvas.StretchDraw(fixRect, Bitmap);
    finally
      Bitmap.Free;
    end;
    fixRect := Rect;
    fixRect.Left := fixRect.Left + bmpWidth;
  end;

  fixRect := Rect;
  if UpperCase(Column.FieldName) = 'XML' then
  begin
    Bitmap := TBitmap.Create;
    try
      ImageList1.GetBitmap(2, Bitmap);
      bmpWidth := vvLargura;
      fixRect.Left := Rect.Left + vvLeft;
      fixRect.Right := Rect.Left + bmpWidth;
      if Bitmap <> nil then
        DBGrid1.Canvas.StretchDraw(fixRect, Bitmap);
    finally
      Bitmap.Free;
    end;
    fixRect := Rect;
    fixRect.Left := fixRect.Left + bmpWidth;
  end;

  if (UpperCase(Column.FieldName) <> 'BOLETO') and
    (UpperCase(Column.FieldName) <> 'PDF') and
    (UpperCase(Column.FieldName) <> 'XML') then
  begin
    if Column.Field.DataType in [FtFloat, ftInteger] then
      DBGrid1.Canvas.textOut(Rect.Right - DBGrid1.Canvas.TextExtent(xValue).cx -
        3, Rect.top, xValue)
    Else
      DBGrid1.Canvas.TextRect(Rect, Rect.Left, Rect.top, xValue);
  end;

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

THCIAwsSecManCli.AppVersion := '8';

THCIAwsSecManCli.IgnoreUpdates := false;

THCIAwsSecManCli.HasAdminRights := false;

THCIAwsSecManCli.DebugExec := false;

THCIAwsSecManCli.LoggedOnPortal := false;

THCIAwsSecManCli.TimeoutConexao := 5000;
THCIAwsSecManCli.TimeoutLeitura := 60000;

THCIAwsSecManCli.AppIniFile := 'hciconfig.ini';

THCIAwsSecManCli.UpdatePackageName := 'package.zip';

THCIAwsSecManCli.ClientTSPlus := 'ClientTSPlus.exe';

THCIAwsSecManCli.URLS3Version :=
  'http://hci-aws-sec-man-cli-updates.s3-website-us-east-1.amazonaws.com/CurrentVersion.json';

THCIAwsSecManCli.URLS3Root :=
  'http://hci-aws-sec-man-cli-updates.s3-website-us-east-1.amazonaws.com/';

THCIAwsSecManCli.URLServicoAWSSecManTeste :=
  'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/testconn/token/';

THCIAwsSecManCli.URLServicoAWSSecMan :=
  'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/token/';

THCIAwsSecManCli.URLServicoStatusServer :=
  'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/statusserver/token/';

THCIAwsSecManCli.URLServicoStartServer :=
  'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/startserver/token/';

THCIAwsSecManCli.URLServicoBuscaFaturas :=
  'http://servicos.hci.com.br/chamados/datasnap/rest/TConta/ListarContasEmAberto?ddd=81&numero=96302385&cnpj=';

end.
