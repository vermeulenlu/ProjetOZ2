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
   Move
   Doaction
   GetState
   %%%%%%%%%%%%%%%%%%%% Fonctions utiles %%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun{NewEtat ID}
      etat(bomber:ID state:on life:Input.nbLives score:0 bomb:1 action:nil)
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
  
in
   %%%%%%%%%%%%%%%%%%%% Fonctions comportementales %%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun{Spawn Etat ID Pos}
      fun{NewSpawn} Pos in
	 Pos = {MapRandomPos}
	 if {IsASpawn Pos} then
	    Pos
	 else
	    {NewSpawn}
	 end
      end
      NewEtat
   in
      NewEtat = {Record.adjoin Etat etat(pos:{NewSpawn})}
      ID = NewEtat.bomber
      Pos = NewEtat.pos
      NewEtat
   end
   
   fun{Doaction Etat ID Action} NewEtat in 
      if(Etat.state==off) then
	 NewEtat = {Record.adjoin Etat etat(action:nil bomber:nil)}
	 ID=NewEtat.bomber
	 Action=NewEtat.action
	 NewEtat
      else
	 ID = Etat.bomber
	 local X in
	    X = {OS.rans} mod 3
	    if(X==0) then
	       NewEtat = {Record.adjoin Etat etat(action:'move(Pos)')}
	       ID=NewEtat.bomber
	       Action=NewEtat.action
	       NewEtat
	    else
	       NewEtat = {Record.adjoin Etat etat(action:'move(Pos)')}
	       ID=NewEtat.bomber
	       Action=NewEtat.action
	       NewEtat
	    end
	 end
      end
   end

   fun{Move Etat ID Pos}
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
	    if({List.nth {List.nth Input.map Pos.y} Pos.x}==1) then {Try}
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
      ID = NewEtat.bomber
      Pos = NewEtat.pos
      NewEtat
   end

   proc{GetState Etat ID State}
      State=Etat.state
      ID=Etat.bomber
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
      [] move(ID Pos)|T then NewEtat in
	 NewEtat = {Move Etat ID Pos}
	 {TreatStream T NewEtat}
      [] getState(ID State)|T then
	 {GetState Etat ID State}
	 {TreatStream T Etat}
       [] doaction(ID Action)|T then NewEtat in
       	 NewEtat = {Doaction Etat ID Action}
       	 {TreatStream T NewEtat}
      end
   end
end
