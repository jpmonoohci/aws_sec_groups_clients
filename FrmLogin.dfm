object Login: TLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Login'
  ClientHeight = 138
  ClientWidth = 311
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonLogin: TButton
    Left = 136
    Top = 105
    Width = 75
    Height = 25
    Caption = 'Login'
    TabOrder = 0
    OnClick = ButtonLoginClick
  end
  object ButtonCancelar: TButton
    Left = 228
    Top = 105
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 1
    OnClick = ButtonCancelarClick
  end
  object StaticText1: TStaticText
    Left = 24
    Top = 1
    Width = 98
    Height = 17
    Caption = 'Login necess'#225'rio'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
  end
  object EditEmail: TEdit
    Left = 104
    Top = 24
    Width = 169
    Height = 21
    TabOrder = 3
  end
  object StaticText2: TStaticText
    Left = 24
    Top = 31
    Width = 32
    Height = 17
    Caption = 'e-mail'
    TabOrder = 4
  end
  object StaticText3: TStaticText
    Left = 24
    Top = 56
    Width = 33
    Height = 17
    Caption = 'senha'
    TabOrder = 5
  end
  object StaticText4: TStaticText
    Left = 18
    Top = 82
    Width = 204
    Height = 17
    Caption = '* Mesmo login do portal de chamados HCI'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clTeal
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 6
  end
  object EditSenha: TMaskEdit
    Left = 104
    Top = 51
    Width = 169
    Height = 21
    DoubleBuffered = False
    ParentDoubleBuffered = False
    PasswordChar = '*'
    TabOrder = 7
    Text = ''
  end
end
