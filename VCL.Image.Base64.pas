unit VCL.Image.Base64;

interface

uses
  VCL.Menus, Jpeg, Pngimage, VCL.ExtCtrls,
  VCL.Dialogs, System.Classes, Soap.EncdDecd, Windows;

type
  TImageHelper = class helper for TImage
    procedure Popup;
    procedure OpenClick(Sender: TObject);
    procedure RemoveClick(Sender: TObject);
    function Base64: String; overload;
    procedure Base64(str64: String); overload;
  end;

implementation

uses
  Vcl.Graphics;

{ TImageHelper }

function TImageHelper.Base64: String;
var
  Input, Output: TStringStream;
begin
  Input := TStringStream.Create;
  Output := TStringStream.Create;

  try
    // Self.Picture.SaveToStream(Input);
    Input.Position := 0;
    Soap.EncdDecd.EncodeStream(Input, Output);
    Output.Position := 0;
    Result := Output.DataString;
  finally
    Input.Free;
    Output.Free;
  end;

end;

procedure TImageHelper.Base64(str64: String);
var
  Input, Output: TStringStream;
  graphic: TGraphic;
begin
  Input := TStringStream.Create(str64);
  Output := TStringStream.Create;
  try
    Input.Position := 0;
    Soap.EncdDecd.DecodeStream(Input, Output);
    Output.Position := 0;

    graphic := TPngImage.Create;
    try
      graphic.LoadFromStream(Output);
      Self.Picture.graphic := graphic;
    finally
      graphic.Free;
    end;
  finally
    Input.Free;
    Output.Free;
  end;
end;

procedure TImageHelper.OpenClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  try
    Dialog := TOpenDialog.Create(nil);
    Dialog.Filter := 'JPG (*.jpg) |*.jpg| PNG (*.png)| *.png';
    if Dialog.Execute then
      Self.Picture.LoadFromFile(Dialog.FileName);
  finally
    Dialog.Free;
  end;
end;

procedure TImageHelper.Popup;
var
  PopMenu: TPopupMenu;
  Item: TMenuItem;
begin
  Self.Stretch := True;

  PopMenu := TPopupMenu.Create(nil);

  Item := TMenuItem.Create(PopMenu);
  Item.Caption := 'Abrir imagem';
  Item.OnClick := OpenClick;
  PopMenu.Items.Add(Item);

  Item := TMenuItem.Create(PopMenu);
  Item.Caption := 'Remover';
  Item.OnClick := RemoveClick;
  PopMenu.Items.Add(Item);

  Self.PopupMenu := PopMenu;

end;

procedure TImageHelper.RemoveClick(Sender: TObject);
begin
  Self.Picture := Nil;
end;

end.
