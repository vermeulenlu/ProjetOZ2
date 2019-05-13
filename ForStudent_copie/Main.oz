functor
import
   GUI
   Input
   Browser
   PlayerManager
   GameState
   System(showInfo:Print)
   OS
define
   Game_Port
   GUI_Port
   ListID
   ListBombers

   proc{BroadCast Message N} GameState State in
      {Send Game_Port askGameState(State)}
      {Wait State}
      GameState = {RetrieveListLast State N 1}
      case GameState of H|T then
	 case Message of spawnPlayer(ID Pos) then
	    {Send H.port info(spawnPlayer(ID Pos))}
	    {BroadCast Message N+1}
	 [] movePlayer(ID Pos) then
	    {Send H.port info(movePlayer(ID Pos))}
	    {BroadCast Message N+1}
	 [] deadPlayer(ID) then
	    {Send H.port info(deadPlayer(ID))}
	    {BroadCast Message N+1}
	 [] bombPlanted(Pos) then
	    {Send H.port info(bombPlanted(Pos))}
	    {BroadCast Message N+1}
	 [] bombExploded(Pos) then
	    {Send H.port info(bombExploded(Pos))}
	    {BroadCast Message N+1}
	 [] boxRemoved(Pos) then
	    {Send H.port info(boxRemoved(Pos))}
	    {BroadCast Message N+1}
	 [] nil then skip
	 end
      [] nil then skip
      end
   end

   fun{SearchBox List N}
      case List of H|T then
	 if(H==2 orelse H==3) then
	    {SearchBox T N+1}
	 else
	    {SearchBox T N}
	 end
      [] nil then
	 N
      end
   end

   fun{NumberBox Map N} Res in
      case Map of H|T then
	 Res = {SearchBox H 0}
	 {NumberBox T N+Res}
      [] nil then
	 N
      end
   end

   fun{WhoIsWinner GameState} ID in
      case GameState of H|T then
	 if(H.life==0) then
	    {WhoIsWinner T}
	 else
	    {Send H.port getId(ID)}
	    {Wait ID}
	    ID
	 end
      [] nil then
	 nil
      end
   end

   fun{HighestScore GameState Winner} ID in
      case GameState of H|T then
	 if(H.score>Winner.score) then
	    {HighestScore T H}
	 else
	    {HighestScore T Winner}
	 end
      [] nil then
	 {Send Winner.port getId(ID)}
	 {Wait ID}
	 ID
      end
   end

   fun{Ids Colors Name NId}
      if(NId >Input.nbBombers) then nil
      else
	 case Colors#Name of (H1|T1)#(H2|T2) then
	    bomber(id:NId color:H1 name:H2)|{Ids T1 T2 NId+1}
	 [] nil#nil then nil
	 end
      end
   end

   fun{GenerateBombers List ID}
      case List#ID of (H1|T1)#(H2|T2) then
	 {PlayerManager.playerGenerator H1 H2}|{GenerateBombers T1 T2}
      [] nil#nil then nil
      end
   end

   fun{IsPresent Pos Points} Res in
      case Points of H|T then
	 if(Pos.x==H.x) then
	    if(Pos.y==H.y) then
	       Res=true
	    else
	       Res={IsPresent Pos T}
	    end
	 else
	    Res={IsPresent Pos T}
	 end
      [] nil then
	 Res=false
      end
      Res
   end

   fun{Replace List P N Count}
      case List of H|T then
	 if(Count==N) then
	    P|T
	 else
	    H|{Replace T P N Count+1}
	 end
      end
   end

   fun{RetrieveListLast List N Count}
      if(N==0) then List
      else
	 case List of H|T then
	    if(Count==N) then T
	    else
	       {RetrieveListLast T N Count+1}
	    end
	 [] nil then nil
	 end
      end
   end

   fun{RetrieveListFirst List N Count}
      case List of H|T then
	 if(Count==N) then nil
	 else
	    H|{RetrieveListFirst T N Count+1}
	 end
      [] nil then nil
      end
   end

   fun{RetireBomb List Bomb}
      case List of H|T then
	 if(H.idBomb==Bomb.idBomb) then
	    T
	 else
	    H|{RetireBomb T Bomb}
	 end
      [] nil then nil
      end
   end

   fun{Retire Pos Points}
      case Points of H|T then
	 if(H==Pos) then
	    T
	 else
	    H|{Retire Pos T}
	 end
      [] nil then nil
      end
   end

   fun{MapRandomPos}
      pt(y:({OS.rand} mod Input.nbRow + 1) x:({OS.rand} mod Input.nbColumn + 1))
   end

   fun{IsASpawn Pos}
      if ({List.nth {List.nth Input.map Pos.y} Pos.x}==4) then true
      else
	 false
      end
   end

   fun{NewSpawn} Pos in
      Pos = {MapRandomPos}
      if {IsASpawn Pos} then
	 Pos
      else
	 {NewSpawn}
      end
   end

   proc{Initit List}
      case List of H|T then
	 local ID Pos in
	    {Send H assignSpawn({NewSpawn})}
	    {Send H spawn(?ID ?Pos)}
	    {Wait ID}
	    {Wait Pos}
	    {Send GUI_Port initPlayer(ID)}
	    {Send GUI_Port spawnPlayer(ID Pos)}
	    {Send Game_Port spawnPlayer(ID Pos)}
	    {Send Game_Port playerMoved(Pos ID.id)}
	    {BroadCast spawnPlayer(ID Pos) 0}
	    {Initit T}
	 end
      [] nil then skip
      end
   end

   fun{Check X Y Xsup Ysup}
      fun{CheckLoop X Y Xsup Ysup N}
	 local XFin YFin Map in
	    if(Xsup<0) then
	       XFin=X-1
	    else
	       XFin=(X)+(Xsup)
	    end
	    if(Ysup<0) then
	       YFin=Y-1
	    else
	       YFin=(Y)+(Ysup)
	    end
	    if (XFin =< 0) then
	       nil
	    elseif(XFin>Input.nbColumn) then
	       nil
	    elseif(YFin=<0) then
	       nil
	    elseif(YFin>Input.nbRow) then
	       nil
	    elseif(N=<0) then
	       nil
	    else
	       {Send Game_Port askMap(Map)}
	       {Wait Map}
	       case {List.nth {List.nth Map Y+Ysup} X+Xsup} of 1 then
		  nil %% WALL
	       [] 2 then pt(x:XFin y:YFin)|nil %% BOX WITH POINT
	       [] 3 then pt(x:XFin y:YFin)|nil %% BOX WITH BONUS
	       [] 4 then pt(x:XFin y:YFin)|{CheckLoop XFin YFin Xsup Ysup N-1} %% SPAWN
	       [] 0 then pt(x:XFin y:YFin)|{CheckLoop XFin YFin Xsup Ysup N-1} %% SOL
	       end
	    end
	 end
      end
   in
      {CheckLoop X Y Xsup Ysup Input.fire}
   end

   proc{HideFiiire List}
      case List of H|T then
	 {Send GUI_Port hideFire(H)}
	 {HideFiiire T}
      [] nil then skip
      end
   end

   proc{Fiiire Points} Map BonusList in
      case Points of H|T then
	 {Send GUI_Port spawnFire(H)}
	 {Send Game_Port askMap(Map)}
	 {Wait Map}
	 case {List.nth {List.nth Map H.y} H.x} of 2 then
	    local NewMap PointsList in
	       {Send GUI_Port hideBox(H)}
	       {Send GUI_Port spawnPoint(H)}
	       NewMap={Replace Map {Replace {List.nth Map H.y} 0 H.x 1} H.y 1}
	       {Send Game_Port mapChanged(NewMap)}
	       {BroadCast boxRemoved(H) 0}
	       {Send Game_Port askPoints(PointsList)}
	       {Wait PointsList}
	       {Send Game_Port pointListChanged(H|PointsList)}
	       {Fiiire T}
	    end
	 [] 3 then
	    local NewMap in
	       {Send GUI_Port hideBox(H)}
	       {Send GUI_Port spawnBonus(H)}
	       NewMap={Replace Map {Replace {List.nth Map H.y} 0 H.x 1} H.y 1}
	       {Send Game_Port mapChanged(NewMap)}
	       {BroadCast boxRemoved(H) 0}
	       {Send Game_Port askBonus(BonusList)}
	       {Wait BonusList}
	       {Send Game_Port bonusListChanged(H|BonusList)}
	       {Fiiire T}
	    end
	 else
	    {Fiiire T}
	 end
      [] nil then skip
      end
   end

   fun{SeeHowManyPlayers GameState N}
      case GameState of H|T then
	 if(H.life>0) then
	    {SeeHowManyPlayers T N+1}
	 else
	    {SeeHowManyPlayers T N}
	 end
      [] nil then N
      end
   end

   fun{GotHit Player GameState}
      local ID Res ID2 Pos Res2 in
	 {Send Player.port gotHit(?ID ?Res)}
	 {Wait ID}
	 {Wait Res}
	 {Send GUI_Port hidePlayer(ID)}
	 case Res of death(NewLife) then
	    if(NewLife=<0) then
	       {Send GUI_Port lifeUpdate(ID 0)}
	       {BroadCast deadPlayer(ID) 0}
	       {Record.adjoin Player player(life:0 state:off)}
	    else
	       {Send GUI_Port lifeUpdate(ID NewLife)}
	       {Send Game_Port askSpawn(Player Res2)}
	       {Wait Res2}
	       {Send GUI_Port spawnPlayer(Player Res2)}
	       {BroadCast deadPlayer(ID) 0}
	       {Record.adjoin Player player(life:NewLife state:off needToSpawn:1)}
	    end
	 else
	    Player
	 end
      end
   end

   proc{EliminatePlayers Points N} GameState State Res in
      {Send Game_Port askGameState(State)}
      {Wait State}
      GameState = {RetrieveListLast State N 1}
      case GameState of H|T then
	 local Gone NewPlayer in
	    case H.state of on then
	       Gone={IsPresent H.pos Points}
	       if(Gone==true) then
		  NewPlayer={GotHit H State}
		  {Send Game_Port updatePlayer(NewPlayer)}
		  {EliminatePlayers Points N+1}
	       else
		  {EliminatePlayers Points N+1}
	       end
	    else
	       {EliminatePlayers Points N+1}
	    end
	 end
      [] nil then skip
      end
   end

   proc{Explode Bomb} PosBomb IDBomb PointsToFire BombList NewBombList in
      PosBomb=Bomb.pos
      IDBomb=Bomb.idBomber
      PointsToFire = {Append {Append {Append {Append {Check PosBomb.x PosBomb.y 0 1} {Check PosBomb.x PosBomb.y 0 ~1}} {Check PosBomb.x PosBomb.y 1 0}} {Check PosBomb.x PosBomb.y ~1 0}} [pt(x:PosBomb.x y:PosBomb.y)]}
      {Send GUI_Port hideBomb(PosBomb)}
      {Fiiire PointsToFire}
      {EliminatePlayers PointsToFire 0}
      {BroadCast bombExploded(PosBomb) 0}
      {Delay 400}
      {HideFiiire PointsToFire}
      {Send Game_Port askBombList(BombList)}
      {Wait BombList}
      NewBombList={RetireBomb BombList Bomb}
      {BroadCast bombExploded(PosBomb) 0}
      {Send Game_Port bombListChanged(NewBombList)}
   end

   proc{UpdateBomb Player N} BombList List in
      {Send Game_Port askBombList(List)}
      {Wait List}
      case List of nil then skip
      else
	 BombList = {RetrieveListLast List N 1}
	 case BombList of H|T then
	    if(H.idBomber.id == Player.id) then
	       if(H.time == 0) then
		  {Explode H}
		  local Res in
		     {Send Player.port add(bomb 1 Res)}
		     {Wait Res}
		  end
		  {UpdateBomb Player N+1}
	       else
		  local P in
		     P={Record.adjoin H bomb(time:H.time-1)}
		     {Send Game_Port updateBomb(P)}
		     {UpdateBomb Player N+1}
		  end
	       end
	    else
	       {UpdateBomb Player N+1}
	    end
	 [] nil then skip
	 end
      end
   end

   proc{MakeAction Player} ID Action Points Bonus Res U in
      {Send Player.port doaction(?ID ?Action)}
      {Wait ID}
      {Wait Action}
      case Action of move(Pos) then
	       {BroadCast movePlayer(ID Pos) 0}
	       {Send GUI_Port movePlayer(ID Pos)}
	       {Send Game_Port askPoints(Points)}
	       {Wait Points}
	       {Send Game_Port askBonus(Bonus)}
	       {Wait Bonus}
	       if({IsPresent Pos Points}) then NewPoints in %% Point
	         NewPoints={Retire Pos Points}
	         {Send Game_Port pointListChanged(NewPoints)}
	         {Send GUI_Port hidePoint(Pos)}
	         {Send Player.port add(point 1 ?Res)}
	         {Wait Res}
	         {Send GUI_Port scoreUpdate(ID Res)}
	         {Send Game_Port playerMoved(Pos ID.id)}
	       elseif({IsPresent Pos Bonus}) then NewBonus in %% Bonus
	         NewBonus={Retire Pos Bonus}
	         {Send Game_Port bonusListChanged(NewBonus)}
	         {Send GUI_Port hideBonus(Pos)}
	         if(({OS.rand} mod 2)==0)  then
	           {Send Player.port add(point 10 ?Res)}
	           {Wait Res}
	           {Send GUI_Port scoreUpdate(ID Res)}
	           {Send Game_Port playerMoved(Pos ID.id)}
	         else
	           {Send Player.port add(bomb 1 ?Res)}
	           {Wait Res}
	           {Send Game_Port playerMoved(Pos ID.id)}
	         end
	       else
	         {Send Game_Port playerMoved(Pos ID.id)}
	       end
      [] bomb(Pos) then NewBombList BombList in

	 {Send GUI_Port spawnBomb(Pos)}
	 {Send Game_Port askBombList(BombList)}
	 {Wait BombList}
	 if(Input.isTurnByTurn) then
	    NewBombList = bomb(pos:Pos time:Input.timingBomb idBomber:ID idBomb:{OS.rand})|BombList
	    {BroadCast bombPlanted(Pos) 0}
	    {Send Game_Port bombListChanged(NewBombList)}
	 else
	    NewBombList = bomb(pos:Pos time:{Alarm Input.timingBombMin+({OS.rand} mod (Input.timingBombMax-Input.timingBombMin))} idBomber:ID idBomb:{OS.rand})|BombList
	    {BroadCast bombPlanted(Pos) 0}
	    {Send Game_Port bombListChanged(NewBombList)}
	 end
      [] null then skip
      end
   end

   proc{Run Players N} GameState GameState2 NewPlayer ID2 Pos Player in
      {Delay 300}
      case Players of H|T then
	 if(H.needToSpawn==1) then
	    {Send H.port spawn(?ID2 ?Pos)}
	    {Wait ID2}
	    {Wait Pos}
	    NewPlayer={Record.adjoin H player(pos:Pos state:on needToSpawn:0)}
	    {BroadCast spawnPlayer(ID2 Pos) 0}
	    {Send Game_Port updatePlayer(NewPlayer)}
	    {UpdateBomb NewPlayer 0}
	    {Send Game_Port askGameState(GameState)}
	    {Wait GameState}
	    if({List.nth GameState N}.life>0) then
	       {MakeAction {List.nth GameState N}}
	       {Run {RetrieveListLast GameState N 1} N+1}
	    else
	       {Run {RetrieveListLast GameState N 1} N+1}
	    end
	 else
	    {UpdateBomb H 0}
	    {Send Game_Port askGameState(GameState)}
	    {Wait GameState}
	    Player =  {List.nth GameState N}
	    if(Player.needToSpawn==1) then
	       {Run {RetrieveListLast GameState N 1} N+1}
	    else
	       if({List.nth GameState N}.life>0) then
		  {MakeAction {List.nth GameState N}}
		  {Run {RetrieveListLast GameState N 1} N+1}
	       else
		  {Run {RetrieveListLast GameState N 1} N+1}
	       end
	    end
	 end
      [] nil then skip
      end
   end

   proc{TurnByTurn} GameState GameState2 Winner Map in
      {Send Game_Port askGameState(GameState)}
      {Wait GameState}
      {Run GameState 1}
      {Send Game_Port askGameState(GameState2)}
      {Wait GameState2}
      {Send Game_Port askMap(Map)}
      {Wait Map}
      if({SeeHowManyPlayers GameState2 0}>1 andthen {NumberBox Map 0}>0) then  %% Le jeu comporte encore plus de un joueur
	 {TurnByTurn}
      else
	 if({SeeHowManyPlayers GameState2 0}==1) then %% Il ne reste qu'un joueur, il gagne
	    Winner={WhoIsWinner GameState2}
	    {Send GUI_Port displayWinner(Winner)}
	 else  %% Il ne reste plus de joueurs ou plus de boxs, le gagnant est celui avec le plus grand nombre de points
	       Winner = {HighestScore GameState2 GameState2.1}
	       {Send GUI_Port displayWinner(Winner)}
	 end
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fonctions Pour le Mode Simultané %%%%%%%%%%%%%%%%%%%%%%%%%%%

   proc{BombSim List} Res in
      case List of H|T then
	 if(H.time == unit) then
	    {Send Game_Port changing(1)}
	    local Port Res in
	       {Explode H}
	       {Send Game_Port giveMePort(H.idBomber.id Port)}
	       {Wait Port}
	       {Send Port add(bomb 1 Res)}
	       {Wait Res}
	       {Send Game_Port changing(0)}
	       {BombSim T}
	    end
	 else
	    {BombSim T}
	 end
      [] nil then
	 skip
      end
   end

   proc{UpdateBombSim} List in
      {Send Game_Port askBombList(List)}
      {Wait List}
      {BombSim List}
      {UpdateBombSim}
   end


   proc{RunThread Player} PlayerState List NewPlayer Res Res2 ID Pos Map in
      {SimThink}
      {Send Game_Port askPlayerState(PlayerState Player.id)}
      {Wait PlayerState}
      {Send Game_Port alivePlayers(Res)}
      {Wait Res}
      {Send Game_Port askMap(Map)}
      {Wait Map}
      if(PlayerState.life>0 andthen Res>1 andthen {NumberBox Map 0}>0) then
	 {Send Game_Port askChange(Res2)}
	 {Wait Res2}
	 if(Res2==1) then
	    {RunThread PlayerState}
	 else
	    if(PlayerState.needToSpawn==1) then
	       {Send PlayerState.port spawn(?ID ?Pos)}
	       {Wait ID}
	       {Wait Pos}
	       NewPlayer={Record.adjoin PlayerState player(pos:Pos state:on needToSpawn:0)}
	       {Send Game_Port updatePlayer(NewPlayer)}
	       {RunThread NewPlayer}
	    else
	       {MakeAction PlayerState}
	       {RunThread PlayerState}
	    end
	 end
      else
	 skip
      end
   end

   proc{NumberPlayers} GameState Winner in
      {Delay 50}
      {Send Game_Port askGameState(GameState)}
      {Wait GameState}
      if({SeeHowManyPlayers GameState 0}>1) then
	 {NumberPlayers}
      else
	 if({SeeHowManyPlayers GameState 0}==1) then %% Il ne reste qu'un joueur, il gagne
	    Winner={WhoIsWinner GameState}
	    {Delay 2000}
	    {Send GUI_Port displayWinner(Winner)}
	 else
	    Winner = {HighestScore GameState GameState.1}
	    {Delay 2000}
	    {Send GUI_Port displayWinner(Winner)}
	 end
      end
   end

   proc{Simultaneous}
      proc{Launcher List}
	 case List of nil then skip
	 [] H|T then
	    thread {RunThread H} end
	    {Launcher T}
	 end
      end
   in
      local Players in
	 {Send Game_Port askGameState(Players)}
	 {Wait Players}
	 {Launcher Players}
	 thread {UpdateBombSim} end
	 thread {NumberPlayers} end
      end
   end

   proc{SimThink}
      {Delay Input.thinkMin+({OS.rand} mod (Input.thinkMax-Input.thinkMin))}
   end

in

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Initialisation de l'interface graphique %%%%%%%%%%%%%%%%
   GUI_Port = {GUI.portWindow}
   {Send GUI_Port buildWindow}
%%%%%%%%%%%%%%%%%%%% Initialisation des Bombers %%%%%%%%%%%%%%%%%%%%%%%

  if (Input.nbBombers == 2) then
    ListID = {Ids Input.colorsBombers [mario luigi] 1}

  elseif(Input.nbBombers == 5) then
    ListID = {Ids Input.colorsBombers [mario luigi peach toad wario] 1}
  elseif(Input.nbBombers == 10) then  
    ListID = {Ids Input.colorsBombers [mario mario luigi luigi peach peach toad toad wario wario] 1}
  end


   ListBombers = {GenerateBombers Input.bombers ListID}
   Game_Port = {GameState.portGameState ListBombers}
   {Initit ListBombers}
   {Delay 10000}
%%%%%%%%%%%%%%%%%%%%%%%% On lance le jeu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case Input.isTurnByTurn of true then
      {TurnByTurn}
   else
      {Simultaneous}
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
