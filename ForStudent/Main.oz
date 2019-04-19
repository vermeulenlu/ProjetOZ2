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
      [] nil then N
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

   
   fun{GenerateBombers List ID}
      case List#ID of (H1|T1)#(H2|T2) then
	 {PlayerManager.playerGenerator H1 H2}|{GenerateBombers T1 T2}
      [] nil#nil then nil
      end
   end

   fun{GenerateGameState List}
      case List of H|T then
	 player(port:H  pos:_ bombpos:nil bombtimeBeforeExplode:nil idBomber:_ life:Input.nbLives)|{GenerateGameState T}
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

   proc{Fiiire List}
      case List of H|T then
	 {Send GUI_Port spawnFire(H)}
	 {Fiiire T}
      [] nil then skip
      end
   end

   proc{HideFiiire List}
      case List of H|T then
	 {Send GUI_Port hideFire(H)}
	 {HideFiiire T}
      [] nil then skip
      end
   end

   fun{Check X Y Xsup Ysup}
      fun{CheckLoop X Y Xsup Ysup N}
	 local Res XFin YFin in
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
	       case {List.nth {List.nth Input.map Y+Ysup} X+Xsup} of 1 then
		  nil
	       [] 2 then pt(x:XFin y:YFin)|{CheckLoop XFin YFin Xsup Ysup N-1}
	       [] 3 then pt(x:XFin y:YFin)|{CheckLoop XFin YFin Xsup Ysup N-1}
	       [] 4 then pt(x:XFin y:YFin)|{CheckLoop XFin YFin Xsup Ysup N-1}
	       [] 0 then pt(x:XFin y:YFin)|{CheckLoop XFin YFin Xsup Ysup N-1}
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
      local ID Res NewLife ID2 Pos in
	 {Send Player.port gotHit(?ID ?Res)}
	 {Wait ID}
	 {Wait Res}
	 {Send GUI_Port hidePlayer(ID)}
	 case Res of death(NewLife) then
	    {Send Player.port spawn(?ID2 ?Pos)}
	    {Wait ID2}
	    {Wait Pos}
	    {Send GUI_Port spawnPlayer(ID2 Pos)}
	    {Record.adjoin Player player(life:NewLife pos:Pos)}
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
	 

   fun{Explode Player TotalGameState N} NewTotalGameState PosBomb IDBomb PointsToFire NewPlayer R in
      PosBomb=Player.bombpos
      IDBomb=Player.idBomber
      PointsToFire = {Append {Append {Append {Check PosBomb.x PosBomb.y 0 1} {Check PosBomb.x PosBomb.y 0 ~1}} {Check PosBomb.x PosBomb.y 1 0}} {Check PosBomb.x PosBomb.y ~1 0}}
      {Send GUI_Port hideBomb(Player.bombpos)}
      {Fiiire PointsToFire}
      {Delay 300}
      NewTotalGameState={EliminatePlayers PointsToFire TotalGameState}
      {HideFiiire PointsToFire}
      NewPlayer={Record.adjoin Player player(bombtimeBeforeExplode:nil bombpos:nil)}
      {Replace NewTotalGameState NewPlayer N 1}
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
      if(Player.life>0) then on
      else
	 off
      end
   end

   fun{UpdateBomb GameState TotalGameState N} NewGameState NewTotalGameState in 
      case GameState of H|T then
	 if(H.bombtimeBeforeExplode == nil) then
	    H|{UpdateBomb T TotalGameState N+1}
	 else
	    if(H.bombtimeBeforeExplode == 0) then
	       NewTotalGameState = {Explode H TotalGameState N}
	       NewGameState={Append {RetrieveListFirst NewTotalGameState N 0} {RetrieveListLast NewTotalGameState N 1}}
	       {List.nth NewGameState N}|{UpdateBomb {RetrieveListLast NewGameState N 1} NewGameState N+1}
	    else
	       local P in
		  P={Record.adjoin H player(bombtimeBeforeExplode:H.bombtimeBeforeExplode-1)}
		  NewTotalGameState = {Replace TotalGameState P N 1}
		  P|{UpdateBomb T NewTotalGameState N+1}
	       end
	    end
	 end
      [] nil then nil
      end
   end

   fun{MakeAction Player}
      local ID Action Pos in
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

%%%%%%%%%%%%%%%%%%%%%%%%%% Boucle pour traiter un joueur %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input : Etat d'un joueur %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Output : Nouvel Etat du joueur apres Action %%%%%%%%%%%%%%%%%

   fun{OneTurn Player}
      local NewPlayer in
	 NewPlayer={MakeAction Player}
	 NewPlayer
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%% Boucle pour traiter la liste des joueurs %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input : Liste d'etat des joueurs %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Output : Nouvelle liste d'etat sans les joueurs elimines %%%%%%%%%%%%%%%%%
   
   fun{Run GameState}
      {Delay 500}
      case GameState of H|T then
	 {OneTurn H}|{Run T}
      [] nil then nil
      end
   end   

%%%%%%%%%%%%%%%%%%% Procédure TurnByTurn %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Input : Liste d'etat des joueurs %%%%%%%%%%%%
   
   proc{TurnByTurn GameState}
      local NewGameState1 NewGameState2 in
	 NewGameState1 = {UpdateBomb GameState GameState 1}
	 NewGameState2 = {Run NewGameState1}
	 {Print 'GAMESTATE : '#{Length NewGameState1 0}#''}
	 if({SeeHowManyPlayers NewGameState2 0} >1) then %% Le jeu comporte encore plus de un joueur
	    {TurnByTurn NewGameState2}
	 else
	    skip %% Il faut afficher le vainqueur
	 end
      end
   end
   
   
   in

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% Initialisation de l'interface graphique %%%%%%%%%%%%%%%%
   GUI_Port = {GUI.portWindow}
   {Send GUI_Port buildWindow}                                        
%%%%%%%%%%%%%%%%%%%% Initialisation des Bombers %%%%%%%%%%%%%%%%%%%%%%%
   ListID = {Ids Input.colorsBombers [lucas jerem] 1}
   ListBombers = {GenerateBombers Input.bombers ListID}
   {Initit ListBombers}
   {Delay 3000}
%%%%%%%%%%%%%%%%%%%%%%%% On lance le jeu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   GameState = {GenerateGameState ListBombers}
   {TurnByTurn GameState}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end