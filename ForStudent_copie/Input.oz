functor
export
   isTurnByTurn:IsTurnByTurn
   useExtention:UseExtention
   printOK:PrintOK
   nbRow:NbRow
   nbColumn:NbColumn
   map:Map
   nbBombers:NbBombers
   bombers:Bombers
   colorsBombers:ColorBombers
   nbLives:NbLives
   nbBombs:NbBombs
   thinkMin:ThinkMin
   thinkMax:ThinkMax
   fire:Fire
   timingBomb:TimingBomb
   timingBombMin:TimingBombMin
   timingBombMax:TimingBombMax
define
   IsTurnByTurn UseExtention PrintOK
   NbRow NbColumn Map
   NbBombers Bombers ColorBombers
   NbLives NbBombs
   ThinkMin ThinkMax
   TimingBomb TimingBombMin TimingBombMax Fire
in


   IsTurnByTurn = true
   UseExtention = false
   PrintOK = true


%%%% Description of the map %%%%

   NbRow = 7
   NbColumn = 13
   Map = [[1 1 1 1 1 1 1 1 1 1 1 1 1]
	  [1 4 0 3 3 3 3 3 3 3 0 4 1]
	  [1 0 1 3 1 2 1 2 1 2 1 0 1]
	  [1 2 2 2 3 2 2 2 2 3 2 2 1]
	  [1 0 1 2 1 2 1 3 1 2 1 0 1]
	  [1 4 0 3 3 3 3 3 3 3 0 4 1]
	  [1 1 1 1 1 1 1 1 1 1 1 1 1]]

%%%% Players description %%%%

   NbBombers = 4
   Bombers = [player033DP player033AI player000name player000bomber]
   ColorBombers = [red green white yellow] %%green = luigi, red = mario, blue = toad et c(255 128 192) = peach

%%%% Parameters %%%%

   NbLives = 3
   NbBombs = 1

   ThinkMin = 400  % in millisecond
   ThinkMax = 600 % in millisecond

   Fire = 2
   TimingBomb = 3
   TimingBombMin = 2000 % in millisecond
   TimingBombMax = 3000 % in millisecond

end
