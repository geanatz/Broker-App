[Setup]
AppVersion=0.1.9
AppName=MAT Finance
AppPublisher=Your Company
AppPublisherURL=https://yourwebsite.com
AppSupportURL=https://yourwebsite.com/support
AppUpdatesURL=https://yourwebsite.com/updates
; Install over previous path if exists (legacy), else install to new path
DefaultDirName={localappdata}\\MAT Finance
DefaultGroupName=MAT Finance
OutputDir=..\..\installer\Output
OutputBaseFilename=MATFinanceInstaller
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Silent upgrade support and automatic app closing/restart
AppId={{A6B6C7D8-E9FA-4B1C-8D2E-112233445566}}
CloseApplications=yes
RestartApplications=yes
SetupLogging=yes
DisableWelcomePage=yes
DisableFinishedPage=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\\..\\build\\windows\\x64\\runner\\Release\\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\MAT Finance"; Filename: "{app}\mat_finance.exe"
Name: "{commondesktop}\MAT Finance"; Filename: "{app}\mat_finance.exe"; Tasks: desktopicon

[Run]
; Interactive install: show "Launch" checkbox after finish
Filename: "{app}\mat_finance.exe"; Description: "{cm:LaunchProgram,MAT Finance}"; Flags: nowait postinstall skipifsilent
; Silent install: auto-launch app after upgrade
Filename: "{app}\mat_finance.exe"; Flags: nowait skipifnotsilent

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
end;

















