functor
import
   GUI 
   Input 
   PlayerManager
   System(showInfo:Print)
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

   proc{Initit List}
      case List of H|T then
	 local ID Pos in
	    {Send H assignSpawn(pt(x:2 y:2))}
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

   proc{MakeAction Player}
      local ID Action Pos in
	 {Send Player doaction(ID Action)}
	 {Wait ID}
	 {Wait Action}
	 case Action of move(Pos)
	 then
	    {Wait Pos}
	    {Send GUI_Port movePlayer(ID Pos)}
	 [] bomb(Pos) then
	    {Send GUI_Port spawnBomb(Pos)}
	 end
      end
   end

   fun{GetState Player}
      local ID State in
	 {Send Player getState(?ID ?State)}
	 {Wait ID}
	 {Wait State}
	 State
      end
   end
   

%%%%%%%%%%%%%%%%%%%%%%%%%% Boucle pour traiter un joueur %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input : Etat d'un joueur %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Output : Nouvel Etat du joueur apres Action %%%%%%%%%%%%%%%%%

   fun{OneTurn Player}
      {MakeAction Player}
      Player
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%% Boucle pour traiter la liste des joueurs %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input : Liste d'etat des joueurs %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Output : Nouvelle liste d'etat sans les joueurs elimines %%%%%%%%%%%%%%%%%
   
   fun{Run GameState}
      {Delay 500}
      case GameState of H|T then
	case {GetState H} of off then %% Si le player est mort, on le retire de la liste des players
	    {Run T}
	 else
	    {OneTurn H}|{Run T}
	 end
      [] nil then nil
      end
   end   

%%%%%%%%%%%%%%%%%%% Procédure TurnByTurn %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Input : Liste d'etat des joueurs %%%%%%%%%%%%
   
   proc{TurnByTurn GameState}
      local NewGameState in
	 NewGameState = {Run GameState}
	 if({Length NewGameState 0} > 1) then %% Le jeu comporte encore plus de un joueur
	    {TurnByTurn NewGameState}
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
%%%%%%%%%%%%%%%%%%%%%%%% On lance le jeu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   {TurnByTurn ListBombers}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
COUUUUU
end
