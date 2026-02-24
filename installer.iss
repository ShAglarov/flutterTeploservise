[Setup]
AppName=teploservice_flutter
AppVersion=1.0.0
DefaultDirName={autopf}\teploservice_flutter
DefaultGroupName=teploservice_flutter
OutputDir=installer
OutputBaseFilename=teploservice_flutter_Setup
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=lowest

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\teploservice_flutter"; Filename: "{app}\teploservice_flutter.exe"
Name: "{autodesktop}\teploservice_flutter"; Filename: "{app}\teploservice_flutter.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Run]
Filename: "{app}\teploservice_flutter.exe"; Description: "Launch teploservice_flutter"; Flags: nowait postinstall skipifsilent
