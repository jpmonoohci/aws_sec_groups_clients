unit Service;

interface

uses
  Vcl.SvcMgr, Vcl.Dialogs, System.Classes, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms,
  IdContext, Vcl.StdCtrls;

type
  TsrvService = class(TService)
    procedure ServiceExecute(Sender: TService);

  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  srvService: TsrvService;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  srvService.Controller(CtrlCode);
end;

function TsrvService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TsrvService.ServiceExecute(Sender: TService);
begin

  while not Self.Terminated do
    ServiceThread.ProcessRequests(true);

end;

end.
