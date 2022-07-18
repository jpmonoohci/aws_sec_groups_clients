unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdCustomHTTPServer,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdHTTPServer, Server.Runner,
  Vcl.StdCtrls, IdTCPConnection, IdTCPClient, IdHTTP, IdAuthentication,
  Vcl.ExtCtrls, Vcl.Mask, Registry, System.UITypes, IdHashMessageDigest,
  System.JSON, Vcl.ComCtrls, IniFiles, ShellApi, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL,
  IdSSLOpenSSL, System.Zip, IOUtils, Vcl.Menus, ClipBrd, FrmLogin, Data.DB,
  Vcl.Grids, Vcl.DBGrids, Datasnap.DBClient, Datasnap.Provider,
  System.ImageList, Vcl.ImgList, FileCtrl, MidasLib, Vcl.Samples.Spin, FrmPix,
  TCustomIdHTTPUnit;

type
  THCIAwsSecManCli = class(TForm)
    IdHTTP1: TIdHTTP;
    Timer1: TTimer;
    ButtonSalvar: TButton;
    ButtonTeste: TButton;
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
    ComboBoxCNPJ: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    ButtonLogoffFinanceiro: TButton;
    PageControl2: TPageControl;
    TabFaturas: TTabSheet;
    TabServicos: TTabSheet;
    Label7: TLabel;
    SpinEditQtd: TSpinEdit;
    Label8: TLabel;
    ButtonPix: TButton;
    Label9: TLabel;
    LabelValorPix: TLabel;
    PnlLicence: TPanel;
    PnlPix: TPanel;
    PixDataSource: TDataSource;
    PixDBGrid: TDBGrid;
    Label10: TLabel;
    PixDataSet: TClientDataSet;
    PixDataSetStatus: TStringField;
    PixDataSetDtCriacao: TStringField;
    PixDataSetDtValidade: TStringField;
    PixDataSetValor: TStringField;
    PixDataSetQR: TMemoField;
    PixDataSetPix: TStringField;
    PixDataSetDescricao: TStringField;

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
    procedure ComboBoxCNPJChange(Sender: TObject);
    procedure ButtonLogoffFinanceiroClick(Sender: TObject);
    procedure SpinEditQtdChange(Sender: TObject);
    function GetLicensesCosts(Token: String; Amount: Integer): String;
    procedure ButtonPixClick(Sender: TObject);
    function GetPix(Token: String): Boolean;
    function CreatePix(Token: String; LicenseCost: Double;
      CustomerDocument: String; CustomerName: String;
      PixDescription: String): Boolean;
    procedure BuscaHistoricoPix();
    procedure PageControl2Change(Sender: TObject);
    procedure PixDBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    function formataDataJSON(Data: String): String;
    procedure PixDBGridCellClick(Column: TColumn);
    procedure CarregaFormPix(DtCriacao: String; DtValidade: String;
      Status: String; Valor: String; Descricao: String; QRCode: String;
      CopiaECola: String);

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
    class var NomeCliente: String;
    class var CNPJsFiliais: TStringList;
    class var NomesFiliais: TStringList;
    class var URLServicoPixLicenseCost: String;
    class var CustoLicencasPix: Double;
    class var URLServicoPixCreate: String;
    class var URLServicoPixGet: String;
    class var URLServicoPixCancel: String;

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
  I: Integer;

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
        NomeCliente := FormLogin.NomeCliente;

        if (Assigned(CNPJsFiliais)) then
        begin
          CNPJsFiliais.Clear;
          NomesFiliais.Clear;
        end;

        ComboBoxCNPJ.AddItem(NomeCliente, nil);

        NomesFiliais := FormLogin.NomesFiliais;
        CNPJsFiliais := FormLogin.CNPJsFiliais;

        for I := 0 to NomesFiliais.Count - 1 do
        begin
          ComboBoxCNPJ.AddItem(NomesFiliais[I], nil);
        end;

        ComboBoxCNPJ.ItemIndex := 0;
        CarregaFaturas(CNPJCliente);

        PageControl2.ActivePageIndex := 0;

      end
      else
        PageControl1.ActivePageIndex := 0;

    finally
      FormLogin.Free;
    end;

  end;

end;

procedure THCIAwsSecManCli.PageControl2Change(Sender: TObject);
begin
  if ((PageControl2.ActivePageIndex = 1)) then
    BuscaHistoricoPix();
end;

procedure THCIAwsSecManCli.BuscaHistoricoPix();
begin

  Screen.Cursor := crHourglass;
  Application.ProcessMessages;

  SpinEditQtd.Value := 0;

  if not GetPix(AppToken) then
    GetPix(AppToken);

  Screen.Cursor := crDefault;
  Application.ProcessMessages;

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

      if (Resposta.IsEmpty) then
      begin

        StatusBar1.Panels[0].Text := 'Empresa não possui faturas';

        Application.ProcessMessages;

        Exit();
      end;

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

procedure THCIAwsSecManCli.ComboBoxCNPJChange(Sender: TObject);
var
  CNPJ: String;
begin

  if (ComboBoxCNPJ.ItemIndex > 0) then
  begin
    CNPJ := CNPJsFiliais[ComboBoxCNPJ.ItemIndex - 1];
    CarregaFaturas(CNPJ);
  end
  else
    CarregaFaturas(CNPJCliente);

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

      lURL := 'http://' + ServerIP + ':9998/PingServer?token=' + AppToken;

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

procedure THCIAwsSecManCli.PixDBGridCellClick(Column: TColumn);
begin

  CarregaFormPix(PixDataSetDtCriacao.AsString, PixDataSetDtValidade.AsString,
    PixDataSetStatus.AsString, PixDataSetValor.AsString,
    PixDataSetDescricao.AsString, PixDataSetQR.AsString,
    PixDataSetPix.AsString);

end;

procedure THCIAwsSecManCli.CarregaFormPix(DtCriacao: String; DtValidade: String;
  Status: String; Valor: String; Descricao: String; QRCode: String;
  CopiaECola: String);
var
  FormPix: TForm1;
begin

  FormPix := TForm1.Create(self);
  FormPix.AppToken := AppToken;

  FormPix.TimeoutConexao := TimeoutConexao;
  FormPix.TimeoutLeitura := TimeoutLeitura;

  FormPix.DtCriacao := DtCriacao;
  FormPix.DtValidade := DtValidade;
  FormPix.Status := Status;
  FormPix.Valor := Valor;
  FormPix.Descricao := Descricao;
  FormPix.QRCode := QRCode;
  FormPix.CopiaECola := CopiaECola;

  FormPix.ShowModal;

  FormPix.Free;

end;

procedure THCIAwsSecManCli.PixDBGridDrawColumnCell(Sender: TObject;
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

  if not odd(PixDBGrid.DataSource.DataSet.RecNo) then // se for ímpar
  begin
    if not(gdSelected in State) then // se a célula não está selecionada
    begin
      PixDBGrid.Canvas.Brush.Color := $00D2FFFF; // define uma cor de fundo
    end;
  end
  else
  begin
    if not(gdSelected in State) then
    // se a célula não está selecionada
    begin
      PixDBGrid.Canvas.Brush.Color := clWhite; // define uma cor de fundo
    end;
  end;

  If gdSelected in State Then
    PixDBGrid.Canvas.Brush.Color := claqua;

  IF (not PixDataSetStatus.AsString.IsEmpty) then
  begin
    if PixDataSetStatus.AsString = 'ATIVA' then
      PixDBGrid.Canvas.Font.Color := clRed
    Else
      PixDBGrid.Canvas.Font.Color := clBlack;
  end
  else
    PixDBGrid.Canvas.Font.Color := clBlack;

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

  PixDBGrid.Canvas.FillRect(Rect);

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
        PixDBGrid.Canvas.StretchDraw(fixRect, Bitmap);
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
        PixDBGrid.Canvas.StretchDraw(fixRect, Bitmap);
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
      PixDBGrid.Canvas.textOut(Rect.Right - DBGrid1.Canvas.TextExtent(xValue).cx
        - 3, Rect.top, xValue)
    Else
      PixDBGrid.Canvas.TextRect(Rect, Rect.Left, Rect.top, xValue);
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

    StatusBar1.Panels[0].Text := 'Erro conectando ao servidor';
    Application.ProcessMessages;
    MessageDlg('Erro conectando ao servidor, por favor tente novamente.',
      mtError, [mbOk], 0);
    ButtonListUsers.Enabled := true;
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

procedure THCIAwsSecManCli.ButtonLogoffFinanceiroClick(Sender: TObject);
begin
  LoggedOnPortal := false;
  PageControl1.ActivePageIndex := 0;
end;

procedure THCIAwsSecManCli.ButtonPixClick(Sender: TObject);
begin

  ButtonPix.Enabled := false;

  if ((CustoLicencasPix = 0) or
    (Application.MessageBox(PChar('Deseja realmente efetuar a aquisição de ' +
    SpinEditQtd.Value.ToString + ' novo(s) usuário(s)?'), 'Atenção!',
    mb_IconQuestion + MB_DEFBUTTON2 + mb_YesNo) = idNo)) then
  begin
    ButtonPix.Enabled := true;
    Exit();
  end;


  // CreatePix(AppToken, CustoLicencasPix, CNPJCliente, NomeCliente,
  // 'Aquisição de ' + SpinEditQtd.Value.ToString + ' licencas HCI');

  if (CreatePix(AppToken, CustoLicencasPix, '10511437803', 'Joao Pedro Monoo',
    'Aquisicao de ' + SpinEditQtd.Value.ToString + ' licencas HCI')) then
  begin

    StatusBar1.Panels[0].Text := 'PIX gerado com sucesso';
    Application.ProcessMessages;

    BuscaHistoricoPix();

  end;

  ButtonPix.Enabled := true;

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

  AppToken := Token.Trim;

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
      SSLIO.SSLOptions.SSLVersions := [sslvTLSv1_2];
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

procedure THCIAwsSecManCli.SpinEditQtdChange(Sender: TObject);
var
  Custo: String;
begin

  if (SpinEditQtd.Value = 0) then
  begin
    LabelValorPix.Caption := 'R$ ' + '0,00';
    ButtonPix.Enabled := false;
    Exit;
  end;

  Screen.Cursor := crHourglass;
  ButtonPix.Enabled := false;

  StatusBar1.Panels[0].Text := 'Aguarde, calculando custo de licenças';
  Application.ProcessMessages;

  Custo := GetLicensesCosts(AppToken, SpinEditQtd.Value);

  StatusBar1.Panels[0].Text := '';

  Screen.Cursor := crDefault;

  if (not Custo.IsEmpty) then
  begin

    CustoLicencasPix := StrToFloat(Custo);

    ButtonPix.Enabled := true;

    LabelValorPix.Caption := FormatFloat('R$ #,##0.00', CustoLicencasPix);
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

function THCIAwsSecManCli.GetLicensesCosts(Token: String;
  Amount: Integer): String;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;
  Custo: String;
  Response: String;
begin

  lResponse := TStringStream.Create('');
  try
    try
      lURL := URLServicoPixLicenseCost + '/' + Token + '/amount/' +
        Amount.ToString;

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
      Response := (JSonValue as TJSonObject).Get('response').JSonValue.Value;

      if (Response.equals('true')) then
        Custo := (JSonValue as TJSonObject).Get('value').JSonValue.Value
      else
        Custo := '0,00';

      Result := Custo;

      JSonValue.Free;

      Application.ProcessMessages;

    except

      on E: Exception do
      begin

        StatusBar1.Panels[0].Text := 'Erro calculando custo de licença ' +
          E.Message;
        Result := '0,00';

      end;

    end;

  finally
    lResponse.Free();

    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

function THCIAwsSecManCli.CreatePix(Token: String; LicenseCost: Double;
  CustomerDocument: String; CustomerName: String;
  PixDescription: String): Boolean;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;
  Response: String;
  JsonToSend: TStringStream;
  jsonPair: TJSONPair;
  JSonObject: TJSonObject;
begin

  Screen.Cursor := crHourglass;
  StatusBar1.Panels[0].Text := 'Aguarde gerando pix';
  Application.ProcessMessages;

  lResponse := TStringStream.Create('');

  JSonObject := TJSonObject.Create();

  JSonObject.AddPair(TJSONPair.Create('pix_nome', CustomerName));
  JSonObject.AddPair(TJSONPair.Create('pix_documento', CustomerDocument));
  JSonObject.AddPair(TJSONPair.Create('pix_descricao', PixDescription));
  JSonObject.AddPair(TJSONPair.Create('pix_valor',
    StringReplace(LicenseCost.ToString, ',', '.', [rfReplaceAll,
    rfIgnoreCase])));

  try
    try
      lURL := URLServicoPixCreate + '/' + Token;

      Http := TIdHTTP.Create(nil);

      Http.Request.ContentType := 'application/json';
      Http.Request.CharSet := 'utf-8';

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := true;
      SSLIO := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      SSLIO.SSLOptions.Method := sslvTLSv1;
      SSLIO.SSLOptions.Mode := sslmClient;
      Http.IOHandler := SSLIO;

      JsonToSend := TStringStream.Create(JSonObject.ToString);

      Http.Post(lURL, JsonToSend, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);
      Response := (JSonValue as TJSonObject).Get('response').JSonValue.Value;

      if (Response.equals('true')) then
        Result := true
      else
      begin
        Result := false;
        StatusBar1.Panels[0].Text := 'Erro gerando pix';
      end;

      JSonValue.Free;

      Screen.Cursor := crDefault;
      Application.ProcessMessages;

    except

      on E: Exception do
      begin

        StatusBar1.Panels[0].Text := 'Erro gerando pix ' + E.Message;
        Result := false;
        Screen.Cursor := crDefault;

      end;

    end;

  finally
    lResponse.Free();

    Http.Disconnect;
    FreeAndNil(SSLIO);
    FreeAndNil(Http);

  end;

end;

function THCIAwsSecManCli.GetPix(Token: String): Boolean;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  JSonPixArray: TJSONArray;
  Http: TCustomIdHTTP;
  Custo: String;
  Response: String;
  PixValor: String;
  PixCopiaCola: String;
  PixQRCode: String;
  PixDescricao: String;
  PixDataValidade: String;
  PixDataCriacao: String;
  PixStatus: String;

  PixValorForm: String;
  PixCopiaColaForm: String;
  PixQRCodeForm: String;
  PixDescricaoForm: String;
  PixDataValidadeForm: String;
  PixDataCriacaoForm: String;
  PixStatusForm: String;
  I: Integer;
  PixTemAtivo: Boolean;
begin

  StatusBar1.Panels[0].Text := 'Aguarde, buscando informações';
  Application.ProcessMessages;

  lResponse := TStringStream.Create('');
  try
    try
      lURL := URLServicoPixGet + '/' + Token;

      Http := TCustomIdHTTP.Create(nil);

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);
      Response := (JSonValue as TJSonObject).Get('response').JSonValue.Value;

      PixTemAtivo := false;

      if (Response.equals('true')) then
      begin

        PixDataSet.EmptyDataSet;

        JSonValue := (JSonValue as TJSonObject).Get('pix').JSonValue;
        JSonPixArray := JSonValue as TJSONArray;

        for I := 0 to JSonPixArray.Size - 1 do

        begin

          PixDataSet.Append;

          PixValor := (JSonPixArray.Get(I) as TJSonObject).Get('pix_valor')
            .JSonValue.Value;

          PixDataSetValor.AsFloat := StrToFloat(PixValor.Replace('.', ','));

          PixQRCode := (JSonPixArray.Get(I) as TJSonObject).Get('pix_qrcodeb64')
            .JSonValue.Value;

          PixDataSetQR.AsString := PixQRCode;

          PixCopiaCola := (JSonPixArray.Get(I) as TJSonObject)
            .Get('pix_txt_qrcode').JSonValue.Value;

          PixDataSetPix.AsString := PixCopiaCola;

          PixDescricao := (JSonPixArray.Get(I) as TJSonObject)
            .Get('pix_descricao').JSonValue.Value;

          PixDataSetDescricao.AsString := PixDescricao;

          PixDataCriacao := (JSonPixArray.Get(I) as TJSonObject)
            .Get('pix_dt_criacao').JSonValue.Value;

          PixDataSetDtCriacao.AsString := formataDataJSON(PixDataCriacao);

          PixDataValidade := (JSonPixArray.Get(I) as TJSonObject)
            .Get('pix_dt_expiracao').JSonValue.Value;

          PixDataSetDtValidade.AsString := formataDataJSON(PixDataValidade);

          PixStatus := (JSonPixArray.Get(I) as TJSonObject).Get('pix_status')
            .JSonValue.Value;

          PixDataSetStatus.AsString := PixStatus;

          if ((I = 0) and (PixStatus = 'ATIVA')) then
          begin

            PixTemAtivo := true;

            PixValorForm := PixValor;
            PixCopiaColaForm := PixCopiaCola;
            PixQRCodeForm := PixQRCode;
            PixDescricaoForm := PixDescricao;
            PixDataValidadeForm := formataDataJSON(PixDataValidade);
            PixDataCriacaoForm := formataDataJSON(PixDataCriacao);
            PixStatusForm := PixStatus;

          end;

          PixDataSet.Post;

        end;

        PixDataSet.First;

        StatusBar1.Panels[0].Text := 'Transações pix carregadas';
        Application.ProcessMessages;

        if (PixTemAtivo) then

        begin

          CarregaFormPix(PixDataCriacaoForm, PixDataValidadeForm, PixStatusForm,
            PixValorForm, PixDescricaoForm, PixQRCodeForm, PixCopiaColaForm);

          Result := false;

        end
        else
          Result := true;

      end
      else
        Result := false;

      JSonValue.Free;

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
      Str((11 - r): 1, dig13);
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
      Str((11 - r): 1, dig14);

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

  if (Column.Index < 3) or (Column.Index > 5) or
    (FaturasDataSetBoleto.AsString.IsEmpty) then
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
    if not(gdSelected in State) then
    // se a célula não está selecionada
    begin
      DBGrid1.Canvas.Brush.Color := $00D2FFFF;
      // define uma cor de fundo
    end;
  end
  else
  begin
    if not(gdSelected in State) then
    // se a célula não está selecionada
    begin
      DBGrid1.Canvas.Brush.Color := clWhite;
      // define uma cor de fundo
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

function THCIAwsSecManCli.formataDataJSON(Data: String): String;
var
  dataFormatada: String;
begin

  dataFormatada := '';

  dataFormatada := Copy(Data, 9, 2);
  dataFormatada := dataFormatada + '/' + Copy(Data, 6, 2);
  dataFormatada := dataFormatada + '/' + Copy(Data, 1, 4);
  // dataFormatada := dataFormatada + ' ' + Copy(Data, 12, 3);
  // dataFormatada := dataFormatada + ' ' + Copy(Data, 15, 2);
  Result := dataFormatada;

end;

initialization

THCIAwsSecManCli.AppVersion := '9';

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

THCIAwsSecManCli.URLServicoPixLicenseCost :=
  'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/pix/licensecost/token';

// THCIAwsSecManCli.URLServicoPixCreate :=
// 'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/pix/token';
//
// THCIAwsSecManCli.URLServicoPixGet :=
// 'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/pix/token';

THCIAwsSecManCli.URLServicoPixCreate :=
  'http://10.191.253.39:8080/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/pix/token';

THCIAwsSecManCli.URLServicoPixGet :=
  'http://10.191.253.39:8080/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/pix/token';

end.
