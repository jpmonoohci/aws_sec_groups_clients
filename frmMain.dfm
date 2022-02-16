object HCIAwsSecManCli: THCIAwsSecManCli
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'HCIAwsSecManCli'
  ClientHeight = 193
  ClientWidth = 441
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 152
    Top = 18
    Width = 64
    Height = 13
    Caption = 'Digite o CNPJ'
  end
  object MaskEdit1: TMaskEdit
    Left = 152
    Top = 37
    Width = 118
    Height = 21
    Enabled = False
    EditMask = '00\.000\.000\/0000\-00;0;_'
    MaxLength = 18
    TabOrder = 0
    Text = ''
  end
  object ButtonSalvar: TButton
    Left = 152
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Salvar'
    Enabled = False
    TabOrder = 1
    OnClick = ButtonSalvarClick
  end
  object ButtonTeste: TButton
    Left = 152
    Top = 127
    Width = 89
    Height = 25
    Caption = 'Testar Conex'#227'o'
    TabOrder = 2
    OnClick = ButtonTesteClick
  end
  object ButtonAtualizacao: TButton
    Left = 256
    Top = 127
    Width = 89
    Height = 25
    Caption = 'Testar Execu'#231#227'o'
    TabOrder = 3
    OnClick = ButtonAtualizacaoClick
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    HandleRedirects = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 24
    Top = 96
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = Timer1Fired
    Left = 24
    Top = 40
  end
end
