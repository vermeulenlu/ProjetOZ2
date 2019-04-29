functor
import
   Player000bomber
   Player000name
   Player000AI
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind ID}
      case Kind
      of player000bomber then {Player000bomber.portPlayer ID}
      [] player000name then {Player000name.portPlayer ID}
      [] player000AI then {Player000AI.portPlayer ID}
      else
         raise
            unknownedPlayer('Player not recognized by the PlayerManager '#Kind)
         end
      end
   end
end
