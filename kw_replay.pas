unit kw_replay;

interface

uses
  windows, cnc3_replay, myutils, DIAnsiStringVector, DIRegEx, sysutils,
  Registry, ShlObj;

type
  TKWReplay = class(TCNC3Replay)
  end;

  TKW = class(TCNC3)
    public        
      class function ParseReplay(var AReplay: TKWReplay;
        const APath: string): boolean; overload;
      class function ParseReplay(var AReplay: TKWReplay;
        const APath: string; var AError: string): boolean; overload;   
      class function LoadInfos(var AData: TCNC3Infos): boolean;
      class function GetArmyName(AArmyId: shortint): string;     
      class function GetShortArmyName(AArmyId: shortint): string;  
      class function GetVersionName(AVersionId: string): string;
      
      const RegKey = 'SOFTWARE\Electronic Arts\Electronic Arts\Command and Conquer 3 Kanes Wrath';
      const BinaryName = 'cnc3ep1.exe';                                                
      const ReplayExt = '.KWReplay';
      const data_Version: array[0..2] of TKeyValStore = (
        (Value: '1.00'; sKey: '1.0.2955.37387'),
        (Value: '1.01'; sKey: '1.1.2955.37387'),
        (Value: '1.02'; sKey: '1.2.0.04')
        );
      const data_Armies: array[0..11] of TKeyValStore = (
        (Value: 'Aléatoire'; iKey: 1),
        (Value: 'Observateur'; iKey: 2),   
    		(Value: 'Commentateur'; iKey: 3),
		    (Value: 'GDI'; iKey: 6),
		    (Value: 'Steel Talons'; iKey: 7),
		    (Value: 'ZOCOM'; iKey: 8),
		    (Value: 'NOD'; iKey: 9),
		    (Value: 'Black Hand'; iKey: 10),
		    (Value: 'Marked of Kane'; iKey: 11),
		    (Value: 'Scrin'; iKey: 12),
		    (Value: 'Reaper-17'; iKey: 13),
		    (Value: 'Traveler-59'; iKey: 14)
        );    
      const data_ShortArmies: array[0..11] of TKeyValStore = (
        (Value: 'R'; iKey: 1),
        (Value: 'O'; iKey: 2),
    		(Value: 'C'; iKey: 3),
		    (Value: 'G'; iKey: 6),
		    (Value: 'ST'; iKey: 7),
		    (Value: 'Z'; iKey: 8),
		    (Value: 'N'; iKey: 9),
		    (Value: 'BH'; iKey: 10),
		    (Value: 'MoK'; iKey: 11),
		    (Value: 'S'; iKey: 12),
		    (Value: 'R17'; iKey: 13),
		    (Value: 'T59'; iKey: 14)
        );
      const data_nonPlaying = [2, 3];
  end;
  
implementation
                               
class function TKW.LoadInfos(var AData: TCNC3Infos): boolean;
var reg: TRegistry;
begin
  result := false; 
  AData.LoadSucess := false;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if not reg.OpenKey(TKW.RegKey, false) then
    begin
      reg.free;
      result := false;
      exit;
    end;
    AData.InstallPath := reg.ReadString('InstallPath');
    AData.ReplayFolderName := reg.ReadString('ReplayFolderName');
    AData.UserDataLeafName := reg.ReadString('UserDataLeafName');        
    AData.Language := reg.ReadString('Language');
    AData.Version := reg.ReadInteger('Version');
    AData.ReplayPath := GetDir(
      MyGetFolder(CSIDL_PERSONAL)
      + AData.UserDataLeafName
      + '\'
      + AData.ReplayFolderName
      );
    reg.CloseKey;
    reg.Free;
    AData.LoadSucess := true;
    result := true;
  except
    reg.Free;
  end;
end;

class function TKW.ParseReplay(var AReplay: TKWReplay;
  const APath: string): boolean;
var error: string;
begin
  result := TKW.ParseReplay(AReplay, APath, error);
end;
     
class function TKW.ParseReplay(var AReplay: TKWReplay;
  const APath: string; var AError: string): boolean;
begin         
  result := false;
  AReplay := TKWReplay.Create;
  try
    AReplay.Parse(APath);
    result := true;
  except
    on E:Exception do
    begin
      AError := E.Message;
      AReplay.Free;
      AReplay := nil;
    end;
  end;
end;

class function TKW.GetArmyName(AArmyId: shortint): string;
begin
  result := KeyValFind(AArmyId, TKW.data_Armies, 'Erreur');
end;
         
class function TKW.GetShortArmyName(AArmyId: shortint): string;
begin
  result := KeyValFind(AArmyId, TKW.data_ShortArmies, 'Erreur');
end;

class function TKW.GetVersionName(AVersionId: string): string;
begin             
  result := KeyValFind(AVersionId, TKW.data_Version, 'Erreur');
end;

end.
