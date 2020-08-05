{ +--------------------------------------------------------------------------+ }
{ | MM3DRead v0.1 * Status reader program for MM3D device                    | }
{ | Copyright (C) 2020 Pozsár Zsolt <pozsar.zsolt@.szerafingomba.hu>         | }
{ | untcommonproc.pas                                                        | }
{ | Common functions and procedures                                          | }
{ +--------------------------------------------------------------------------+ }

//   This program is free software: you can redistribute it and/or modify it
// under the terms of the European Union Public License 1.1 version.
//
//   This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.

unit untcommonproc; 
{$MODE OBJFPC}{$H-}
interface
uses
  Classes,
  Dialogs,
  INIFiles,
  LResources,
  SysUtils,
 {$IFDEF WIN32}Windows,{$ENDIF}
  dos,
  httpsend;
var
  exepath: shortstring;
  lang: string[2];
  uids: string;
  urls: array[0..63] of string;
  userdir: string;
{$IFDEF WIN32}
const
  CSIDL_PROFILE=40;
  SHGFP_TYPE_CURRENT=0;
{$ENDIF}

{$I config.pas}

function getdatafromdevice(url, uid: string): boolean;
function getexepath: string;
function getlang: string;
function loadconfiguration(filename: string): boolean;
function saveconfiguration(filename: string): boolean;
procedure makeuserdir;

{$IFDEF WIN32}
function SHGetFolderPath(hwndOwner: HWND; nFolder: Integer; hToken: THandle;
         dwFlags: DWORD; pszPath: LPTSTR): HRESULT; stdcall;
         external 'Shell32.dll' name 'SHGetFolderPathA';
{$ENDIF}

Resourcestring
  MESSAGE01='Cannot read configuration file!';
  MESSAGE02='Cannot write configuration file!';
  MESSAGE03='Cannot read data from this URL!';
  MESSAGE04='Cannot save data to cache directory!';

implementation

// get data from controller device via http
function getdatafromdevice(url, uid: string): boolean;
var
  value0, value1, value2, value3: TStringList;
begin
  getdatafromdevice:=true;
  value0:=TStringList.Create;
  value1:=TStringList.Create;
  value2:=TStringList.Create;
  value3:=TStringList.Create;
  with THTTPSend.Create do
  begin
    if not HttpGetText(url+'?uid='+uid+'&value=0',value0) then getdatafromdevice:=false;
    if not HttpGetText(url+'?uid='+uid+'&value=1',value1) then getdatafromdevice:=false;
    if not HttpGetText(url+'?uid='+uid+'&value=2',value2) then getdatafromdevice:=false;
    if not HttpGetText(url+'?uid='+uid+'&value=3',value3) then getdatafromdevice:=false;
    Free;
  end;
  if not getdatafromdevice then showmessage(MESSAGE03) else
  begin
    try
      value0.SaveToFile(userdir+DIR_CACHE+'value0.txt');
      value1.SaveToFile(userdir+DIR_CACHE+'value1.txt');
      value2.SaveToFile(userdir+DIR_CACHE+'value2.txt');
      value3.SaveToFile(userdir+DIR_CACHE+'value3.txt');
    except
      getdatafromdevice:=false;
      showmessage(MESSAGE04);
    end;
  end;
  value0.Free;
  value1.Free;
  value2.Free;
  value3.Free;
end;

// get executable path
function getexepath: string;
var
  p: shortstring;
begin
  fsplit(paramstr(0),exepath,p,p);
  getexepath:=exepath;
end;

// get system language
function getlang: string;
var
{$IFDEF WIN32}
  buffer : pchar;
  size : integer;
{$ENDIF}
  s: string;
begin
 {$IFDEF UNIX}
  s:=getenv('LANG');
 {$ENDIF}
 {$IFDEF WIN32}
  size:=getlocaleinfo (LOCALE_USER_DEFAULT, LOCALE_SABBREVLANGNAME, nil, 0);
  getmem(buffer, size);
  try
    getlocaleinfo (LOCALE_USER_DEFAULT, LOCALE_SABBREVLANGNAME, buffer, size);
    s:=string(buffer);
  finally
    freemem(buffer);
  end;
 {$ENDIF}
  if length(s)=0 then s:='en';
  lang:=lowercase(s[1..2]);
  getlang:=lang;
end;

// load configuration
function loadconfiguration(filename: string): boolean;
var
  b: byte;
  iif: TINIFile;
begin
  iif:=TIniFile.Create(filename);
  loadconfiguration:=true;
  try
    uids:=iif.ReadString('uids','1','');
    for b:=0 to 63 do
      urls[b]:=iif.ReadString('urls',inttostr(b+1),'');
  except
    showmessage(MESSAGE01);
    loadconfiguration:=false;
  end;
  iif.Free;
end;

// save configuration
function saveconfiguration(filename: string): boolean;
var
  b: byte;
  iif: TINIFile;
begin
  iif:=TIniFile.Create(filename);
  saveconfiguration:=true;
  try
    iif.WriteString('uids','1',uids);
    for b:=0 to 63 do
      iif.WriteString('urls',inttostr(b+1),urls[b]);
  except
    saveconfiguration:=false;
    showmessage(MESSAGE02);
  end;
  iif.Free;
end;

// make user's directory
procedure makeuserdir;
{$IFDEF WIN32}
var
  buffer: array[0..MAX_PATH] of char;

  function getuserprofile: string;
  begin
    fillchar(buffer, sizeof(buffer), 0);
    ShGetFolderPath(0, CSIDL_PROFILE, 0, SHGFP_TYPE_CURRENT, buffer);
    result:=string(pchar(@buffer));
  end;
{$ENDIF}

begin
 {$IFDEF UNIX}
  userdir:=getenvironmentvariable('HOME');
 {$ENDIF}
 {$IFDEF WIN32}
  userdir:=getuserprofile;
 {$ENDIF}
  forcedirectories(userdir+DIR_CACHE);
  forcedirectories(userdir+DIR_CONFIG);
end;

end.
