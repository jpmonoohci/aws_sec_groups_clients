unit TCustomIdHTTPUnit;

interface

uses
  System.Classes, IdHTTP, IdSSL, IdSSLOpenSSL, IdSSLOpenSSLHeaders, IdCTypes,
  System.SysUtils;

type
  TCustomIdHTTP = class(TIdHTTP)
  public
    constructor Create(AOwner: TComponent);
    Destructor Destroy; override;

    class var myIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  private
    procedure OnStatusInfoEx(ASender: TObject; const AsslSocket: PSSL;
      const AWhere, Aret: TIdC_INT; const AType, AMsg: String);
  end;

  { TCustomIdHTTP }

implementation

constructor TCustomIdHTTP.Create(AOwner: TComponent);

begin
  myIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  with myIOHandler as TIdSSLIOHandlerSocketOpenSSL do
  begin
    OnStatusInfoEx := Self.OnStatusInfoEx;
    SSLOptions.Method := sslvSSLv23;
    SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_1, sslvTLSv1];
  end;

  IOHandler := myIOHandler;

  inherited Create(AOwner);
end;

procedure TCustomIdHTTP.OnStatusInfoEx(ASender: TObject; const AsslSocket: PSSL;
  const AWhere, Aret: TIdC_INT; const AType, AMsg: String);
begin
  SSL_set_tlsext_host_name(AsslSocket, Request.Host);
end;

destructor TCustomIdHTTP.Destroy;
begin
  FreeAndNil(myIOHandler);
  inherited;
end;

end.
