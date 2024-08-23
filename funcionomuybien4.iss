; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "WhatsAppSender"
#define MyAppVersion "1.8.0"
#define MyAppExeName "WhatsAppSenderG.jar"
#define MyAppAssocName MyAppName + " File"
#define MyAppAssocExt ".jar"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{2FB019DA-65D7-418B-BC6C-78073A8C7886}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
DefaultDirName={autopf}\{#MyAppName}
ChangesAssociations=yes
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputBaseFilename=WhatsAppSender
SetupIconFile=C:\Users\Juan David\Desktop\WhatsAppSender\whats-removebgmin-removebg-preview.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Dirs]
Name: "{app}"; Permissions: everyone-modify
Name: "{app}\listas"; Permissions: everyone-modify
Name: "{app}\lib"; Permissions: everyone-modify
Name: "{app}\driver"; Permissions: everyone-modify

[Files]
Source: "C:\Users\Juan David\Desktop\WhatsAppSender\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion; Permissions: everyone-modify
Source: "C:\Users\Juan David\Desktop\WhatsAppSender\driver\*"; DestDir: "{app}\driver"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\Users\Juan David\Desktop\WhatsAppSender\lib\*"; DestDir: "{app}\lib"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\Users\Juan David\Desktop\WhatsAppSender\listas"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\Users\Juan David\Desktop\WhatsAppSender\WhatsAppSenderG.jar"; DestDir: "{app}"; Flags: ignoreversion; Permissions: everyone-modify
Source: "C:\Users\Juan David\Desktop\WhatsAppSender\version.json"; DestDir: "{app}"; Flags: ignoreversion; Permissions: everyone-modify
Source: "C:\Users\Juan David\Desktop\WhatsAppSender\README.TXT"; DestDir: "{app}"; Flags: ignoreversion; Permissions: everyone-modify
Source: "C:\Users\Juan David\Desktop\WhatsAppSender\notas.txt"; DestDir: "{app}"; Flags: ignoreversion ; Permissions: everyone-modify
Source: "C:\Users\Juan David\Desktop\WhatsAppSender\jre-8u202-windows-x64.exe"; DestDir: "{tmp}"; Flags: ignoreversion; Permissions: everyone-modify
Source: "C:\Users\Juan David\Desktop\WhatsAppSender\whats-removebgmin-removebg-preview.ico"; DestDir: "{app}"; Flags: ignoreversion; Permissions: everyone-modify
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Registry]
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".myp"; ValueData: ""

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\whats-removebgmin-removebg-preview.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\whats-removebgmin-removebg-preview.ico"; Tasks: desktopicon
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\whats-removebgmin-removebg-preview.ico"


[Code]
function CutJavaVersionPart(var V: string): Integer;
var
  S: string;
  P: Integer;
begin
  if Length(V) = 0 then
  begin
    Result := 0;
  end
  else
  begin
    P := Pos('.', V);
    if P = 0 then P := Pos('_', V);

    if P > 0 then
    begin
      S := Copy(V, 1, P - 1);
      Delete(V, 1, P);
    end
    else
    begin
      S := V;
      V := '';
    end;
    Result := StrToIntDef(S, 0);
  end;
end;

function MaxJavaVersion(V1, V2: string): string;
var
  Part1, Part2: Integer;
  Buf1, Buf2: string;
begin
  Buf1 := V1;
  Buf2 := V2;
  Result := '';
  while (Result = '') and ((Buf1 <> '') or (Buf2 <> '')) do
  begin
    Part1 := CutJavaVersionPart(Buf1);
    Part2 := CutJavaVersionPart(Buf2);
    if Part1 > Part2 then
      Result := V1
    else if Part2 > Part1 then
      Result := V2;
  end;
end;

function GetJavaVersionFromSubKey(RootKey: Integer; SubKeyName: string): string;
var
  Versions: TArrayOfString;
  I: Integer;
begin
  if RegGetSubkeyNames(RootKey, SubKeyName, Versions) then
  begin
    for I := 0 to GetArrayLength(Versions) - 1 do
    begin
      Result := MaxJavaVersion(Result, Versions[I]);
    end;
  end;
end;

function GetJavaVersionFromRootKey(RootKey: Integer): string;
begin
  Result := MaxJavaVersion(
    GetJavaVersionFromSubKey(RootKey, 'SOFTWARE\JavaSoft\Java Runtime Environment'),
    GetJavaVersionFromSubKey(RootKey, 'SOFTWARE\JavaSoft\Java Development Kit'));
end;

function GetJavaVersion: string;
begin
  Result := GetJavaVersionFromRootKey(HKLM);
  if IsWin64 then
  begin
    Result := MaxJavaVersion(Result, GetJavaVersionFromRootKey(HKLM64));
  end;
end;

function IsJavaVersionBelow(Version: string): Boolean;
var
  JavaVersion: string;
begin
  JavaVersion := GetJavaVersion;
  Result := JavaVersion < Version;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  JavaVersion: string;
  ErrorCode: Integer;
begin
  if CurStep = ssInstall then
  begin
    JavaVersion := GetJavaVersion;
    if IsJavaVersionBelow('1.8.0_202') then
    begin
      if MsgBox('Se requiere Java 8-202 o una versión superior. ¿Desea instalar Java ahora?', mbConfirmation, MB_YESNO) = IDYES then
      begin
        ExtractTemporaryFile('jre-8u202-windows-x64.exe');
        Exec(ExpandConstant('{tmp}\jre-8u202-windows-x64.exe'), '', '', SW_SHOW, ewWaitUntilTerminated, ErrorCode);
      end
      else
      begin
        MsgBox('La instalación no puede continuar sin Java 8-202 o una versión superior. Se cancelará la instalación.', mbError, MB_OK);
        Abort;
      end;
    end;
  end;
end;



[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: shellexec postinstall skipifsilent



