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


%%%% Style of game %%%%

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

   NbBombers = 2
   Bombers = [player000name player000name]
   ColorBombers = [yellow red]

%%%% Parameters %%%%

   NbLives = 10
   NbBombs = 1

   ThinkMin = 400  % in millisecond
   ThinkMax = 600 % in millisecond

   Fire = 2
   TimingBomb = 3
   TimingBombMin = 5000 % in millisecond
   TimingBombMax = 6000 % in millisecond

end