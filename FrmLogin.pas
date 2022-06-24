unit FrmLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Mask, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdSSL,
  IdSSLOpenSSL, System.JSON;

type
  TLogin = class(TForm)
    ButtonLogin: TButton;
    ButtonCancelar: TButton;
    StaticText1: TStaticText;
    EditEmail: TEdit;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    EditSenha: TMaskEdit;
    IdHTTP1: TIdHTTP;
    procedure ButtonCancelarClick(Sender: TObject);
    procedure ButtonLoginClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    function ValidarEmail(email: string): Boolean;
    function doLogin(Token: String; email: String; senha: string): Boolean;
  private
    { Private declarations }
  public
    { Public declarations }

    class var URLServicoLoginPortal: string;
    class var TimeoutConexao: Integer;
    class var TimeoutLeitura: Integer;
    class var AppToken: String;
    class var CNPJCliente: String;
    class var NomeCliente: String;
    class var NomesFiliais: TStringList;
    class var CNPJsFiliais: TStringList;

  end;

var
  Login: TLogin;

implementation

{$R *.dfm}

procedure TLogin.ButtonCancelarClick(Sender: TObject);
begin

  self.Close;
  self.ModalResult := MrCancel;
end;

procedure TLogin.ButtonLoginClick(Sender: TObject);
var
  senha: string;
begin

  if (not ValidarEmail(EditEmail.Text)) then
  begin
    MessageDlg('Por favor, digite um email válido.', mtError, [mbOk], 0);
    exit;
  end;

  senha := EditSenha.Text;

  if (senha.IsEmpty) then
  begin
    MessageDlg('Por favor, digite sua senha.', mtError, [mbOk], 0);
    exit;
  end;

  if (doLogin(AppToken, EditEmail.Text, EditSenha.Text)) then
  begin
    self.Close;
    self.ModalResult := mrOk;
  end

end;

procedure TLogin.FormActivate(Sender: TObject);
begin

  EditEmail.SetFocus;

end;

function TLogin.ValidarEmail(email: string): Boolean;
begin
  email := Trim(UpperCase(email));
  if Pos('@', email) > 1 then
  begin
    Delete(email, 1, Pos('@', email));
    Result := (Length(email) > 0) and (Pos('.', email) > 2) and
      (Pos(' ', email) = 0);
  end
  else
  begin
    Result := False;
  end;
end;

function TLogin.doLogin(Token: String; email: String; senha: string): Boolean;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonObj: TJSONObject;
  GrupoCNPJObj: TJSONObject;
  JSonValue: TJSONValue;
  JSonArray: TJSONArray;
  RetornoChamada: String;
  MensagemErroChamada: String;
  SSLIO: TIdSSLIOHandlerSocketOpenSSL;
  Http: TIdHTTP;
  i: Integer;
  CNPJ: String;

begin

  lResponse := TStringStream.Create('');
  try
    try

      Screen.Cursor := crHourglass;

      lURL := URLServicoLoginPortal + Token + '/email/' + email +
        '/senha/' + senha;

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

      JSonObj := TJSONObject.ParseJSONValue(Resposta) as TJSONObject;

      RetornoChamada := JSonObj.GetValue<string>('response');
      MensagemErroChamada := JSonObj.GetValue<string>('message');

      if (not RetornoChamada.equals('true')) then
      begin
        JSonObj.Free;
        Result := False;
        MessageDlg('Erro ' + MensagemErroChamada, mtError, [mbOk], 0);
        exit;
      end;

      CNPJCliente := JSonObj.GetValue<string>('cnpj');
      NomeCliente := JSonObj.GetValue<string>('nome');

      CNPJsFiliais.Clear;
      NomesFiliais.Clear;

      JSonValue := JSonObj.Get('group_cnpj').JSonValue;
      JSonArray := JSonValue as TJSONArray;

      for i := 0 to JSonArray.Size - 1 do
      begin

        GrupoCNPJObj := (JSonArray.Get(i) as TJSONObject);

        JSonValue := GrupoCNPJObj.Get(0).JSonValue;
        NomesFiliais.Add(JSonValue.Value);

        JSonValue := GrupoCNPJObj.Get(1).JSonValue;
        CNPJ := JSonValue.Value;
        CNPJ := StringReplace(CNPJ, '.', '', [rfReplaceAll, rfIgnoreCase]);
        CNPJ := StringReplace(CNPJ, '/', '', [rfReplaceAll, rfIgnoreCase]);
        CNPJ := StringReplace(CNPJ, '-', '', [rfReplaceAll, rfIgnoreCase]);

        CNPJsFiliais.Add(CNPJ);

      end;

      JSonObj.Free;

      Result := true;

    except

      on E: Exception do
      begin
        Result := False;
        MessageDlg('Login falhou ' + E.Message, mtError, [mbOk], 0);
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

initialization

TLogin.URLServicoLoginPortal :=
  'https://awssecman.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/loginportal/token/';

// TLogin.URLServicoLoginPortal :=
// 'http://10.191.253.39:8080/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/loginportal/token/';

TLogin.NomesFiliais := TStringList.Create();
TLogin.CNPJsFiliais := TStringList.Create();

end.
