object HCIAwsSecManCli: THCIAwsSecManCli
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'HCIAwsSecManCli'
  ClientHeight = 309
  ClientWidth = 637
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
    Left = 192
    Top = 42
    Width = 64
    Height = 13
    Caption = 'Digite o CNPJ'
  end
  object MaskEdit1: TMaskEdit
    Left = 192
    Top = 61
    Width = 118
    Height = 21
    EditMask = '00\.000\.000\/0000\-00;0;_'
    MaxLength = 18
    TabOrder = 0
    Text = ''
  end
  object ButtonSalvar: TButton
    Left = 192
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Salvar'
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
  object StatusBar1: TStatusBar
    AlignWithMargins = True
    Left = 3
    Top = 287
    Width = 631
    Height = 19
    BiDiMode = bdRightToLeft
    BorderWidth = 1
    Panels = <
      item
        Width = 50
      end>
    ParentBiDiMode = False
    SimpleText = #9#9
    ExplicitLeft = -2
    ExplicitTop = 288
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 637
    Height = 286
    ActivePage = TabSheet2
    TabOrder = 5
    object TabSheet1: TTabSheet
      Caption = 'Login'
      ExplicitLeft = 84
      ExplicitTop = 61
      object ButtonLogin: TButton
        Left = 288
        Top = 192
        Width = 75
        Height = 25
        Caption = 'Executar HCI'
        TabOrder = 0
      end
      object EditUserName: TEdit
        Left = 310
        Top = 155
        Width = 121
        Height = 21
        TabOrder = 1
      end
      object StaticText1: TStaticText
        Left = 252
        Top = 159
        Width = 52
        Height = 17
        Caption = 'Username'
        TabOrder = 2
      end
      object StaticText2: TStaticText
        Left = 243
        Top = 80
        Width = 93
        Height = 17
        Caption = 'Status do Servidor'
        TabOrder = 3
      end
      object EditServer: TEdit
        Left = 334
        Top = 76
        Width = 121
        Height = 21
        TabOrder = 4
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Usu'#225'rios'
      ImageIndex = 1
      object ListBoxUser: TListBox
        Left = 21
        Top = 18
        Width = 300
        Height = 215
        ItemHeight = 13
        TabOrder = 0
      end
      object Button2: TButton
        Left = 152
        Top = -64
        Width = 121
        Height = 25
        Caption = 'Listar Usu'#225'rios'
        TabOrder = 1
      end
      object ButtonListUsers: TButton
        Left = 487
        Top = 208
        Width = 123
        Height = 25
        BiDiMode = bdRightToLeft
        Caption = 'Listar Usu'#225'rios'
        ParentBiDiMode = False
        TabOrder = 2
        OnClick = ButtonListUsersClick
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Configura'#231#227'o'
      ImageIndex = 2
      ExplicitLeft = 3
      ExplicitTop = 23
      object EditToken: TEdit
        Left = 256
        Top = 120
        Width = 121
        Height = 21
        TabOrder = 0
      end
      object StaticText3: TStaticText
        Left = 256
        Top = 97
        Width = 33
        Height = 17
        Caption = 'Token'
        TabOrder = 1
      end
      object ButtonSalvarToken: TButton
        Left = 272
        Top = 147
        Width = 83
        Height = 25
        Caption = 'Salvar Token'
        TabOrder = 2
      end
    end
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
    Left = 32
    Top = 288
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = Timer1Fired
    Top = 288
  end
end
