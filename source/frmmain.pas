{ +--------------------------------------------------------------------------+ }
{ | MM3DRead v0.1 * Status reader program for MM3D device                    | }
{ | Copyright (C) 2020 Pozsár Zsolt <pozsar.zsolt@.szerafingomba.hu>         | }
{ | frmmain.pas                                                              | }
{ | Main form                                                                | }
{ +--------------------------------------------------------------------------+ }

//   This program is free software: you can redistribute it and/or modify it
// under the terms of the European Union Public License 1.1 version.
//
//   This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.

unit frmmain;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Buttons, ExtCtrls, untcommonproc, dos;
type
  { TForm1 }
  TForm1 = class(TForm)
    Bevel1: TBevel;
    Bevel10: TBevel;
    Bevel11: TBevel;
    Bevel12: TBevel;
    Bevel13: TBevel;
    Bevel14: TBevel;
    Bevel15: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    Bevel8: TBevel;
    Bevel9: TBevel;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Shape1: TShape;
    Shape10: TShape;
    Shape11: TShape;
    Shape12: TShape;
    Shape13: TShape;
    Shape14: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Shape9: TShape;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    StatusBar1: TStatusBar;
    procedure ComboBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;
var
  Form1: TForm1;
  inifile: string;

implementation

{$R *.lfm}
{ TForm1 }

// read data from URL
procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  getdatafromdevice(ComboBox1.Text, Edit1.Text);
end;

// add URL to list
procedure TForm1.SpeedButton2Click(Sender: TObject);
var
  line: byte;
  thereis: boolean;
begin
  thereis:=false;
  if ComboBox1.Items.Count>0 then
    for line:=0 to ComboBox1.Items.Count-1 do
      if ComboBox1.Items.Strings[line]=ComboBox1.Text then thereis:=true;
  if (not thereis) and (ComboBox1.Items.Count<64) then
    ComboBox1.Items.AddText(ComboBox1.Text);
end;

// remove URL from list
procedure TForm1.SpeedButton3Click(Sender: TObject);
var
  line: byte;
begin
  if ComboBox1.Items.Count>0 then
  begin
    for line:=0 to ComboBox1.Items.Count-1 do
      if ComboBox1.Items.Strings[line]=ComboBox1.Text then break;
    ComboBox1.Items.Delete(line);
    ComboBox1Change(Sender);
  end;
end;

// event of ComboBox1
procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if length(ComboBox1.Text)=0 then
  begin
    SpeedButton1.Enabled:=false;
    SpeedButton2.Enabled:=false;
    SpeedButton3.Enabled:=false;
  end else
  begin
    SpeedButton1.Enabled:=true;
    SpeedButton2.Enabled:=true;
    SpeedButton3.Enabled:=true;
  end;
end;

// events of Form1
procedure TForm1.FormCreate(Sender: TObject);
var
  b: byte;
begin
  makeuserdir;
  getlang;
  getexepath;
  Form1.Caption:=APPNAME+' v.'+VERSION;
  // load configuration
  inifile:=untcommonproc.userdir+DIR_CONFIG+'mm3dread.ini';
  if fsearch('mm3dread.ini',untcommonproc.userdir+DIR_CONFIG)<>''
    then loadconfiguration(inifile);
  Edit1.Text:=untcommonproc.uids;
  for b:=0 to 63 do
    if length(urls[b])>0 then
      ComboBox1.Items.Add(untcommonproc.urls[b]);
  // set position of speedbuttons
  SpeedButton1.Top:=ComboBox1.Top+((ComboBox1.Height-SpeedButton1.Height) div 2);
  SpeedButton2.Top:=SpeedButton1.Top;
  SpeedButton3.Top:=SpeedButton1.Top;
  Edit1.Top:=SpeedButton1.Top;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Bevel2.Width:=(Form1.Width div 2)-6;
  Bevel3.Width:=Bevel2.Width;
  Bevel4.Left:=(Form1.Width div 2)-114;
  Bevel8.Left:=Bevel4.Left;
  Bevel12.Left:=Bevel4.Left;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  b: byte;
begin
  for b:=0 to 63 do
    untcommonproc.urls[b]:='';
  if ComboBox1.Items.Count>0 then
    for b:=0 to ComboBox1.Items.Count-1 do
      untcommonproc.urls[b]:=ComboBox1.Items.Strings[b];
  untcommonproc.uids:=Edit1.Text;
  saveconfiguration(inifile);
end;

end.
