functor
import
   GUI 
   Input 
   PlayerManager
   System(showInfo:Print)
   OS
define
   GUI_Port
   ListBombers
   GameState
   ListID

   fun{Length List N}
      case List of H|T then
	 {Length T N+1}
      else
	 N
      end
   end

   fun{Append L1 L2}
      case L1 of H|T then
	 H|{Append T L2}
      [] nil then
	 L2
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

   fun{Ids Colors Name NId}
      if(NId >Input.nbBombers) then nil
      else 
	 case Colors#Name of (H1|T1)#(H2|T2) then
	    bomber(id:NId color:H1 name:H2)|{Ids T1 T2 NId+1}
	 [] nil#nil then nil
	 end
      end
   end

   fun{CheckScore GameState Winner}
      case GameState of H|T then
	 if(H.score>Winner.score) then
	    {CheckScore T H}
	 else
	    {CheckScore T Winner}
	 end
      [] nil then Winner
      end
   end

   fun{CheckWinner GameState}
      case GameState of H|T then
	 case {GetState H} of on then H
	 else
	    {CheckWinner T}
	 end
      end
   end

   
   fun{GenerateBombers List ID}
      case List#ID of (H1|T1)#(H2|T2) then
	 {PlayerManager.playerGenerator H1 H2}|{GenerateBombers T1 T2}
      [] nil#nil then nil
      end
   end

   fun{GenerateGameState List}
      case List of H|T then
	 player(port:H  pos:_ bombpos:nil bombtimeBeforeExplode:nil idBomber:_ life:Input.nbLives map:Input.map)|{GenerateGameState T}
      [] nil then nil
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
	    {Initit T}
	 end
      [] nil then skip
      end
   end

   fun{RetrieveListLast List N Count}
      case List of H|T then
	 if(Count==N) then T
	 else
	    {RetrieveListLast T N Count+1}
	 end
      [] nil then nil
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

   fun{UpdateMapToPlayers GameState Map}
      case GameState of H|T then
	 {Record.adjoin H player(map:Map)}|{UpdateMapToPlayers T Map}
      [] nil then nil
      end
   end

   fun{UpdateMap NewMap Pos GameState} NewPlayer in
      case GameState of H|T then
	 NewPlayer={Record.adjoin H player(map:NewMap)}
	 {Send NewPlayer.port info(boxRemoved(Pos))}
	 NewPlayer|{UpdateMap NewMap Pos T}
      [] nil then nil
      end
   end

   fun{Fiiire Points Map Port GameState} NewGameState in
      case Points of H|T then
	 {Send GUI_Port spawnFire(H)}
	 case {List.nth {List.nth Map H.y} H.x} of 2 then
	    local Res ID NewMap in
	       {Send GUI_Port hideBox(H)}
	       {Send Port add(point 1 ?Res)}
	       {Wait Res}
	       {Send Port getId(?ID)}
	       {Wait ID}
	       {Send GUI_Port scoreUpdate(ID Res)}
	       NewMap={Replace Map {Replace {List.nth Map H.y} 0 H.x 1} H.y 1}
	       NewGameState={UpdateMap NewMap H GameState}
	       {Fiiire T NewMap Port NewGameState}
	    end
	 [] 3 then
	    local Res ID NewMap in
	       {Send GUI_Port hideBox(H)}
	       {Send Port add(bomb 1 ?Res)}
	       {Wait Res}
	       {Send Port getId(?ID)}
	       {Wait ID}
	       NewMap={Replace Map {Replace {List.nth Map H.y} 0 H.x 1} H.y 1}
	       NewGameState={UpdateMap NewMap H GameState}
	       {Fiiire T NewMap Port NewGameState}
	    end
	 else
	    {Fiiire T Map Port GameState}
	 end
      [] nil then GameState
      end
   end

   proc{HideFiiire List}
      case List of H|T then
	 {Send GUI_Port hideFire(H)}
	 {HideFiiire T}
      [] nil then skip
      end
   end

   fun{Check X Y Xsup Ysup Player}
      fun{CheckLoop X Y Xsup Ysup N}
	 local XFin YFin in
	    if(Xsup<0) then XFin=X-1
	    else
	       XFin=(X)+(Xsup)
	    end
	    if(Ysup<0) then YFin=Y-1
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
	       case {List.nth {List.nth Player.map Y+Ysup} X+Xsup} of 1 then
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

   fun{GotHit Player}
      local ID Res ID2 Pos in
	 {Send Player.port gotHit(?ID ?Res)}
	 {Wait ID}
	 {Wait Res}
	 {Send GUI_Port hidePlayer(ID)}
	 case Res of death(NewLife) then
	    if(NewLife==0) then
	       {Send GUI_Port lifeUpdate(ID NewLife)}
	       {Record.adjoin Player player(life:NewLife)}
	    else
	       {Send Player.port spawn(?ID2 ?Pos)}
	       {Wait ID2}
	       {Wait Pos}
	       {Send GUI_Port lifeUpdate(ID2 NewLife)}
	       {Send GUI_Port spawnPlayer(ID2 Pos)}
	       {Record.adjoin Player player(life:NewLife pos:Pos)}
	    end
	 else
	    Player
	 end
      end
   end
      

   fun{EliminatePlayers Points GameState}
      case GameState of H|T then
	 local Gone NewPlayer in
	    Gone={IsPresent H.pos Points}
	    if(Gone==true) then
	       NewPlayer={GotHit H}
	       NewPlayer|{EliminatePlayers Points T}
	    else
	       H|{EliminatePlayers Points T}
	    end
	 end
      [] nil then nil
      end
   end
	 

   fun{Explode Player TotalGameState N} NewTotalGameState PosBomb IDBomb PointsToFire NewPlayer NewMap R in
      PosBomb=Player.bombpos
      IDBomb=Player.idBomber
      PointsToFire = {Append {Append {Append {Append {Check PosBomb.x PosBomb.y 0 1 Player} {Check PosBomb.x PosBomb.y 0 ~1 Player}} {Check PosBomb.x PosBomb.y 1 0 Player}} {Check PosBomb.x PosBomb.y ~1 0 Player}} [pt(x:PosBomb.x y:PosBomb.y)]}
      {Send GUI_Port hideBomb(Player.bombpos)}
      NewMap={Fiiire PointsToFire Player.map Player.port TotalGameState}
      {Delay 1000}
      NewTotalGameState={EliminatePlayers PointsToFire NewMap}
      {HideFiiire PointsToFire}
      NewPlayer={Record.adjoin {List.nth NewTotalGameState N} player(bombtimeBeforeExplode:nil bombpos:nil)}
      local Res in
	 {Send NewPlayer.port add(bomb 1 Res)}
	 {Wait Res}
      end
      R={Replace NewTotalGameState NewPlayer N 1}
      R
   end

   fun{SeeHowManyPlayers List N}
      case List of H|T then
	 case {GetState H} of on then {SeeHowManyPlayers T N+1}
	 [] off then {SeeHowManyPlayers T N}
	 end
      [] nil then N
      end
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
   

   fun{GetState Player}
      local ID State in
	 {Send Player.port getState(?ID ?State)}
	 {Wait ID}
	 {Wait State}
	 State
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%% Fonction pour checker si une bombe doit exploser et ses MAJ %%%%%%%%%%%%%%%%%%%%%
   
   fun{UpdateBomb Player TotalGameState N} NewTotalGameState in 
      if(Player.bombtimeBeforeExplode == nil) then
	 TotalGameState
      else
	 if(Player.bombtimeBeforeExplode == 0) then
	    NewTotalGameState = {Explode Player TotalGameState N}
	    {Append {RetrieveListFirst NewTotalGameState N 0} {RetrieveListLast NewTotalGameState N 1}}
	 else
	    local P in
	       P={Record.adjoin Player player(bombtimeBeforeExplode:Player.bombtimeBeforeExplode-1)}
	       {Replace TotalGameState P N 1}
	    end
	 end
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%% Action d un joueur : Move ou Bomb %%%%%%%%%%%%%%%%%%%%%
   
   fun{MakeAction Player}
      local ID Action in
	 {Send Player.port doaction(ID Action)}
	 {Wait ID}
	 {Wait Action}
	 case Action of move(Pos)
	 then
	    {Send GUI_Port movePlayer(ID Pos)}
	    {Record.adjoin Player player(pos:Pos)}
	 [] bomb(Pos) then
	    {Send GUI_Port spawnBomb(Pos)}
	    {Record.adjoin Player player(bombpos:Pos bombtimeBeforeExplode:Input.timingBomb idBomber:ID)}
	 end
      end
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%% Boucle pour traiter la liste des joueurs %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input : Liste d'etat des joueurs %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Output : Nouvelle liste d'etat sans les joueurs elimines %%%%%%%%%%%%%%%%%
   
   fun{Run GameState TotalGameState N} NewGameState R in
      {Delay 220}
      case GameState of H|T then
	 R=TotalGameState
	 % {Print 'NEWMAP DU PLAYER1 : '#{List.nth R.1.map.2.1 4}#', NEWMAP DU PLAYER2 : '#{List.nth R.2.1.map.2.1 4}#''}
	 % {Print 'NEWMAP DU PLAYER1 : '#{List.nth R.1.map.2.1 5}#', NEWMAP DU PLAYER2 : '#{List.nth R.2.1.map.2.1 5}#''}
	 % {Print 'NEWMAP DU PLAYER1 : '#{List.nth R.1.map.2.2.1 2}#', NEWMAP DU PLAYER2 : '#{List.nth R.1.map.2.2.1 2}#''}
	 % {Print 'NEWMAP DU PLAYER1 : '#{List.nth R.1.map.2.2.2.1 2}#', NEWMAP DU PLAYER2 : '#{List.nth R.1.map.2.2.2.1 2}#''}
	 NewGameState={UpdateBomb H TotalGameState N}
	 % {Print 'NEWMAP DU PLAYER1AFTERBOMB : '#{List.nth NewGameState.1.map.2.1 4}#', NEWMAP DU PLAYER2AFTERBOMB : '#{List.nth NewGameState.2.1.map.2.1 4}#''}
	 % {Print 'NEWMAP DU PLAYER1AFTERBOMB : '#{List.nth NewGameState.1.map.2.1 5}#', NEWMAP DU PLAYER2AFTERBOMB : '#{List.nth NewGameState.2.1.map.2.1 5}#''}
	 % {Print 'NEWMAP DU PLAYER1AFTERBOMB : '#{List.nth NewGameState.1.map.2.2.1 2}#', NEWMAP DU PLAYER2AFTERBOMB : '#{List.nth NewGameState.1.map.2.2.1 2}#''}
	 % {Print 'NEWMAP DU PLAYER1AFTERBOMB : '#{List.nth NewGameState.1.map.2.2.2.1 2}#', NEWMAP DU PLAYER2AFTERBOMB : '#{List.nth NewGameState.1.map.2.2.2.1 2}#''}
	 {Delay 220}
	 case {GetState {List.nth NewGameState N}} of on then
	    {MakeAction {List.nth NewGameState N}}|{Run {RetrieveListLast NewGameState N 1} NewGameState N+1}
	 [] off then
	    {List.nth NewGameState N}|{Run {RetrieveListLast NewGameState N 1} NewGameState N+1}
	 end
      [] nil then nil
      end
   end   

%%%%%%%%%%%%%%%%%%% Procédure TurnByTurn %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Input : Liste d'etat des joueurs %%%%%%%%%%%%
   
   proc{TurnByTurn GameState}
      local NewGameState MapToUpdate NewState in
	 NewGameState = {Run GameState GameState 1}
	 MapToUpdate={List.nth NewGameState {Length NewGameState 0}}.map
	 NewState={UpdateMapToPlayers NewGameState MapToUpdate}
	 % {Print 'NEWMAP DU PLAYER1AFTERUPDATE : '#{List.nth NewState.1.map.2.1 4}#', NEWMAP DU PLAYER2AFTERUPDATE : '#{List.nth NewState.2.1.map.2.1 4}#''}
	 % {Print 'NEWMAP DU PLAYER1AFTERUPDATE : '#{List.nth NewState.1.map.2.1 5}#', NEWMAP DU PLAYER2AFTERUPDATE : '#{List.nth NewState.2.1.map.2.1 5}#''}
	 % {Print 'NEWMAP DU PLAYER1AFTERUPDATE : '#{List.nth NewState.1.map.2.2.1 2}#', NEWMAP DU PLAYER2AFTERUPDATE : '#{List.nth NewState.1.map.2.2.1 2}#''}
	 % {Print 'NEWMAP DU PLAYER1AFTERUPDATE : '#{List.nth NewState.1.map.2.2.2.1 2}#', NEWMAP DU PLAYER2AFTERUPDATE : '#{List.nth NewState.1.map.2.2.2.1 2}#''}
	 if({SeeHowManyPlayers NewState 0}>1) then%% Le jeu comporte encore plus de un joueur
	    {TurnByTurn NewState}
	 else
	    case {SeeHowManyPlayers NewState 0} of 0 then
	       local Winner ID in
		  Winner={CheckScore NewState NewState.1}
		  {Send Winner.port getId(ID)}
		  {Wait ID}
		  {Send GUI_Port displayWinner(ID)}
	       end
	    else
	       local Winner ID in
		  Winner={CheckWinner NewState}
		  {Send Winner.port getId(ID)}
		  {Wait ID}
		  {Send GUI_Port displayWinner(ID)}
	       end
	    end
	 end
      end
   end
   
   
   in

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% Initialisation de l'interface graphique %%%%%%%%%%%%%%%%
   GUI_Port = {GUI.portWindow}
   {Send GUI_Port buildWindow}                                        
%%%%%%%%%%%%%%%%%%%% Initialisation des Bombers %%%%%%%%%%%%%%%%%%%%%%%
   ListID = {Ids Input.colorsBombers [lucas jerem jean] 1}
   ListBombers = {GenerateBombers Input.bombers ListID}
   {Initit ListBombers}
   {Delay 10000}
%%%%%%%%%%%%%%%%%%%%%%%% On lance le jeu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   GameState = {GenerateGameState ListBombers}
   {TurnByTurn GameState}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end