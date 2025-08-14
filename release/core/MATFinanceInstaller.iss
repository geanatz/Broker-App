[Setup]
AppVersion=0.1.7
AppName=MAT Finance
AppPublisher=Your Company
AppPublisherURL=https://yourwebsite.com
AppSupportURL=https://yourwebsite.com/support
AppUpdatesURL=https://yourwebsite.com/updates
; Install over previous path if exists (legacy), else install to new path
DefaultDirName={code:GetInstallDir}
DefaultGroupName=MAT Finance
OutputDir=D:\Repositories\Broker-App\installer\Output
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
Source: "D:\Repositories\Broker-App\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\MAT Finance"; Filename: "{app}\mat_finance.exe"
Name: "{commondesktop}\MAT Finance"; Filename: "{app}\mat_finance.exe"; Tasks: desktopicon

[Run]
; Interactive install: show "Launch" checkbox after finish
Filename: "{app}\mat_finance.exe"; Description: "{cm:LaunchProgram,MAT Finance}"; Flags: nowait postinstall skipifsilent
; Silent install: auto-launch app after upgrade
Filename: "{app}\mat_finance.exe"; Flags: nowait skipifnotsilent

[Code]
function DirExists(const Dir: string): Boolean;
begin
  Result := Dir <> '';
  if Result then
    Result := DirExists(Dir);
end;

function GetInstallDir(Param: string): string;
var legacy: string;
begin
  legacy := ExpandConstant('{localappdata}') + '\\Broker App';
  if DirExists(legacy) then begin
    Result := legacy;
  end else begin
    Result := ExpandConstant('{localappdata}') + '\\MAT Finance';
  end;
end;
function InitializeSetup(): Boolean;
begin
  Result := True;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
end;


