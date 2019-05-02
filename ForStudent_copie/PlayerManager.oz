functor
import
   Player000bomber
   Player000name
   Player033AI
   Player105Cerbere
   Player033DP
   Player001name 
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind ID}
      case Kind
      of player000bomber then {Player000bomber.portPlayer ID}
      [] player000name then {Player000name.portPlayer ID}
      [] player033AI then {Player033AI.portPlayer ID}
      [] player001name then {Player001name.portPlayer ID}
      [] player033DP then {Player033DP.portPlayer ID}
      else
         raise
            unknownedPlayer('Player not recognized by the PlayerManager '#Kind)
         end
      end
   end
end
