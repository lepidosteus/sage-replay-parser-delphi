unit cnc3_replay;

interface

uses
  windows, SysUtils, DIRegEx, Registry, myutils, ShlObj, math,
  DIAnsiStringVector, DIContainers, strutils, DIPointerVector, myformat;

type
  TCNC3Infos = record
    InstallPath: string;
    ReplayFolderName: string;
    UserDataLeafName: string;
    ReplayPath: string;
    Language: string;
    Version: integer;
    
    LoadSucess: boolean;
  end;

  TCNC3Player = record
    Color: shortint;
    Army: shortint;
    Position: shortint;
    Team: byte;
    Handicap: shortint;
    case Human: boolean of
        true: (
          Clan: string[64];
          Name: string[64];
          UID: string[8]
          );
        false: (
          IAMode: shortint;
          IAName: string[2]
          );
  end;

  TCNC3Options = record
    Speed: byte;
    Money: word;
    Delay: byte;
    Crates: boolean;      
    Map: string;
  end;

  TCNC3Misc = record
    GSID: string;
    Version: string;
    Commented: boolean;
    Length: word;
  end;

  TCNC3Replay = class(TObject)
    private
      procedure AddPlayer(APlayer: string);
    protected
      procedure ReadPlayers(AReg: TDIPerlRegEx);
      procedure ReadOptions(AReg: TDIPerlRegEx);
      procedure ReadMisc(AReg: TDIPerlRegEx);
    public
      Players: array of TCNC3Player;
      Options: TCNC3Options;
      Misc: TCNC3Misc;       
      Size: cardinal;
      procedure Parse(const APath: string);
      function Format(const AFrmt: string; const AFilter: string): string;
      function Format2(const AFrmt: string): string;
      procedure subFormat(const Sender: TDIRegex; const VarName: string;
        out varValue: string; var ReplaceVar: boolean);
      function ListPlayers(AArmy: boolean = false; AClan: boolean = false; AShortArmy: boolean = false): string;        
      function GetHumanLength(): string;
  end;

  TCNC3 = class(TObject)
    public
      class function LoadInfos(var AData: TCNC3Infos): boolean;
      class function ParseReplay(var AReplay: TCNC3Replay;
        const APath: string): boolean; overload;           
      class function ParseReplay(var AReplay: TCNC3Replay;
        const APath: string; var AError: string): boolean; overload;
      class function GetArmyName(AArmyId: shortint): string;     
      class function GetShortArmyName(AArmyId: shortint): string;  
      class function GetVersionName(AVersionId: string): string;

      const RegKey = 'SOFTWARE\Electronic Arts\Electronic Arts\Command and Conquer 3';
      const BinaryName = 'CNC3.exe';                                     
      const ReplayExt = '.CNC3Replay';      
      const BuffSize = 1536;
      const ReplayHeader = 'C&C3 REPLAY HEADER';
      const ReplayRegexCompileOptions = [coUnGreedy];
      const ReplayRegex =
        'M=(?P<Map>[^;]+);'                   // map
				+'MC=(?P<MC>[0-9A-Z]+);'
				+'MS=(?P<MS>[0-9]+);'
				+'SD=(?P<SD>-?[0-9]+);'
				+'GSID=(?P<GSID>[0-9A-Z]+);'
				+'GT=(?P<GT>-?[0-9]+);'
				+'PC=(?P<PC>-?[0-9]+);'
				+'RU=(?P<Options>[0-9 -]+);'          // options
				+'S=(?P<Players>([^:]+:){6,8});'      // players
				+'.+'
				+'(?P<Version>\d\.\d{1,2}\.\d{1,5}\.\d{1,5})'; //version

      const data_Maps: array[0..72] of TKeyValStore = (
        (Value: 'Action fluviale'; sKey: 'data/maps/official/map_mp_2_simon'),
        (Value: 'Arène de tournoi'; sKey: 'data/maps/official/map_mp_2_black2'),
        (Value: 'Grande bataille de Black'; sKey: 'data/maps/official/map_mp_2_black6'),
        (Value: 'Petite ville des Etats-Unis'; sKey: 'data/maps/official/map_mp_2_black5'),
        (Value: 'Problèmes de pipeline'; sKey: 'data/maps/official/map_mp_2_black9'),
        (Value: 'Sertão mortelle'; sKey: 'data/maps/official/map_mp_2_black10'),
        (Value: 'Territoires désolés de Barstow'; sKey: 'data/maps/official/map_mp_2_black3'),
        (Value: 'Tour de tournoi'; sKey: 'data/maps/official/map_mp_2_black7'),
        (Value: 'Tournoi Désert'; sKey: 'data/maps/official/map_mp_2_bass1'),
        (Value: 'Avantage déséquilibré'; sKey: 'data/maps/official/map_mp_3_black1'),
        (Value: 'Triple menace'; sKey: 'data/maps/official/map_mp_3_black2'),
        (Value: 'Le cratère du carnage'; sKey: 'data/maps/official/map_mp_4_black1'),
        (Value: 'Désert périphérique'; sKey: 'data/maps/official/map_mp_4_bass'),
        (Value: 'La bataille pour la terre égyptienne'; sKey: 'data/maps/official/map_mp_4_bender'),
        (Value: 'Carnage en zone rouge'; sKey: 'data/maps/official/map_mp_4_rao'),
        (Value: 'Rixe tumultueuse'; sKey: 'data/maps/official/map_mp_4_black6'),
        (Value: 'Six pieds sous terre'; sKey: 'data/maps/official/map_mp_6_hayes'),
        (Value: 'Symphonie explosive'; sKey: 'data/maps/official/map_mp_6_black2'),
        (Value: 'Le Rocktogone'; sKey: 'data/maps/official/map_mp_8_bass'),
        (Value: 'Massacre limitrophe'; sKey: 'data/maps/official/map_mp_8_black1'),
        { 1.05 }
        (Value: 'Schlachtfeld Stuttgart'; sKey: 'data/maps/official/map_mp_2_black12'),
        (Value: 'Tournoi de la côte'; sKey: 'data/maps/official/map_mp_2_chuck1'),
        (Value: 'Tournoi de la faille'; sKey: 'data/maps/official/map_mp_2_will1'),
        (Value: 'Chaos sur la côte'; sKey: 'data/maps/official/map_mp_4_chuck1'),
        { 1.09 }
        (Value: 'Wrecktropolis'; sKey: 'data/maps/official/map_mp_4_chuck2'),
        { semi-official maps (from EB/BestBuy pre-orders }
        (Value: 'Les armes fatales'; sKey: 'data/maps/internal/map_mp_2_black11'),
        (Value: 'Vallée de la mort'; sKey: 'data/maps/internal/map_mp_4_black5'),
        (Value: 'Méga-bataille de Black'; sKey: 'data/maps/internal/map_mp_6_black1'),
    		{ Kane's Wrath converted }          
        (Value: 'Les armes fatales'; sKey: 'data/maps/official/map_mp_2_black11'),
        (Value: 'Vallée de la mort'; sKey: 'data/maps/official/map_mp_4_black5'),
        (Value: 'Méga-bataille de Black'; sKey: 'data/maps/official/map_mp_6_black1'),
        { Kane's Wrath }
        (Value: 'Décision guerrière'; sKey: 'data/maps/official/bamap_dc05_2'),
        (Value: 'Point Zéro'; sKey: 'data/maps/official/map_mp_2_black4'),
        (Value: 'Tournoi Redux dans le désert'; sKey: 'data/maps/official/map_mp_2_black1'),
        (Value: 'Vallée du Tibre'; sKey: 'data/maps/official/map_mp_2_black8'),
        (Value: 'Décision partagée'; sKey: 'data/maps/official/bamap_dc05_3'),
        (Value: 'Le triangle de la toundra'; sKey: 'data/maps/official/bamap_kk03_3'),
        (Value: 'Massacre suburbain'; sKey: 'data/maps/official/bamap_ew09_03'),
        (Value: 'Conflit croisé'; sKey: 'data/maps/official/bamap_dc08_4'),
        (Value: 'Dégradation urbaine'; sKey: 'data/maps/official/bamap_ew07_04'),
        (Value: 'Déluge d''artillerie'; sKey: 'data/maps/official/bamap_ew06_04'),
        (Value: 'Désolation'; sKey: 'data/maps/official/bamap_dc03_3'),
        (Value: 'Dévastation sur les docks'; sKey: 'data/maps/official/bamap_jf01_4'),
        (Value: 'Enfer et paradis'; sKey: 'data/maps/official/bamap_rh01_4'),
        (Value: 'Fracas frontalier'; sKey: 'data/maps/official/map_mp_4_ssmith_01'),
        (Value: 'Grabuge au port'; sKey: 'data/maps/official/bamap_aw01_04'),
        (Value: 'Investissements douteux'; sKey: 'data/maps/official/bamap_ew01_4'),
        (Value: 'La fin des haricots'; sKey: 'data/maps/official/bamap_dc04_3'),
        (Value: 'La sécurité en question'; sKey: 'data/maps/official/bamap_ew05_04'),
        (Value: 'La ville-empire'; sKey: 'data/maps/official/bamap_dc11_4'),
        (Value: 'Le petit conflit dans la prairie'; sKey: 'data/maps/official/bamap_dc01_4'),
        (Value: 'Les montagnes de la folie'; sKey: 'data/maps/official/bamap_dc07_4'),
        (Value: 'L''allée des meurtriers'; sKey: 'data/maps/official/bamap_dc10_4'),
        (Value: 'Opportunité perdue'; sKey: 'data/maps/official/bamap_sb01_4'),
        (Value: 'Promesses orientales'; sKey: 'data/maps/official/bamap_ew08_04'),
        (Value: 'Terres arides'; sKey: 'data/maps/official/bamap_dc06_4'),
        (Value: 'Terreur sur l''oasis'; sKey: 'data/maps/official/bamap_ew03_04'),
        (Value: 'Territoires abandonnés'; sKey: 'data/maps/official/bamap_dc02_4'),
        (Value: 'Les jardins de tibérium III'; sKey: 'data/maps/official/map_mp_5_black1'),
        (Value: 'L''isthme de la folie'; sKey: 'data/maps/official/bamap_ew11_05'),
        (Value: 'Désert de tibérium'; sKey: 'data/maps/official/bamap_ew10_06'),
        (Value: 'En eaux troubles'; sKey: 'data/maps/official/bamap_jf03_6'),
        { Kane's Wrath bonus maps }
        (Value: 'Arène en ruine'; sKey: 'data/maps/internal/map_mp_2_black2_redzoned'),
        (Value: 'Menace sur la tour'; sKey: 'data/maps/internal/map_mp_2_black7_redzoned'),
        (Value: 'Rivière de l''oubli'; sKey: 'data/maps/internal/map_mp_2_simon_b'),
        (Value: 'Les cratères de Camden'; sKey: 'data/maps/internal/eamap_sb05_4'),
        { unofficial maps }
    		(Value: 'Empire Déchu classique'; sKey: 'data/maps/internal/fallen_empire_classic'),
        (Value: 'Micro Wars v1.1'; sKey: 'data/maps/internal/micro_wars_v1.1'),
        (Value: 'Micro Wars Teams v1.1'; sKey: 'data/maps/internal/micro_wars_team_v1.1'),
		    { lda tournament }
    		(Value: 'Tournoi LDA Fortification'; sKey: 'data/maps/internal/[lda-domination]fortification'),
        (Value: 'Tournoi LDA Avant Poste'; sKey: 'data/maps/internal/[lda-domination]avant-poste'),
        (Value: 'Tournoi LDA Standard'; sKey: 'data/maps/internal/[lda-domination]standard'),
        (Value: 'Tournoi LDA Base'; sKey: 'data/maps/internal/[lda-domination]base')
        );
      const data_Version: array[0..7] of TKeyValStore = (
        (Value: '1.02'; sKey: '1.2.2613.21264'),
		    (Value: '1.03'; sKey: '1.3.2615.35899'),
		    (Value: '1.04'; sKey: '1.4.2620.25554'),
		    (Value: '1.05'; sKey: '1.5.2674.29882'), 
		    (Value: '1.06'; sKey: '1.6.2717.27604'),
		    (Value: '1.07'; sKey: '1.7.2745.30656'),
		    (Value: '1.08'; sKey: '1.8.2761.19784'),
		    (Value: '1.09'; sKey: '1.9.2801.21826')
        );    
      const data_Armies: array[0..5] of TKeyValStore = (
        (Value: 'Aléatoire'; iKey: 1),
        (Value: 'Observateur'; iKey: 2),
    		(Value: 'Commentateur'; iKey: 3),
		    (Value: 'GDI'; iKey: 6),
    		(Value: 'NOD'; iKey: 7),
		    (Value: 'Scrin'; iKey: 8)
        );    
      const data_ShortArmies: array[0..5] of TKeyValStore = (
        (Value: 'R'; iKey: 1),
        (Value: 'O'; iKey: 2),
    		(Value: 'C'; iKey: 3),
		    (Value: 'G'; iKey: 6),
    		(Value: 'N'; iKey: 7),
		    (Value: 'S'; iKey: 8)
        );
      const data_nonPlaying = [2, 3];
      const data_Colors: array[0..8] of TKeyValStore = (
        (Value: '$000000'; iKey: -1),
        (Value: '$2B2BB3'; iKey: 0),
        (Value: '$FCE953'; iKey: 1),
        (Value: '$00A744'; iKey: 2),
        (Value: '$FD7602'; iKey: 3),
        (Value: '$FB7FD3'; iKey: 4),
        (Value: '$8301FC'; iKey: 5),
        (Value: '$D50000'; iKey: 6),
        (Value: '$04DAFA'; iKey: 7)
        );
      const data_IAMode: array[0..5] of TKeyValStore = (
        (Value: 'Aléatoire'; iKey: -2),
        (Value: 'Equilibrée'; iKey: 0),
        (Value: 'Attaque rapide'; iKey: 1),
        (Value: 'Développement tranquille'; iKey: 2),
        (Value: 'Guerilla'; iKey: 3),
        (Value: 'Rouleau compresseur'; iKey: 4)
        );
      const data_IAName: array[0..3] of TKeyValStore = (   
		    (Value: 'IA Facile'; sKey: 'CE'),
		    (Value: 'IA Moyenne'; sKey: 'CM'),
		    (Value: 'IA Difficile'; sKey: 'CH'),
		    (Value: 'IA Brutale'; sKey: 'CB')
        );
  end;

implementation

uses
  kw_replay, ra3_replay;

{ TCNC3 }

class function TCNC3.LoadInfos(var AData: TCNC3Infos): boolean;
var reg: TRegistry;
begin
  result := false;       
  AData.LoadSucess := false;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if not reg.OpenKey(TCNC3.RegKey, false) then
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

class function TCNC3.ParseReplay(var AReplay: TCNC3Replay;
  const APath: string): boolean;
var error: string;
begin
  result := TCNC3.ParseReplay(AReplay, APath, error);
end;
     
class function TCNC3.ParseReplay(var AReplay: TCNC3Replay;
  const APath: string; var AError: string): boolean;
begin         
  result := false;
  AReplay := TCNC3Replay.Create;
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

class function TCNC3.GetArmyName(AArmyId: shortint): string;
begin
  result := KeyValFind(AArmyId, TCNC3.data_Armies, 'Erreur');
end;
                         
class function TCNC3.GetShortArmyName(AArmyId: shortint): string;
begin
  result := KeyValFind(AArmyId, TCNC3.data_ShortArmies, 'Erreur');
end;

class function TCNC3.GetVersionName(AVersionId: string): string;
begin
  result := KeyValFind(AVersionId, TCNC3.data_Version, 'Erreur');
end;

{ TCNC3Replay }

procedure TCNC3Replay.Parse(const APath: string);
var buff: array[0..(TCNC3.BuffSize - 1)] of char;
    reg: TDIPerlRegEx;
begin
  if not FileExists(APath) then
    raise Exception.CreateFmt('Cannot parse "%s", this file does not exist', [APath]);
  if not ExtractToBuffer(buff, APath, 0, 1536) then
    raise Exception.CreateFmt('Cannot parse "%s", file is unreadable', [APath]);
  if not StrCompare(buff, TCNC3.ReplayHeader) then     
    raise Exception.CreateFmt('Cannot parse "%s", invalid header', [APath]);
  reg := RegexExtract(buff, TCNC3.ReplayRegex, TCNC3.ReplayRegexCompileOptions);
  if reg = nil then
    raise Exception.CreateFmt('Cannot parse "%s", not a valid CnC3 replay file', [APath]);
  self.Size := GetSizeOfFile(APath);
  self.ReadPlayers(reg); 
  self.ReadOptions(reg);
  self.ReadMisc(reg);
end;
                 
procedure TCNC3Replay.AddPlayer(APlayer: string);
var pVector: TDIAnsiStringVector;
    PTCNC3Player: ^TCNC3Player;
begin     
  pVector := Explode(APlayer, ',');
  try
    if ((pVector.NameAt[0] = 'X') or (pVector.NameAt[0] = 'Hpost Commentator')) then
      exit;
    SetLength(self.Players, length(self.Players) + 1);
    PTCNC3Player := @self.Players[length(self.Players) - 1];
    case pVector.NameAt[0][1] of
      'H':
        begin
          PTCNC3Player^.Human := true;
          PTCNC3Player^.Color := strtoint(pVector.NameAt[4]);
          PTCNC3Player^.Army := strtoint(pVector.NameAt[5]);
          PTCNC3Player^.Position := strtoint(pVector.NameAt[6]);
          PTCNC3Player^.Team := strtoint(pVector.NameAt[7]) + 1;
          PTCNC3Player^.Handicap := strtoint(pVector.NameAt[8]);
          PTCNC3Player^.Clan := pVector.NameAt[11];
          PTCNC3Player^.Name := copy(pVector.NameAt[0], 2, length(pVector.NameAt[0]) - 1);
          PTCNC3Player^.UID := pVector.NameAt[1];
        end;
      'C':
        begin
          PTCNC3Player^.Human := false;
          PTCNC3Player^.Color := strtoint(pVector.NameAt[1]);
          PTCNC3Player^.Army := strtoint(pVector.NameAt[2]);
          PTCNC3Player^.Position := strtoint(pVector.NameAt[3]);
          PTCNC3Player^.Team := strtoint(pVector.NameAt[4]) + 1;
          PTCNC3Player^.Handicap := strtoint(pVector.NameAt[5]);
          PTCNC3Player^.IAMode := strtoint(pVector.NameAt[6]);
          PTCNC3Player^.IAName := pVector.NameAt[0];
        end;
    end;
  finally
    pVector.Free;
  end;
end;

procedure TCNC3Replay.ReadPlayers(AReg: TDIPerlRegEx);
var pVector: TDIAnsiStringVector;
    i: integer;
begin
  pVector := Explode(AReg.NamedSubStrByName('Players'), ':', false);
  try
    if (pVector.Count <> 8) and (pVector.Count <> 6) then
      raise Exception.Create('Invalid players number, unknown format');
    for i := 0 to pVector.Count - 1 do
      self.AddPlayer(pVector.NameAt[i]); 
    if ((length(self.Players) = 0) or (length(self.Players) > 8)) then   
      raise Exception.Create('Invalid players number, unknown format');
  finally
    pVector.Free;
  end;
end;

procedure TCNC3Replay.subFormat(const Sender: TDIRegex; const VarName: string;
  out varValue: string; var ReplaceVar: boolean);
var elems: TDIAnsiStringVector;
begin
  elems := Explode(VarName, '_');
  try
    case AnsiIndexStr(
      LowerCase(elems.FirstName),
      ['map', 'players', 'version', 'date', 'time', 'length', 'rdate']
      ) of
      0 : if self is TRA3Replay then
            varValue := KeyValFind(StrCrop(self.Options.Map, 3), TRA3.data_Maps, 'Map inconnue')
          else
            varValue := KeyValFind(StrCrop(self.Options.Map, 3), TCNC3.data_Maps, 'Map inconnue');
      1 : begin
            if ((elems.Count = 2) and (elems.NameAt[1] = 'army')) then
              varValue := self.ListPlayers(true)
            else if ((elems.Count = 2) and (elems.NameAt[1] = 'sarmy')) then
              varValue := self.ListPlayers(false, false, true)
            else if ((elems.Count = 2) and (elems.NameAt[1] = 'clan')) then
              varValue := self.ListPlayers(false, true)
            else if ((elems.Count = 2) and (elems.NameAt[1] = 'armyclan')) then
              varValue := self.ListPlayers(true, true)
            else if ((elems.Count = 2) and (elems.NameAt[1] = 'sarmyclan')) then
              varValue := self.ListPlayers(false, true, true)
            else
              varValue := self.ListPlayers();
          end;
      2 : if self is TKWReplay then
            varValue := TKW.GetVersionName(self.Misc.Version)
          else if self is TRA3Replay then             
            varValue := TRA3.GetVersionName(self.Misc.Version)
          else                                                      
            varValue := TCNC3.GetVersionName(self.Misc.Version);
      3 : varValue := FormatDateTime('dd-mm-yy', Now);
      4 : varValue := FormatDateTime('hh"h"nn', Now);
      5 : varValue := self.GetHumanLength();       
      6 : begin
            if (elems.Count = 2) then
              varValue := FormatDateTime(elems.NameAt[1], Now)
            else
              varValue := FormatDateTime('yy-mm-dd', Now);
          end;
      -1: varValue := VarName;
    end;
  finally     
    elems.Free;
  end;
end;

procedure TCNC3Replay.ReadOptions(AReg: TDIPerlRegEx);
var opt: TDIAnsiStringVector;
begin
  opt := Explode(trim(AReg.NamedSubStrByName('Options')));
  try
    if opt.Count < 6 then
      raise Exception.Create('Invalid options number, unknown format');
    self.Options.Speed := strtoint(opt.NameAt[1]);
    self.Options.Money := strtoint(opt.NameAt[2]);
    self.Options.Delay := strtoint(opt.NameAt[5]);
    self.Options.Crates := (strtoint(opt.NameAt[6]) = 1);
    self.Options.Map := AReg.NamedSubStrByName('Map');
  finally   
    opt.Free;
  end;
end;

procedure TCNC3Replay.ReadMisc(AReg: TDIPerlRegEx);
var numPlayers: byte;
begin         
  numPlayers := length(self.Players);
  if numPlayers = 0 then
    raise Exception.Create('Player list is empty, cannot proceed');
  self.Misc.Version := AReg.NamedSubStrByName('Version');
  self.Misc.GSID := AReg.NamedSubStrByName('GSID');
  self.Misc.Commented := (strtoint(AReg.NamedSubStrByName('PC')) = -1);
  self.Misc.Length :=
    Round(((self.Size / 1024) / (0.18 * numPlayers))
      - ((self.Size / 1536) - (104 * numPlayers)));
  if self.Misc.Commented then
    self.Misc.Length := round(self.Misc.Length / 2.20);
end;

function TCNC3Replay.Format(const AFrmt: string; const AFilter: string): string;
begin
  if self is TKWReplay then
    result := RegexFormat(AFrmt, self.subFormat, AFilter, '.KWReplay')
  else if self is TRA3Replay then
    result := RegexFormat(AFrmt, self.subFormat, AFilter, '.RA3Replay')
  else
    result := RegexFormat(AFrmt, self.subFormat, AFilter, '.CNC3Replay');
end;
          
function TCNC3Replay.Format2(const AFrmt: string): string;
begin
  result := RegexFormat(AFrmt, self.subFormat, '', '');
end;

function TCNC3Replay.GetHumanLength: string;
begin
  result := inttostr(floor(self.Misc.Length div 60));
  result := result + ':' + FormatFloat('00', self.Misc.Length - (strtoint(result) * 60));
end;

function TCNC3Replay.ListPlayers(AArmy: boolean; AClan: boolean; AShortArmy: boolean): string;
var i, j: integer;
    list: array[0..4] of TDIPointerVector;
    nonPlaying: set of byte;
begin
  result := '';
  // on créer les 5 vector (pas de team, puis les 4 teams)
  for i := 0 to length(list) - 1 do
    list[i] := NewDIPointerVector;
  try
    // on insère chaque joueur dans le vector qui gère sa team
    for i := 0 to length(self.Players) - 1 do
      list[self.Players[i].Team].InsertPointerLast(@self.Players[i]);
    // on boucle sur chaque vector pour en afficher les membres
    for i := 0 to length(list) - 1 do
    begin
      if list[i].Count > 0 then // si vecteur pas vide (quelqu'un dans l'équipe)
      begin
        // on a changé d'équipe
        if length(result) <> 0 then
          result := result + ' vs ';
        // on boucle sur chaque joueur de l'équipe
        for j := 0 to list[i].Count - 1 do
        begin
          // on retire les non joueurs          
          if self is TKWReplay then
            nonPlaying := TKW.data_nonPlaying
          else if self is TRA3Replay then
            nonPlaying := TRA3.data_nonPlaying
          else
            nonPlaying := TCNC3.data_nonPlaying;
          if TCNC3Player(list[i].PointerAt[j]^).Army in nonPlaying then
            continue;
          // si on a déjà un joueur de l'équipe affiché
          if ((length(result) <> 0) and (j <> 0)) then
            if i <> 0 then
              result := result + ' + '
            else           
              result := result + ' vs ';
          // si on veut afficher le clan et que c'est un humain (avec un clan)
          if (AClan
            and (TCNC3Player(list[i].PointerAt[j]^).Human)
            and (length(TCNC3Player(list[i].PointerAt[j]^).Clan) > 0)) then
            result := result + '[' + TCNC3Player(list[i].PointerAt[j]^).Clan + ']';
          // on affiche le nom
          if TCNC3Player(list[i].PointerAt[j]^).Human then
            result := result + TCNC3Player(list[i].PointerAt[j]^).Name
          else
            result := result
              + KeyValFind(TCNC3Player(list[i].PointerAt[j]^).IAName, TCNC3.data_IAName, 'IA')
              + ' '
              + KeyValFind(TCNC3Player(list[i].PointerAt[j]^).IAMode, TCNC3.data_IAMode, 'Classique');
          // on affiche l'armée
          {NEED HACK KW}
          if self is TKWReplay then
          begin
            if AArmy then
              result := result + ' ('
                + TKW.GetArmyName(TCNC3Player(list[i].PointerAt[j]^).Army)
                + ')'
          end
          else if self is TRA3Replay then
          begin
            if AArmy then
              result := result + ' ('
                + TRA3.GetArmyName(TCNC3Player(list[i].PointerAt[j]^).Army)
                + ')'
          end
          else
            if AArmy then
              result := result + ' ('
                + TCNC3.GetArmyName(TCNC3Player(list[i].PointerAt[j]^).Army)
                + ')';
          // army short
          if self is TKWReplay then
          begin
            if AShortArmy then
              result := result + ' ('
                + TKW.GetShortArmyName(TCNC3Player(list[i].PointerAt[j]^).Army)
                + ')'
          end
          else if self is TRA3Replay then
          begin
            if AShortArmy then
              result := result + ' ('
                + TRA3.GetShortArmyName(TCNC3Player(list[i].PointerAt[j]^).Army)
                + ')'
          end
          else
            if AShortArmy then
              result := result + ' ('
                + TCNC3.GetShortArmyName(TCNC3Player(list[i].PointerAt[j]^).Army)
                + ')';
        end;
      end;
    end;
  finally
    for i := 0 to length(list) - 1 do
      list[i].Free;
  end;
end;

end.
