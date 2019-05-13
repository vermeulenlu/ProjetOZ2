functor
import
   Player000bomber
   Player033name
   Player033AI
   Player105Cerbere
   Player033DP
   Player005Arrows
   Player082advancedPlayer
   Player100advanced
   PlayerSmart02
   Player021IA2
   Player001name
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind ID}
      case Kind
      of player000bomber then {Player000bomber.portPlayer ID}
      [] player033name then {Player033name.portPlayer ID}
      [] player033AI then {Player033AI.portPlayer ID}
      [] player001name then {Player001name.portPlayer ID}
      [] player033DP then {Player033DP.portPlayer ID}
      [] player005Arrows then {Player005Arrows.portPlayer ID}
      [] player082advancedPlayer then {Player082advancedPlayer.portPlayer ID}
      [] player100advanced then {Player100advanced.portPlayer ID}
      [] playerSmart02 then {PlayerSmart02.portPlayer ID}
      [] player021IA2 then {Player021IA2.portPlayer ID}
      [] player105Cerbere then {Player105Cerbere.portPlayer ID}
      else
         raise
            unknownedPlayer('Player not recognized by the PlayerManager '#Kind)
         end
      end
   end
end
