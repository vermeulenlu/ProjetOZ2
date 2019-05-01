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
   Name = 'player000AI'
   Spawn
   Doaction
   GetState
   GetId
   AssignSpawn
   Add
   GotHit
   Replace
   Info

   CanIMove
   CanIEscape
   Menace

%%%%%%%%%%%%%%%%%%%% Fonctions utiles %%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{NewEtat ID}
      etat(bomber:ID state:on life:Input.nbLives score:0 bomb:1 spawn:nil pos:nil posBomb:nil map:Input.map)
   end

   fun{Length List N}
      case List of H|T then
	 {Length T N+1}
      [] nil then
	 N
      end
   end

   fun{Nth List N Count}
      case List of H|T then
	 if(Count==N) then
	    H
	 else
	    {Nth T N Count+1}
	 end
      [] nil then
	 nil
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

   fun{Swipe A B List} NewList in
      NewList = {Replace List {Nth List A 1} B 1}
      {Replace NewList {Nth List B 1} A 1}
   end

   fun{Shuffle List N} R in
      if(N==0) then List
      else
	 R=({OS.rand} mod N)+1
	 {Shuffle {Swipe N R List} N-1}
      end
   end

   fun{Append L1 L2}
      case L1 of H|T then
	 H|{Append T L2}
      [] nil then
	 L2
      end
   end

   fun{Retire P List}
      case List of H|T then
	 if(H.x == P.x) then
	    if(H.y == P.y) then
	       T
	    else
	       H|{Retire P T}
	    end
	 else
	    H|{Retire P T}
	 end
      [] nil then nil
      end
   end

   fun{CheckRange Etat X Y Xsup Ysup}
      fun{CheckLoop Etat X Y Xsup Ysup N}
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
	       Map = Etat.map
	       case {List.nth {List.nth Map Y+Ysup} X+Xsup} of 1 then
		  nil %% WALL
	       [] 2 then nil %% BOX WITH POINT
	       [] 3 then nil %% BOX WITH BONUS
	       [] 4 then pt(x:XFin y:YFin)|{CheckLoop Etat XFin YFin Xsup Ysup N-1} %% SPAWN
	       [] 0 then pt(x:XFin y:YFin)|{CheckLoop Etat XFin YFin Xsup Ysup N-1} %% SOL
	       end
	    end
	 end
      end
   in
      {CheckLoop Etat X Y Xsup Ysup Input.fire}
   end

   fun{Check P List}
      case List of H|T then
	 if(H.x == P.x) then
	    if(H.y == P.y) then
	       true
	    else
	       {Check P T}
	    end
	 else
	    {Check P T}
	 end
      else
	 false
      end
   end

   fun{CheckBox Etat Pos Xsup Ysup N} Map XFin YFin in
      Map = Etat.map
      if(N==0) then false
      else
	 XFin=Pos.x+Xsup
	 YFin=Pos.y+Ysup
	 if(XFin>Input.nbColumn orelse XFin=<0 orelse YFin>Input.nbRow orelse YFin=<0) then false
	 else
	    case {List.nth {List.nth Map YFin} XFin} of 1 then
	       false
	    [] 2 then true
	    [] 3 then true
	    [] 4 then {CheckBox Etat pt(x:XFin y:YFin) Xsup Ysup N-1}
	    [] 0 then {CheckBox Etat pt(x:XFin y:YFin) Xsup Ysup N-1}
	    end
	 end
      end
   end

   fun{GoingToDestroy Etat Pos} Bool1 Bool2 Bool3 Bool4 in
      Bool1={CheckBox Etat Pos 1 0 Input.fire}
      Bool2={CheckBox Etat Pos ~1 0 Input.fire}
      Bool3={CheckBox Etat Pos 0 1 Input.fire}
      Bool4={CheckBox Etat Pos 0 ~1 Input.fire}
      if(Bool1 orelse Bool2 orelse Bool3 orelse Bool4) then true
      else
	 false
      end
   end

   fun{CanIMove Etat Pos Range} NewPos1 NewPos2 NewPos3 NewPos4 List NewList in
      NewPos1={Move Etat Pos Range ~1 0}
      NewPos2={Move Etat Pos Range 1 0}
      NewPos3={Move Etat Pos Range 0 ~1}
      NewPos4={Move Etat Pos Range 0 1}
      List = NewPos1|NewPos2|NewPos3|NewPos4|nil
      NewList={Shuffle List {Length List 0}}
      if(NewList.1==0) then
	 if(NewList.2.1==0) then
	    if(NewList.2.2.1==0) then
	       if(NewList.2.2.2.1==0) then
		  nil
	       else
		  NewList.2.2.2.1
	       end
	    else
	       NewList.2.2.1
	    end
	 else
	    NewList.2.1
	 end
      else
	 NewList.1
      end
   end

   fun{Move Etat Pos Range Xsup Ysup}
      local X Y Map NewPos in
	 Map=Etat.map
	 X=Pos.x
	 Y=Pos.y
	 NewPos=pt(x:X+Xsup y:Y+Ysup)
	 if(Input.nbRow < NewPos.y orelse Input.nbColumn < NewPos.x  orelse NewPos.x=<0 orelse NewPos.y =<0) then
	    0
	 else
	    if({List.nth {List.nth Map NewPos.y} NewPos.x}==0 orelse {List.nth {List.nth Map NewPos.y} NewPos.x}==4) then
	       if({Check NewPos Range}==false) then
		  NewPos
	       else
		  0
	       end
	    else
	       0
	    end
	 end
      end
   end

   fun{Menace Etat Pos} Range2 in
      Range2 = {Range Etat Etat.posBomb}
      {Check Pos Range2}
   end

   fun{Extend Etat Pos Xsup Ysup Range N} Map XFin YFin in
      Map = Etat.map
      case Xsup#Ysup of (H1|T1)#(H2|T2) then
	 XFin=Pos.x+N*H1
	 YFin=Pos.y+N*H2
	 if(Input.nbRow < YFin orelse Input.nbColumn < XFin orelse XFin=<0 orelse YFin =<0) then
	    {Extend Etat Pos T1 T2 Range N}
	 else
	    if({List.nth {List.nth Map YFin} XFin} == 0 orelse {List.nth {List.nth Map YFin} XFin} == 4) then
	       if({CanIMove Etat pt(x:XFin y:YFin) Range}==nil) then
		  {Extend Etat Pos T1 T2 Range N}
	       else
		  if({List.nth {List.nth Map Pos.y+H2} Pos.x+H1} == 0 orelse {List.nth {List.nth Map Pos.y+H2} Pos.x+H1} == 4) then
		     pt(x:Pos.x+H1 y:Pos.y+H2)
		  else
		     {Extend Etat Pos T1 T2 Range N}
		  end
	       end
	    else
	       {Extend Etat Pos T1 T2 Range N}
	    end
	 end
      [] nil#nil then
	 nil
      end
   end

   fun{SafePoint Etat Pos Range} Xsup Ysup Pos0 Pos1 Pos2 in
      Xsup=[1 ~1 0 0]
      Ysup=[0 0 1 ~1]
      Pos0={CanIMove Etat Pos Range}
      Pos1={Extend Etat Pos Xsup Ysup Range 1}
      Pos2={Extend Etat Pos Xsup Ysup Range 2}
      if(Pos0==nil) then
	 if(Pos1==nil) then
	    if(Pos2==nil) then
	       nil
	    else
	       Pos2
	    end
	 else
	    Pos1
	 end
      else
	 Pos0
      end
   end

   fun{CanIEscape Etat Pos} Range2 NewPoints NewRange Res in
      Range2 = {Range Etat Etat.posBomb}
      NewPoints = {Append {Append {Append {Append {CheckRange Etat Pos.x Pos.y 0 1} {CheckRange Etat Pos.x Pos.y 0 ~1}} {CheckRange Etat Pos.x Pos.y 1 0}} {CheckRange Etat Pos.x Pos.y ~1 0}} [pt(x:Pos.x y:Pos.y)]}
      NewRange = {Append NewPoints Range2}
      {Print 'LA TAILLE DE MA RANGE EST : '#{List.length NewRange}#''}
      Res={SafePoint Etat Pos NewRange}
      if(Res==nil) then
	 false
      else
	 true
      end
   end

   fun{Range Etat BombList}
      case BombList of H|T then
	 {Append {Append {Append {Append {Append {CheckRange Etat H.x H.y 0 1} {CheckRange Etat H.x H.y 0 ~1}} {CheckRange Etat H.x H.y 1 0}} {CheckRange Etat H.x H.y ~1 0}} [pt(x:H.x y:H.y)]} {Range Etat T}}
      [] nil then nil
      end
   end

   fun{Bomb Etat Pos}
      {Record.adjoin Etat etat(bomb:Etat.bomb-1)}
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

   fun{Doaction Etat ID Action} NewEtat PosMenace PosMenace Pos NewPos Range2 in
      if(Etat.state==off) then
	       NewEtat = {Record.adjoin Etat etat(action:nil bomber:nil)}
	       ID=NewEtat.bomber
	       Action=NewEtat.action
	       NewEtat
      else
	       ID = Etat.bomber
	       {Print 'JE RECOMMENCE UNE NOUVELLE BOUCLE : '#ID.id#''}
	       PosMenace = {Menace Etat Etat.pos}
	       if(PosMenace==false) then % Je ne suis pas menacé
	           {Print 'JE NE SUIS PAS MENACE'}
	            if(Etat.bomb>0) then % J'ai encore des bombes en reserve
	               {Print 'J AI ENCORE UNE BOMBE EN RESERVE'}
	               if({CanIEscape Etat Etat.pos}) then % Je regarde si en posant une bombe, je peux m'echapper
		                {Print 'JE PEUX M ECHAPPER EN POSANT UNE BOMBE'}
		                if({GoingToDestroy Etat Etat.pos}) then % Je regarde si ma bombe va etre utile
		                    NewEtat={Bomb Etat Etat.pos}
		                    Pos=NewEtat.pos
		                    Action=bomb(Pos)
		                    NewEtat
		                else % Ma bombe n'est pas utile, je tente donc un mouvement
		                    NewPos = {CanIMove Etat Etat.pos {Range Etat Etat.posBomb}}
		                    if(NewPos==nil) then % Je ne peux pas faire de mouvement sans m'exposer a une menace
			                      {Print 'JE NE PEUX PAS FAIRE DE MOUVEMENT SANS M EXPOSER '}
			                      Pos=Etat.pos
			                      Action=move(Pos)
			                      Etat
		                    else % Je peux bouger sans m'exposer
			                      {Print 'JE PEUX BOUGER SANS M EXPOSER'}
			                      NewEtat={Record.adjoin Etat etat(pos:NewPos)}
			                      Pos=NewEtat.pos
			                      Action=move(Pos)
			                      NewEtat
		                    end
		                end
	               else % Je ne peux pas m'echapper si je pose une bombe, je tente alors de faire un mouvement
		                {Print 'JE NE PEUX PAS M ECHAPPER EN POSANT UNE BOMBE'}
		                NewPos = {CanIMove Etat Etat.pos {Range Etat Etat.posBomb}}
		                if(NewPos==nil) then % Je ne peux pas faire de mouvement sans m'exposer a une menace
		                    {Print 'JE NE PEUX PAS FAIRE DE MOUVEMENT SANS M EXPOSER '}
		                    Pos=Etat.pos
		                    Action=move(Pos)
		                    Etat
		                else % Je peux bouger sans m'exposer
		                    {Print 'JE PEUX BOUGER SANS M EXPOSER'}
		                    NewEtat={Record.adjoin Etat etat(pos:NewPos)}
		                    Pos=NewEtat.pos
		                    Action=move(Pos)
		                    NewEtat
		                end
	               end
	            else % Je n'ai pas de bombe, je tente alors de faire un mouvement
	               {Print 'JE N AI PLUS DE BOMBES EN RESERVE'}
	               NewPos = {CanIMove Etat Etat.pos {Range Etat Etat.posBomb}}
	               if(NewPos==nil) then % Je ne peux pas faire de mouvement sans m'exposer a une menace
		                {Print 'JE NE PEUX PAS FAIRE DE MOUVEMENT SANS M EXPOSER '}
		                Pos=Etat.pos
		                Action=move(Pos)
		                Etat
	               else % Je peux bouger sans m'exposer
		                {Print 'JE PEUX BOUGER SANS M EXPOSER'}
		                NewEtat={Record.adjoin Etat etat(pos:NewPos)}
		                Pos=NewEtat.pos
		                Action=move(Pos)
		                NewEtat
	               end
	            end
	       else % Je suis mencacé
	            {Print 'JE SUIS MENACE'}
	            Range2 = {Range Etat Etat.posBomb}
	            NewPos={SafePoint Etat Etat.pos Range2}
	            NewEtat={Record.adjoin Etat etat(pos:NewPos)}
	            Pos=NewEtat.pos
	            Action=move(Pos)
	            NewEtat
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
	    if(NewLife==0) then
	       NewEtat={Record.adjoin Etat etat(life:NewLife state:off)}
	    else
	       NewEtat={Record.adjoin Etat etat(life:NewLife)}
	    end
	    Res=death(NewLife)
	    NewEtat
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
      then
	 {Record.adjoin Etat etat(posBomb:Pos|Etat.posBomb)}
      [] bombExploded(Pos)%% Bomb has exploded at <position> Pos
      then
	 local NewBombList in
	    NewBombList = {Retire Pos Etat.posBomb}
	    {Record.adjoin Etat etat(posBomb:NewBombList)}
	 end
      [] boxRemoved(Pos)
      then
	 local NewMap PosX PosY in
	    PosX=Pos.x
	    PosY=Pos.y
	    NewMap = {Replace Etat.map {Replace {List.nth Etat.map Pos.y} 0 PosX 1} PosY 1} %%Change la map interne du joueur
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
