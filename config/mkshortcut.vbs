'+-----------------------------------------------------------------------------+
'| MM3DRead v0.3 * Status reader program for MM3D device                       |
'| Copyright (C) 2020-2023 Pozsár Zsolt <pozsar.zsolt@szerafingomba.hu>        |
'| mkshortcut.vbs                                                              |
'| Make shortcut                                                               |
'+-----------------------------------------------------------------------------+

set WshShell = WScript.CreateObject("WScript.Shell" )
set oShellLink = WshShell.CreateShortcut(Wscript.Arguments.Named("shortcut") & ".lnk")
oShellLink.TargetPath = Wscript.Arguments.Named("target")
oShellLink.WindowStyle = 1
oShellLink.Save

