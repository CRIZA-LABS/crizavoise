; CrizaVoise by Criza Labs: Windows installer (Inno Setup 6).
;   flutter build windows --release
;   ISCC.exe installer.iss   (winget install JRSoftware.InnoSetup;
;   per-user installs put it in %LOCALAPPDATA%\Programs\Inno Setup 6)
; Output: dist\CrizaVoise-Setup-1.0.0.exe
;
; Installs per user (no admin rights needed) unless the person chooses
; "all users". Uninstalling never touches business data, which lives in
; %APPDATA%\Criza Labs\CrizaVoise.

#define AppName "CrizaVoise"
; CI passes the tag's version: ISCC /DAppVersion=1.2.3 installer.iss
#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif
#define AppExe "crizavoise.exe"
#define BuildDir "build\windows\x64\runner\Release"

[Setup]
; Never change AppId: Windows uses it to find the installed app for upgrades.
AppId={{7EE07F6F-3F1D-43F5-8720-94DE38052FD1}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=Criza Labs
AppPublisherURL=https://criza.dev
AppSupportURL=https://criza.dev
AppCopyright=Copyright (C) 2026 Criza Labs
VersionInfoVersion={#AppVersion}
VersionInfoDescription={#AppName} by Criza Labs Setup
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir=dist
OutputBaseFilename=CrizaVoise-Setup-{#AppVersion}
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
LicenseFile=LICENSE
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb,*.lib,*.exp,syncfusion_*"
; Microsoft Visual C++ runtime, so the app starts on PCs without the redistributable.
Source: "C:\Windows\Sysnative\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Windows\Sysnative\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Windows\Sysnative\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
