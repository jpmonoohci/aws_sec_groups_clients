unit FrmPix;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  TCustomIdHTTPUnit,
  IdHttp,
  System.JSON, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,
  IdSSLOpenSSL, Vcl.Image.Base64,
  ClipBrd;

type
  TForm1 = class(TForm)
    ImageQRCode: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    BtnCopiarPix: TButton;
    BtnFechar: TButton;
    BtnCancelarPIX: TButton;
    LblStatus: TLabel;
    LblDtCriacao: TLabel;
    LblDtValidade: TLabel;
    LblValor: TLabel;
    LblDescricao: TLabel;
    LblMensagem: TLabel;
    LblMensagem1: TLabel;
    EditPixCopiaCola: TEdit;
    procedure BtnCancelarPIXClick(Sender: TObject);
    function CancelPix(Token: String): Boolean;
    procedure BtnCopiarPixClick(Sender: TObject);
    procedure BtnFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public

    class var URLServicoPixCancel: String;
    class var TimeoutConexao: Integer;
    class var TimeoutLeitura: Integer;
    class var AppToken: String;

    class var DtCriacao: String;
    class var DtValidade: String;
    class var Status: String;
    class var Valor: String;
    class var Descricao: String;
    class var QRCode: String;
    class var CopiaECola: String;
    class var PixTxId: String;
    class var OcultaBotaoCancelar: Boolean;

    { Public declarations }
  end;

var
  FormPix: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BtnCancelarPIXClick(Sender: TObject);
begin

  if (Application.MessageBox(PChar('Deseja realmente cancelar este PIX?'),
    'Atenção!', mb_IconQuestion + MB_DEFBUTTON2 + mb_YesNo) = idYes) then

  begin

    if (CancelPix(AppToken)) then
    begin
      MessageDlg('PIX cancelado com sucesso.', mtInformation, [mbOk], 0);
      self.Close;
    end;

  end;

end;

procedure TForm1.BtnCopiarPixClick(Sender: TObject);
begin

  Clipboard.AsText := EditPixCopiaCola.Text;

  MessageDlg('PIX Copia e Cola copiado para a memória.', mtInformation,
    [mbOk], 0);

  Application.ProcessMessages;
end;

procedure TForm1.BtnFecharClick(Sender: TObject);
begin
  self.Close;
end;

function TForm1.CancelPix(Token: String): Boolean;
var
  lURL: String;
  lResponse: TStringStream;
  Resposta: String;
  JSonValue: TJSonValue;
  JSonPixArray: TJSONArray;
  Http: TCustomIdHTTP;
  Response: String;
begin

  Application.ProcessMessages;

  lResponse := TStringStream.Create('');
  try
    try
      lURL := URLServicoPixCancel + '/' + Token + '/pixtxid/' + PixTxId;

      Http := TCustomIdHTTP.Create(nil);

      Http.ConnectTimeout := TimeoutConexao;
      Http.ReadTimeout := TimeoutLeitura;

      Http.ProtocolVersion := pv1_1;
      Http.HandleRedirects := True;

      Http.Get(lURL, lResponse);

      Resposta := lResponse.DataString;

      JSonValue := TJSonObject.ParseJSONValue(Resposta);
      Response := (JSonValue as TJSonObject).Get('response').JSonValue.Value;

      if (Response.equals('true')) then
        Result := True
      else
        Result := false;

      JSonValue.Free;

      Application.ProcessMessages;

    except

      on E: Exception do
      begin

        MessageDlg('Erro cancelando PIX. ' + E.Message, mtError, [mbOk], 0);
        Result := false;

      end;

    end;

  finally
    lResponse.Free();

    Http.Disconnect;
    FreeAndNil(Http);

  end;

end;

procedure TForm1.FormShow(Sender: TObject);
var
  Base64Str: String;
begin

  LblStatus.Caption := Status;
  LblDtCriacao.Caption := DtCriacao;
  LblDtValidade.Caption := DtValidade;
  LblValor.Caption := Valor;
  LblDescricao.Caption := Descricao;
  EditPixCopiaCola.Text := CopiaECola;

  BtnFechar.SetFocus;

  if (Status.equals('ATIVA')) then
  begin
    BtnCancelarPIX.Enabled := True;
    BtnCancelarPIX.Visible := True;
    BtnCopiarPix.Enabled := True;

    Base64Str := QRCode;

    Base64Str := Base64Str.Replace('data:image/png;base64,', '');

    ImageQRCode.Base64(Base64Str);

  end
  else
  begin
    EditPixCopiaCola.Enabled := false;
    BtnCancelarPIX.Visible := false;
    BtnCopiarPix.Enabled := false;
    ImageQRCode.Visible := false;
    LblMensagem1.Visible := false;

    if (Status.equals('PAGO')) then
      LblMensagem.Caption := 'PIX recebido.'
    else if (Status.equals('INATIVA')) then
      LblMensagem.Caption := 'PIX cancelado, pagamento indisponível.'
    else
      LblMensagem.Caption := 'Pagamento indisponível.'

  end;

  if (OcultaBotaoCancelar) then
    BtnCancelarPIX.Visible := false;

end;

initialization

// TForm1.URLServicoPixCancel :=
// 'http://10.191.253.39:8080/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/pix/cancel/token';

TForm1.URLServicoPixCancel :=
  'https://awssecman-scheduler.hci.app.br/Vkp6d1szSnRgPmcqaih3UyFTLiE9VV43YzVqSF1Icn0/pix/cancel/token';

end.
