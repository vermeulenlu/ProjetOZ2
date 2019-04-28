functor
import
   Input
   Browser
   Projet2019util
   System(showInfo:Print)
   OS
   Number
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream
   Name = 'namefordebug'
   Spawn
   Doaction
   GetState
   GetId
   AssignSpawn
   Add
   GotHit
   Replace
   Info


   SafePoint %%TOCHECK
   FindSafePath %%TOCHECK
   IsCovered %%TOCHECK
   IsBombNear %%TOCHECK
   NewExplorerMap%%TOCHECK
   PossiblePoint%%TOCHECK
   SelectShortestPath%%TOCHECK
   MinPath%%TOCHECK
   RetireBombOnPos%%TOCHECK
   FindObstacle%%TOCHECK


%%%%%%%%%%%%%%%%%%%% Fonctions utiles %%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{SafePoint PosX PosY Etat}
      local NearBombList IsSafePoint in
        NearBombList = {IsBombNear PosX PosY Etat.posBomb nil}
        IsSafePoint = {IsCovered PosX PosY NearBombList Etat.map}
        IsSafePoint
      end
   end

   fun{FindSafePath PosX PosY Carte SafePath Etat}%%BFS pour trouver le point safe le plus proche, retourne la liste des position pour y accéder
      %%Check dans toute les directions si les points sont safes.
      if ({SafePoint PosX PosY Etat}) then local PathToFollow in %% Si on est sur une case safe, on return le chemin complet pour arriver jusqu'a nous
          PathToFollow = pos(x:PosX y:PosY)|SafePath
          PathToFollow
          end
      else
        if ({PossiblePoint PosX+1 PosY Carte} orelse {PossiblePoint PosX-1 PosY Carte} orelse {PossiblePoint PosX PosY+1 Carte} orelse {PossiblePoint PosX PosY-1 Carte}) then local NewCarte PathToRight PathToLeft PathToTop  PathToBottom in%%Si possible d'aller dans une direction

            NewCarte = {Replace Carte {Replace {List.nth Carte PosY} 7 PosX 1} PosY 1} %%Marque la position comme 7 (= visitée)
            PathToRight = {FindSafePath PosX+1 PosY NewCarte pos(x:PosX y:PosY)|SafePath Etat}
            PathToLeft = {FindSafePath PosX-1 PosY NewCarte pos(x:PosX y:PosY)|SafePath Etat}
            PathToTop = {FindSafePath PosX+1 PosY NewCarte pos(x:PosX y:PosY)|SafePath Etat}
            PathToBottom = {FindSafePath PosX+1 PosY NewCarte pos(x:PosX y:PosY)|SafePath Etat}
            {SelectShortestPath PathToRight PathToLeft PathToBottom PathToTop}%%Renvoie le chemin le plus court vers un point safe.
            end

        else %%Si on ne peut aller nulle part et qu'on est pas safe, on abandonne le chemin
            nil
        end
      end
   end



   fun{SelectShortestPath L1 L2 L3 L4}
      {MinPath {MinPath L1 L2} {MinPath L3 L4}}
   end

   fun{MinPath L1 L2}
     case L1 of nil then
       L2
     [] H|T then
        case L2 of nil then
          L1
        [] H|T then
           if ({List.length L2} < {List.length L1}) then
              L2
           else
              L1
           end
        end
     end
   end


   fun{PossiblePoint PosX PosY Carte}
      if ({List.nth {List.nth Carte PosY} PosX} \= 0) then
        false
      else
        true
      end
   end

   fun{IsCovered PosX PosY NearBombList Map} %%Check si il y a un obstacle pour bloquer l'explosion des bombes proches
      case NearBombList of H|T then
          if(PosX == H.x andthen PosY==H.y) then
              false
          elseif ({Number.abs PosX-{Number.abs H.x}} == 1 orelse {Number.abs PosY-{Number.abs H.y}} == 1) then %%Si la bombe est a une case, pas possible qu'il y ai un obstacle
              false
          elseif ({FindObstacle PosX PosY H.x H.y}) then
              {IsCovered PosX PosY T Map}
          else
              false
          end
      []nil then %% On est couvert de toutes les bombes
          true
      end
   end


   fun{FindObstacle PosX1 PosY1 PosX2 PosY2} ToGo in
      if (PosX1 == PosX2) then
        ToGo = PosY1 - PosY2
        if (ToGo < ~1) then
            if ({List.nth {List.nth Map PosY1+1} PosX1} == 2 orelse {List.nth {List.nth Map PosY1+1} PosX1}==3) then
                true
            else
                {FindObstacle PosX1 PosY1+1 PosX2 PosY2}
            end

        elseif (ToGo > 1) then
            if ({List.nth {List.nth Map PosY1-1} PosX1} == 2 orelse {List.nth {List.nth Map PosY1-1} PosX1}==3) then
                true
            else
                {FindObstacle PosX1 PosY1-1 PosX2 PosY2}
            end
        else
            false
        end
      else
        ToGo = PosX1 - PosX2
        if (ToGo <  ~1) then
          if ({List.nth {List.nth Map PosY1} PosX1+1} == 2 orelse {List.nth {List.nth Map PosY1} PosX1+1}==3) then
              true
          else
              {FindObstacle PosX1+1 PosY1 PosX2 PosY2}
          end

        elseif (ToGo > 1) then
          if ({List.nth {List.nth Map PosY1} PosX1-1} == 2 orelse {List.nth {List.nth Map PosY1} PosX1-1}==3) then
              true
          else
              {FindObstacle PosX1-1 PosY1 PosX2 PosY2}
          end
        else
          false
        end
     end
   end

   fun{IsBombNear PosX PosY BombList NearBombList}  %%check si il y a une bombe entre PosX et PosX +-Input.fire ou entre PosY et PosY+-2. Return la pos des bombes qui respectent ces conditions
      case BombList of H|T then
          if (PosX == H.x andthen PosY == H.y) then %%Bombe sur notre position
              {IsBombNear PosX PosY T {Append NearBombList H}}
          elseif (PosX+Input.fire >= H.x andthen PosY == H.y) then %%Bombe a droite
              {IsBombNear PosX PosY T {Append NearBombList H}}
          elseif (PosX-Input.fire =< H.x andthen PosY == H.y) then %%Bombe à gauche
              {IsBombNear PosX PosY T {Append NearBombList H}}
          elseif (PosY+Input.fire >= H.y andthen PosX == H.x) then %%Bombe en haut
              {IsBombNear PosX PosY T {Append NearBombList H}}
          elseif (PosY-Input.fire =< H.y andthen PosX == H.x) then %%Bombe en bas
              {IsBombNear PosX PosY T {Append NearBombList H}}
          else
              {IsBombNear PosX PosY T NearBombList}
          end
      [] nil then
          NearBombList
      end
   end

   fun{NewExplorerMap Etat}
      carte(map:Etat.map)
   end

   fun{RetireBombOnPos List Pos}
      case List of H|T then
        local PosX PosY HPos HPosX HPosY in
          PosX = Pos.x
          PosY = Pos.y
          HPos = H.pos
          HPosX = HPos.x
          HPosY = HPos.y
          if(HPosY==Pos.y andthen HPosX == Pos.x) then
            T
          else
            H|{RetireBombOnPos T Pos}
          end
        end
      [] nil then nil
      end
  end

   fun{NewEtat ID}
      etat(bomber:ID state:on life:Input.nbLives score:0 bomb:1 spawn:nil pos:nil posBomb:nil map:Input.map)
   end


   fun{Append L1 L2}
      case L1 of H|T then
	 H|{Append T L2}
      [] nil then
	 L2
      end
   end

   fun{Move Etat Pos}
      fun{Try}
	       local X Y RandX RandXsign RandY RandYsign Pos RandXX RandYY in
	           X=Etat.pos.x
	           Y=Etat.pos.y
	           RandXX={OS.rand} mod 2
	           RandYY={OS.rand} mod 2
	           RandXsign = {OS.rand} mod 2
	           RandYsign = {OS.rand} mod 2
	           if(RandXsign==0) then
	               RandX=(~RandXX)
	           else
                 RandX=RandXX
	           end
	           if(RandYsign==0) then
	               RandY=(~RandYY)
	           else
                 RandY=RandYY
	           end
	           Pos = pt(x:X+RandX y:Y+RandY)
	           if({List.nth {List.nth Etat.map Pos.y} Pos.x}==1 orelse {List.nth {List.nth Etat.map Pos.y} Pos.x} ==2 orelse {List.nth {List.nth Etat.map Pos.y} Pos.x}==3 ) then
                 {Try}
	           else
	               if((RandX)*(RandY) == 0) then
		                  if(RandX+RandY == 0) then
                          {Try}
		                  else
		                      Pos
		                  end
	               else
		                {Try}
	               end
	           end
	       end
      end
      NewEtat
   in
      NewEtat = {AdjoinList Etat [pos#{Try}]}
      Pos = NewEtat.pos
      NewEtat
   end

   fun{Bomb Etat Pos}
      {Record.adjoin Etat etat(bomb:Etat.bomb-1 posBomb:Pos|Etat.posBomb)}
   end

in
%%%%%%%%%%%%%%%%%%%% Fonctions comportementales %%%%%%%%%%%%%%%%%%%%%%%%%

   fun{GetId Etat ID}
      ID=Etat.bomber
      Etat
   end

   fun{GetState Etat ID State}
      State=Etat.state
      ID=Etat.bomber
      Etat
   end

   fun{AssignSpawn Etat Pos}
      {Record.adjoin Etat etat(spawn:Pos)}
   end

   fun{Spawn Etat ID Pos}
      if(Etat.life>0) then
	 ID=Etat.bomber
	 Pos=Etat.spawn
	 {Record.adjoin Etat etat(pos:Pos state:on)}
      else
	 ID=nil
	 Pos=nil
	 {Record.adjoin Etat etat(pos:nil state:off)}
      end
   end

   fun{Doaction Etat ID Action} NewEtat NewEtat2 in
      if(Etat.state==off) then
	       NewEtat = {Record.adjoin Etat etat(action:nil bomber:nil)}
	       ID=NewEtat.bomber
	       Action=NewEtat.action
	       NewEtat
      else
	       ID = Etat.bomber
	       local X in
	           X = {OS.rand} mod 16
	           local Pos Pos2 in
	               if(X>0) then
		                  NewEtat={Move Etat Pos2}
		                  Pos=NewEtat.pos
		                  Action=move(Pos)
		                  NewEtat
	               else
		                  NewEtat={Bomb Etat Etat.pos}
		                  Pos=NewEtat.pos
		                  Action=bomb(Pos)
		                  NewEtat
	               end
	           end
	       end
      end
   end

   fun{Add Etat Type Option Res}
      case Type of bomb then
	       Res=Etat.bomb+1
	       {Record.adjoin Etat etat(bomb:Etat.bomb+1)}
      [] point then
	       Res=Etat.score+Option
	       {Record.adjoin Etat etat(score:Etat.score+Option)}
      end
   end

   fun{GotHit Etat ID Res}
      if(Etat.state==off) then
	       ID=nil
	       Res=nil
	       {Record.adjoin Etat etat(bomber:nil)}
      else
	       ID=Etat.bomber
	       local NewLife NewEtat in
	           NewLife=Etat.life-1
	           NewEtat={Record.adjoin Etat etat(life:NewLife)}
	           Res=death(NewLife)
	           NewEtat
	       end
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

   fun{Info Etat Message} %%TODO
      case Message of spawnPlayer(ID Pos) %% Player <bomber> ID has spawn in <position> Pos
      then Etat %%Useless pour la version random
      [] movePlayer(ID Pos) %% Player <bomber> ID has move to <position> Pos
      then Etat %%Useless pour la version random
      [] deadPlayer(ID)%% Player <bomber> ID has died
      then Etat %%Useless pour la version random
      [] bombPlanted(Pos) then local NewEtat in
        NewEtat = {Record.adjoin Etat etat(posBomb:Pos|Etat.posBomb)}
        NewEtat
        end
      [] bombExploded(Pos) then local NewEtat NewBombList in
        NewBombList = {RetireBombOnPos Etat.posBomb Pos}
        NewEtat = {Record.adjoin Etat etat(posBomb:NewBombList)}
        end
      [] boxRemoved(Pos) then
	       local NewMap PosX PosY NewEtat in
            PosX=Pos.x
            PosY=Pos.y
            NewMap = {Replace Etat.map {Replace {List.nth Etat.map Pos.y} 0 PosX 1} PosY 1} %%Change la map interne du joueur
	          NewEtat={Record.adjoin Etat etat(map:NewMap)} %%Renvoie l'etat avec la nouvelle map
            NewEtat
	       end
      end

   end

%%%%%%%%%%%%%%%%%%%% Fonctions exécutives %%%%%%%%%%%%%%%%%%%%%%%%%%



   fun{StartPlayer ID}
      Stream
      Port
      Etat
      OutputStream
   in
      {NewPort Stream Port}
      thread %% filter to test validity of message sent to the player
	 OutputStream = {Projet2019util.portPlayerChecker Name ID Stream}
	 Etat = {NewEtat ID}
      end
      thread
	 {TreatStream OutputStream Etat}
      end
      Port
   end


   proc{TreatStream Stream Etat} %% TODO you may add some arguments if needed
      case Stream of nil then skip
      [] spawn(ID Pos)|T then NewEtat in
	 NewEtat = {Spawn Etat ID Pos}
	 {TreatStream T NewEtat}
      [] getState(ID State)|T then NewEtat in
	 NewEtat = {GetState Etat ID State}
	 {TreatStream T NewEtat}
      [] getId(ID)|T then NewEtat in
	 NewEtat = {GetId Etat ID}
	 {TreatStream T NewEtat}
      [] doaction(ID Action)|T then NewEtat in
	 NewEtat = {Doaction Etat ID Action}
	 {TreatStream T NewEtat}
      [] assignSpawn(Pos)|T then NewEtat in
	 NewEtat = {AssignSpawn Etat Pos}
	 {TreatStream T NewEtat}
      [] add(Type Option Res)|T then NewEtat in
	 NewEtat = {Add Etat Type Option Res}
	 {TreatStream T NewEtat}
      [] gotHit(ID Res)|T then NewEtat in
	 NewEtat = {GotHit Etat ID Res}
	 {TreatStream T NewEtat}
      [] info(Message)|T then NewEtat in
	 NewEtat = {Info Etat Message}
	 {TreatStream T NewEtat}
      end
   end




end
