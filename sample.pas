procedure DisplayReplayInfo(AFilePath: string);
var replay: TCNC3Replay; // TKWReplay, TRA3Replay, ...
begin
   if not FileExists(AFilePath) then
      exit;
   try
      TCNC3.ParseReplay(replay, AFilePath);
      try
        WriteLn(replay.Format('%version% - %map% - %players_armyclan%', ''));
      finally
        replay.Free
    end;
  except
  end;
end;
