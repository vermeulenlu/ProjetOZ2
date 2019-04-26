functor
import
   Input
   Browser
   Projet2019util
   System(showInfo:Print)
   OS
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

   %%%%%%%%%%%%%%%%%%%% Fonctions utiles %%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{NewEtat ID}
      etat(bomber:ID state:on life:Input.nbLives score:0 bomb:1 action:nil spawn:nil pos:nil posBomb:nil map:Input.map)
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
	    else RandX=RandXX
	    end
	    if(RandYsign==0) then
	       RandY=(~RandYY)
	    else RandY=RandYY
	    end
	    Pos = pt(x:X+RandX y:Y+RandY)
	    if({List.nth {List.nth Input.map Pos.y} Pos.x}==1 orelse {List.nth {List.nth Input.map Pos.y} Pos.x} ==2 orelse {List.nth {List.nth Input.map Pos.y} Pos.x}==3 ) then {Try}
	    else
	       if((RandX)*(RandY) == 0) then Pos
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
      Pos=Etat.pos
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
	           X = {OS.rand} mod 3
	           local Pos in
	               if(X==0) then
		                NewEtat={Move Etat Pos}
		                NewEtat2={Record.adjoin NewEtat etat(action:move(Pos))}
		                Action=NewEtat2.action
		                NewEtat2
	               else
		                NewEtat = {Bomb Etat Pos}
		                NewEtat2 = {Record.adjoin Etat etat(action:bomb(Pos))}
		                Action=NewEtat.action
		                NewEtat2
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
	 Res=Etat.score+1
	 {Record.adjoin Etat etat(score:Etat.score+1)}
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
	           NewEtat={Record.adjoin Etat etat(action:death(NewLife) life:NewLife)}
	           Res=NewEtat.action
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
      [] bombPlanted(Pos)%% Bomb has been planted at <position> Pos
        then Etat %%Useless pour la version random
      [] bombExploded(Pos)%% Bomb has exploded at <position> Pos
        then Etat %%Useless pour la version random, sert a quoi ?
      [] boxRemoved(Pos)
        then
            local NewMap in
              NewMap = {Replace Etat.map {Replace {List.nth Etat.map Pos.y} 0 Pos.x 1} Pos.y 1} %%Change la map interne du joueur

              {Record.adjoin Etat etat(map:NewMap)} %%Renvoie l'etat avec la nouvelle map
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
