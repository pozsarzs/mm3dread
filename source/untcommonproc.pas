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
  dos;
var
  exepath, p: shortstring;
  lang: string[2];
  pathremotefiles: array[0..15] of string;
  s: string;
  userdir: string;
{$IFDEF WIN32}
const
  CSIDL_PROFILE=40;
  SHGFP_TYPE_CURRENT=0;
{$ENDIF}

{$I config.pas}

function getexepath: string;
function getlang: string;
function loadinifile: boolean;
function saveinifile: boolean;
procedure makeuserdir;

{$IFDEF WIN32}
function SHGetFolderPath(hwndOwner: HWND; nFolder: Integer; hToken: THandle;
         dwFlags: DWORD; pszPath: LPTSTR): HRESULT; stdcall;
         external 'Shell32.dll' name 'SHGetFolderPathA';
{$ENDIF}

Resourcestring
  MESSAGE01='Cannot read configuration file!';
  MESSAGE02='Cannot write configuration file!';

implementation

// get executable path
function getexepath: string;
begin
  fsplit(paramstr(0),exepath,p,p);
  getexepath:=exepath;
end;

// get system language
function getlang: string;
{$IFDEF WIN32}
var
  buffer : pchar;
  size : integer;
{$ENDIF}
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

  function GetWindowsTemp: string;
  begin  
    fillchar(buffer,MAX_PATH+1, 0);
    GetTempPath(MAX_PATH, buffer);
    result:=string(pchar(@buffer));
    if result[length(result)]<>'\' then result:=result+'\';
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
