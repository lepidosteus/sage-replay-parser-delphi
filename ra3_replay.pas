unit ra3_replay;

interface

uses
  windows, cnc3_replay, myutils, DIAnsiStringVector, DIRegEx, sysutils,
  registry, ShlObj;

type
  TRA3Replay = class(TCNC3Replay)     
    public
      procedure Parse(const APath: string);
  end;

  TRA3 = class(TCNC3)
    public        
      class function ParseReplay(var AReplay: TRA3Replay;
        const APath: string): boolean; overload;
      class function ParseReplay(var AReplay: TRA3Replay;
        const APath: string; var AError: string): boolean; overload;
      class function GetArmyName(AArmyId: shortint): string;    
      class function GetShortArmyName(AArmyId: shortint): string;  
      class function GetVersionName(AVersionId: string): string;    
      class function LoadInfos(var AData: TCNC3Infos): boolean;
{
      const RegKey = 'SOFTWARE\Electronic Arts\EA Games\Red Alert 3 Beta';
      const BinaryName = 'RA3Beta.exe';             
      const data_Maps: array[0..3] of TKeyValStore = (
        (Value: 'Cabana Republic'; sKey: 'data/maps/official/map_mp_2_feasel1'),  
        (Value: 'Temple Prime'; sKey: 'data/maps/official/map_mp_2_black1b'),
        (Value: 'Roundhouse Redux'; sKey: 'data/maps/official/map_mp_4_feasel1'),
        (Value: 'Rock Ridge'; sKey: 'data/maps/official/map_mp_4_feasel2')
        );
      const data_Version: array[0..4] of TKeyValStore = ( 
        (Value: '1.00'; sKey: '1.0.3097.26724'),
        (Value: '1.02'; sKey: '1.2.3103.42807'),  
        (Value: '1.03'; sKey: '1.3.3118.21701'),
        (Value: '1.04'; sKey: '1.4.3126.27409'),
        (Value: '1.05'; sKey: '1.5.3142.35637')
        );
      const data_Armies: array[0..3] of TKeyValStore = (
        (Value: 'Empire'; iKey: 2),
        (Value: 'Alliés'; iKey: 4),
    		(Value: 'Aléatoire'; iKey: 7),
		    (Value: 'Soviétiques'; iKey: 8)
        );
      const data_nonPlaying = [7];
}
      const RegKey = 'SOFTWARE\Electronic Arts\Electronic Arts\Red Alert 3';
      const BinaryName = 'RA3.exe';                                         
      const ReplayExt = '.RA3Replay';
      const ReplayHeader = 'RA3 REPLAY HEADER';
      const data_Maps: array[0..40] of TKeyValStore = (
        // 1v1
        (Value: 'Arche secrète'; sKey: 'data/maps/official/map_mp_2_feasel3'),
        (Value: 'Base de combat flottante'; sKey: 'data/maps/official/map_mp_2_feasel4'),
        (Value: 'Chasse neige'; sKey: 'data/maps/official/map_mp_2_feasel5'),
        (Value: 'Force industrielle'; sKey: 'data/maps/official/map_mp_2_feasel6'),
        (Value: 'Ile en feu'; sKey: 'data/maps/official/map_mp_2_feasel8'),
        (Value: 'L''ile éternelle'; sKey: 'data/maps/official/map_mp_2_rao1'),
        (Value: 'Les canaux du carnage'; sKey: 'data/maps/official/map_mp_2_feasel2'),
        (Value: 'Rencontre explosive'; sKey: 'data/maps/official/map_mp_2_feasel7'),
        (Value: 'République de cabana'; sKey: 'data/maps/official/map_mp_2_feasel1'),
        (Value: 'Temple principal'; sKey: 'data/maps/official/map_mp_2_black1b'),
        // 1v1v1
        (Value: 'La forteresse cachée'; sKey: 'data/maps/official/map_mp_3_feasel3'),
        (Value: 'Le cratère du chaos'; sKey: 'data/maps/official/map_mp_3_feasel2'),
        (Value: 'Pyroclasme'; sKey: 'data/maps/official/map_mp_3_feasel4'),
        // 2v2
        (Value: 'Assaut aquatique'; sKey: 'data/maps/official/map_mp_4_ssmith2-remix'),
        (Value: 'Cercle de feu'; sKey: 'data/maps/official/map_mp_4_feasel7'),
        (Value: 'Folie marine'; sKey: 'data/maps/official/map_mp_4_feasel3'),
        (Value: 'Grabuge naval'; sKey: 'data/maps/official/map_mp_4_feasel5'),
        (Value: 'La crête rocheuse'; sKey: 'data/maps/official/map_mp_4_feasel2'),
        (Value: 'Opposition Navale'; sKey: 'data/maps/official/map_mp_4_feasel6'),
        (Value: 'Opposition virulante'; sKey: 'data/maps/official/map_mp_4_stewart_1'),
        (Value: 'Rotonde explosive'; sKey: 'data/maps/official/map_mp_4_feasel1'),
        (Value: 'Territoire hostile'; sKey: 'data/maps/official/map_mp_4_black_xslice'),
        // 1v1v1v1v1
        (Value: 'Affrontements sur la mesa'; sKey: 'data/maps/official/map_mp_5_feasel2'),
        (Value: 'Circus maximum'; sKey: 'data/maps/official/map_mp_5_feasel3'),
        // 3v3
        (Value: 'Carville'; sKey: 'data/maps/official/map_mp_6_ssmith2'),
        (Value: 'Heure zéro'; sKey: 'data/maps/official/map_mp_6_feasel3'),
        (Value: 'Magmageddon'; sKey: 'data/maps/official/map_mp_6_feasel4'),
        (Value: 'Paradis perdu'; sKey: 'data/maps/official/map_mp_6_feasel1'),
        // Cartes bonus
        // Edition collector
        (Value: 'Le village de la tortue'; sKey: 'data/maps/internal/map_mp_2_ssmith1-redux'),
        (Value: 'Mission technique'; sKey: 'data/maps/internal/map_mp_3_feasel1'),
        (Value: 'Dernier recours'; sKey: 'data/maps/internal/map_mp_4_feasel4'),
        (Value: 'Loch en danger'; sKey: 'data/maps/internal/map_mp_5_feasel1'),
        (Value: 'Danger marin'; sKey: 'data/maps/internal/map_mp_6_feasel2'),
        // Warhammer Online
        (Value: 'Age of Wreckoning'; sKey: 'data/maps/internal/map_mp_promo_feasel4'), 
        // Pré-commandes
        (Value: 'Port en crise'; sKey: 'data/maps/internal/map_mp_promo_feasel7'),  
        // Bêta testeurs
        (Value: 'Tortue Noire'; sKey: 'data/maps/internal/map_mp_promo_feasel6'),  
        // EA Store
        (Value: 'Bout du monde'; sKey: 'data/maps/internal/map_mp_promo_feasel5'),     
        // Game
        (Value: 'Attractions fatales'; sKey: 'data/maps/internal/map_mp_promo_feasel2'),
        // Gamestop
        (Value: 'Allée des Dreadnoughts'; sKey: 'data/maps/internal/map_mp_promo_feasel3a'),  
        // Best Buy
        (Value: 'Mauvaise pente'; sKey: 'data/maps/internal/map_mp_promo_feasel1'),       
        // EBGames
        (Value: 'Voie des Dreadnoughts'; sKey: 'data/maps/internal/map_mp_promo_feasel3b')
        );
      const data_Version: array[0..10] of TKeyValStore = (
        (Value: '1.00'; sKey: '1.0.3174.697'),
        (Value: '1.01'; sKey: '1.1.3185.21765'),
        (Value: '1.02'; sKey: '1.2.3194.30243'),
        (Value: '1.03'; sKey: '1.3.3195.25881'),
        (Value: '1.04'; sKey: '1.4.3205.30624'),
        (Value: '1.05'; sKey: '1.5.3227.15829'),
        (Value: '1.06'; sKey: '1.6.3230.17659'),
        (Value: '1.07'; sKey: '1.7.3285.27919'),
        (Value: '1.08'; sKey: '1.8.3314.30153'),
        (Value: '1.09'; sKey: '1.9.3333.26811'),
        (Value: '1.10'; sKey: '1.10.3346.29997')
        );
      const data_Armies: array[0..5] of TKeyValStore = (
        (Value: 'Observateur'; iKey: 1),
        (Value: 'Empire'; iKey: 2),
        (Value: 'Commentateur'; iKey: 3),
        (Value: 'Alliés'; iKey: 4),
    		(Value: 'Aléatoire'; iKey: 7),
		    (Value: 'Soviétiques'; iKey: 8)
        );     
      const data_ShortArmies: array[0..5] of TKeyValStore = (
        (Value: 'O'; iKey: 1),
        (Value: 'E'; iKey: 2),
        (Value: 'C'; iKey: 3),
        (Value: 'A'; iKey: 4),
    		(Value: 'R'; iKey: 7),
		    (Value: 'S'; iKey: 8)
        );
      const data_nonPlaying = [1, 3];
  end;
  
implementation
                            
class function TRA3.LoadInfos(var AData: TCNC3Infos): boolean;
var reg: TRegistry;
begin
  result := false;   
  AData.LoadSucess := false;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if not reg.OpenKey(TRA3.RegKey, false) then
    begin
      reg.free;
      result := false;
      exit;
    end;
    AData.InstallPath := reg.ReadString('Install Dir');
    AData.ReplayFolderName := reg.ReadString('ReplayFolderName');
    AData.UserDataLeafName := reg.ReadString('UserDataLeafName');         
    AData.Language := reg.ReadString('Language');
    AData.Version := 0;
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

class function TRA3.ParseReplay(var AReplay: TRA3Replay;
  const APath: string): boolean;
var error: string;
begin
  result := TRA3.ParseReplay(AReplay, APath, error);
end;
  
class function TRA3.ParseReplay(var AReplay: TRA3Replay;
  const APath: string; var AError: string): boolean;
begin         
  result := false;
  AReplay := TRA3Replay.Create;
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

class function TRA3.GetArmyName(AArmyId: shortint): string;
begin
  result := KeyValFind(AArmyId, TRA3.data_Armies, 'Erreur');
end;
       
class function TRA3.GetShortArmyName(AArmyId: shortint): string;
begin
  result := KeyValFind(AArmyId, TRA3.data_ShortArmies, 'Erreur');
end;

class function TRA3.GetVersionName(AVersionId: string): string;
begin             
  result := KeyValFind(AVersionId, TRA3.data_Version, 'Erreur');
  if (result = 'Erreur')
      and (AVersionId[1] = '1')
      and (AVersionId[2] = '.')
      and (AVersionId[3] = '1')
      and (AVersionId[4] in ['0'..'9']) then
    result := '1.1' + AVersionId[4];
end;

procedure TRA3Replay.Parse(const APath: string);
var buff: array[0..(TCNC3.BuffSize - 1)] of char;
    reg: TDIPerlRegEx;
begin
  if not FileExists(APath) then
    raise Exception.CreateFmt('Cannot parse "%s", this file does not exist', [APath]);
  if not ExtractToBuffer(buff, APath, 0, 1536) then
    raise Exception.CreateFmt('Cannot parse "%s", file is unreadable', [APath]);
  if not StrCompare(buff, TRA3.ReplayHeader) then     
    raise Exception.CreateFmt('Cannot parse "%s", invalid header', [APath]);
  reg := RegexExtract(buff, TCNC3.ReplayRegex, TCNC3.ReplayRegexCompileOptions);
  if reg = nil then
    raise Exception.CreateFmt('Cannot parse "%s", not a valid RA3 replay file', [APath]);
  self.Size := GetSizeOfFile(APath);
  self.ReadPlayers(reg); 
  self.ReadOptions(reg);
  self.ReadMisc(reg);
end;

end.
