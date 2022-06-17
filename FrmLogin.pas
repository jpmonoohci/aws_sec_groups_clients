unit FrmLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Mask, Vcl.StdCtrls;

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
    procedure ButtonCancelarClick(Sender: TObject);
    procedure ButtonLoginClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
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
begin

  self.Close;
  self.ModalResult := mrOk;

end;

end.
