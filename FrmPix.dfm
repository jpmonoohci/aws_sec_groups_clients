object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'PIX'
  ClientHeight = 255
  ClientWidth = 347
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ImageQRCode: TImage
    Left = 216
    Top = 8
    Width = 105
    Height = 105
    Proportional = True
  end
  object Label1: TLabel
    Left = 23
    Top = 30
    Width = 75
    Height = 13
    Caption = 'Data Cria'#231#227'o:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 23
    Top = 8
    Width = 40
    Height = 13
    Caption = 'Status:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 23
    Top = 52
    Width = 78
    Height = 13
    Caption = 'Data Validade'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 23
    Top = 74
    Width = 32
    Height = 13
    Caption = 'Valor:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 23
    Top = 164
    Width = 58
    Height = 13
    Caption = 'Descri'#231#227'o:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 23
    Top = 131
    Width = 96
    Height = 22
    Caption = 'PIX Copia e Cola: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LblStatus: TLabel
    Left = 117
    Top = 8
    Width = 44
    Height = 13
    Caption = 'LblStatus'
  end
  object LblDtCriacao: TLabel
    Left = 117
    Top = 30
    Width = 60
    Height = 13
    Caption = 'LblDtCriacao'
  end
  object LblDtValidade: TLabel
    Left = 117
    Top = 52
    Width = 64
    Height = 13
    Caption = 'LblDtValidade'
  end
  object LblValor: TLabel
    Left = 117
    Top = 74
    Width = 37
    Height = 13
    Caption = 'LblValor'
  end
  object LblDescricao: TLabel
    Left = 117
    Top = 164
    Width = 59
    Height = 13
    Caption = 'LblDescricao'
  end
  object LblMensagem: TLabel
    Left = 23
    Top = 192
    Width = 273
    Height = 13
    Caption = 'Efetue o pagamento utilizando o Pix Copia e Cola'
    Color = clRed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object LblMensagem1: TLabel
    Left = 23
    Top = 217
    Width = 131
    Height = 13
    Caption = 'ou digitalize o QR Code.'
    Color = clRed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object BtnCopiarPix: TButton
    Left = 125
    Top = 126
    Width = 58
    Height = 25
    Caption = 'Copiar'
    TabOrder = 1
    OnClick = BtnCopiarPixClick
  end
  object BtnFechar: TButton
    Left = 196
    Top = 222
    Width = 125
    Height = 25
    Caption = 'Fechar'
    TabOrder = 0
    OnClick = BtnFecharClick
  end
  object BtnCancelarPIX: TButton
    Left = 239
    Top = 126
    Width = 82
    Height = 25
    Caption = 'Cancelar PIX'
    TabOrder = 2
    OnClick = BtnCancelarPIXClick
  end
  object EditPixCopiaCola: TEdit
    Left = 189
    Top = 128
    Width = 41
    Height = 21
    TabOrder = 3
    Text = 'EditPixCopiaCola'
    Visible = False
  end
end
