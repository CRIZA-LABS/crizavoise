[Setup]
AppName=CrizaVoise
AppVersion=1.0.0
AppPublisher=Criza Labs
AppPublisherURL=https://criza.dev
DefaultDirName={autopf}CrizaVoise
DefaultGroupName=CrizaVoise
OutputDir=Output
OutputBaseFilename=CrizaVoiseSetup
SetupIconFile=windowsunneresourcesapp_icon.ico
LicenseFile=LICENSE
Compression=lzma
SolidCompression=yes

[Files]
Source: "buildwindowsdunnerRelease*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}CrizaVoise"; Filename: "{app}crizavoise.exe"
Name: "{commondesktop}CrizaVoise"; Filename: "{app}crizavoise.exe"
