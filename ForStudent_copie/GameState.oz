functor
import
   Input
   Browser
   Projet2019util
export
   portGameState:StartGameState
define   
   StartGameState
   Sync
   Name = 'namefordebug'
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% FONCTIONS UTILES %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun{Replace List P N Count}
      case List of H|T then
	 if(Count==N) then
	    P|T
	 else
	    H|{Replace T P N Count+1}
	 end
      end
   end

   fun{ReplacePlayer Players NewPlayer}
      case Players of H|T then
	 if(H.id == NewPlayer.id) then
	    NewPlayer|T
	 else
	    H|{ReplacePlayer T NewPlayer}
	 end
      [] nil then nil
      end
   end
   
   fun{DefinePlayers List N}
      case List of H|T then
	 player(id:N pos:_ score:0 life:Input.nbLives port:H allowToPlay:unit)|{DefinePlayers T N+1}
      [] nil then nil
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% FONCTIONS COMPORTEMENTALES %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun{NewGameState List} GameState Players in
      GameState=gamestate(players:_ bomblist:nil bonus:nil map:Input.map points:nil isChanging:0)
      Players={DefinePlayers List 1}
      {Record.adjoin GameState gamestate(players:Players)}
   end
   
   fun{UpdateMap GameState Map}
      {Record.adjoin GameState gamestate(map:Map)}
   end

   fun{UpdatePos GameState Players Pos ID N}
      case Players of H|T then
	 if(H.id == ID) then NewPlayer NewPlayers in
	    NewPlayer = {Record.adjoin H player(pos:Pos)}
	    NewPlayers = {Replace GameState.players NewPlayer N 1}
	    {Record.adjoin GameState gamestate(players:NewPlayers)}
	 else
	    {UpdatePos GameState T Pos ID N+1}
	 end
      [] nil then nil
      end
   end

   fun{UpdateBomb GameState BombList Bomb N} NewList in
      case BombList of H|T then
	 if(H.idBomb == Bomb.idBomb) then
	    NewList = {Replace GameState.bomblist Bomb N 1}
	    {Record.adjoin GameState gamestate(bomblist:NewList)}
	 else
	    {UpdateBomb GameState T Bomb N+1}
	 end
      [] nil then nil
      end
   end

   fun{UpdateBombList GameState BombList}
      {Record.adjoin GameState gamestate(bomblist:BombList)}
   end

   fun{UpdatePoints GameState PointList}
      {Record.adjoin GameState gamestate(points:PointList)}
   end

   fun{UpdateBonus GameState BonusList}
      {Record.adjoin GameState gamestate(bonus:BonusList)}
   end

   fun{UpdatePlayer GameState Players NewPlayer} NewPlayers in
      NewPlayers = {ReplacePlayer Players NewPlayer}
      {Record.adjoin GameState gamestate(players:NewPlayers)}
   end

   fun{SearchState Players ID}
      case Players of H|T then
	 if(H.id == ID) then H
	 else
	    {SearchState T ID}
	 end
      [] nil then nil
      end
   end

   fun{GivePort Players ID}
      case Players of H|T then
	 if(H.id == ID) then
	    H.port
	 else
	    {GivePort T ID}
	 end
      [] nil then nil
      end
   end

in
   fun{StartGameState List}
      Stream Port GameState
   in
      {NewPort Stream Port}
      GameState={NewGameState List} 
      thread
	 {Sync Stream GameState}
      end
      Port
   end

   proc{Sync Stream GameState}
      case Stream of nil then skip
      [] mapChanged(Map)|T then NewState in
	 NewState = {UpdateMap GameState Map}
	 {Sync T NewState}
      [] askMap(Map)|T then
	 Map=GameState.map
	 {Sync T GameState}
      [] playerMoved(Pos ID)|T then NewState in
	 NewState = {UpdatePos GameState GameState.players Pos ID 1}
	 {Sync T NewState}
      [] bombListChanged(BombList)|T then NewState in
	 NewState = {UpdateBombList GameState BombList}
	 {Sync T NewState}
      [] askBombList(BombList)|T then 
	 BombList = GameState.bomblist
	 {Sync T GameState}
      [] pointListChanged(Pos)|T then NewState in
	 NewState = {UpdatePoints GameState Pos}
	 {Sync T NewState}
      [] askPoints(ListPoints)|T then 
	 ListPoints=GameState.points
	 {Sync T GameState}
      [] bonusListChanged(Pos)|T then NewState in
	 NewState = {UpdateBonus GameState Pos}
	 {Sync T NewState}
      [] askBonus(ListBonus)|T then 
	 ListBonus=GameState.bonus
	 {Sync T GameState}
      [] askGameState(State)|T then 
	 State=GameState.players
	 {Sync T GameState}
      [] updateBomb(Bomb)|T then NewState in
	 NewState = {UpdateBomb GameState GameState.bomblist Bomb 1}
	 {Sync T NewState}
      [] updatePlayer(Player)|T then NewState in
	 NewState = {UpdatePlayer GameState GameState.players Player}
	 {Sync T NewState}
      [] askPlayerState(State ID)|T then 
	 State={SearchState GameState.players ID}
	 {Sync T GameState}
      [] giveMePort(ID Port)|T then 
	 Port={GivePort GameState.players ID}
	 {Sync T GameState}
      [] askChange(Res)|T then 
	 Res=GameState.isChanging
	 {Sync T GameState}
      [] changing(Res)|T then NewState in
	 NewState={Record.adjoin GameState gamestate(isChanging:Res)}
	 {Sync T NewState}
      end
   end
   
end
