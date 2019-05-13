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
   guiOpt:GUIOpt
define
   Mode
   IsTurnByTurn UseExtention PrintOK GUIOpt
   NbRow NbColumn Map
   NbBombers Bombers ColorBombers
   NbLives NbBombs
   ThinkMin ThinkMax
   TimingBomb TimingBombMin TimingBombMax Fire
in

  Mode = 6   %%Mode à utiliser


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (Mode == 1) then

     IsTurnByTurn = true
     UseExtention = false
     GUIOpt = false
     PrintOK = false


  %%%% Description of the map %%%%

     NbRow = 7
     NbColumn = 7
     Map = [[1 1 1 1 1 1 1]
      [1 4 0 3 0 4 1]
      [1 0 1 3 1 0 1]
      [1 2 2 2 3 2 1]
      [1 0 1 2 1 0 1]
      [1 4 0 3 0 4 1]
      [1 1 1 1 1 1 1]]


  %%%% Players description %%%%

     NbBombers = 2
     Bombers = [player033DP player033name]
     ColorBombers = [red green] %%green = luigi, red = mario, blue = toad et c(255 128 192) = peach

  %%%% Parameters %%%%

     NbLives = 3
     NbBombs = 1

     ThinkMin = 400  % in millisecond
     ThinkMax = 600 % in millisecond

     Fire = 2
     TimingBomb = 3
     TimingBombMin = 2000 % in millisecond
     TimingBombMax = 3000 % in millisecond

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  elseif (Mode ==2) then

  IsTurnByTurn = false
  UseExtention = false
  GUIOpt = false
  PrintOK = false


%%%% Description of the map %%%%

  NbRow = 7
  NbColumn = 7
  Map = [[1 1 1 1 1 1 1]
   [1 4 0 3 0 4 1]
   [1 0 1 3 1 0 1]
   [1 2 2 2 3 2 1]
   [1 0 1 2 1 0 1]
   [1 4 0 3 0 4 1]
   [1 1 1 1 1 1 1]]


%%%% Players description %%%%

  NbBombers = 2
  Bombers = [player033DP player033name]
  ColorBombers = [red green] %%green = luigi, red = mario, blue = toad et c(255 128 192) = peach

%%%% Parameters %%%%

  NbLives = 3
  NbBombs = 1

  ThinkMin = 400  % in millisecond
  ThinkMax = 600 % in millisecond

  Fire = 2
  TimingBomb = 3
  TimingBombMin = 2000 % in millisecond
  TimingBombMax = 3000 % in millisecond


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  elseif (Mode ==3) then
  IsTurnByTurn = true
  UseExtention = false
  GUIOpt = false
  PrintOK = false


%%%% Description of the map %%%%

  NbRow = 15
  NbColumn = 15
  Map = [[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
   [1 4 0 3 1 0 0 3 2 1 2 0 0 4 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 2 2 2 3 0 1 1 0 2 2 3 0 2 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 2 2 2 3 0 1 1 0 2 2 3 0 2 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 4 0 3 3 0 2 2 3 1 0 2 0 4 1]
   [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]]


%%%% Players description %%%%

  NbBombers = 5
  Bombers = [player033DP player033DP player033name player033name player033name]
  ColorBombers = [red green c(255 128 192) blue yellow] %%green = luigi, red = mario, blue = toad, yellow = wario et c(255 128 192) = peach

%%%% Parameters %%%%

  NbLives = 3
  NbBombs = 1

  ThinkMin = 400  % in millisecond
  ThinkMax = 600 % in millisecond

  Fire = 2
  TimingBomb = 3
  TimingBombMin = 2000 % in millisecond
  TimingBombMax = 3000 % in millisecond


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  elseif (Mode==4) then

  IsTurnByTurn = false
  UseExtention = false
  GUIOpt = false
  PrintOK = false


%%%% Description of the map %%%%

  NbRow = 15
  NbColumn = 15
  Map = [[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
   [1 4 0 3 1 0 0 3 2 1 2 0 0 4 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 2 2 2 3 0 1 1 0 2 2 3 0 2 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 1 2 0 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 2 2 2 3 0 1 1 0 2 2 3 0 2 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 4 0 3 3 0 2 2 3 1 0 2 0 4 1]
   [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]]


%%%% Players description %%%%

  NbBombers = 5
  Bombers = [player033DP player033DP player033name player033name player033name]
  ColorBombers = [red green c(255 128 192) blue yellow] %%green = luigi, red = mario, blue = toad, yellow = wario et c(255 128 192) = peach

%%%% Parameters %%%%

  NbLives = 3
  NbBombs = 1

  ThinkMin = 400  % in millisecond
  ThinkMax = 600 % in millisecond

  Fire = 2
  TimingBomb = 3
  TimingBombMin = 2000 % in millisecond
  TimingBombMax = 3000 % in millisecond
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  elseif (Mode ==5) then

  IsTurnByTurn = true
  UseExtention = false
  GUIOpt = false
  PrintOK = false


%%%% Description of the map %%%%

  NbRow = 15
  NbColumn = 15
  Map = [[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
   [1 4 0 3 1 0 0 3 2 1 2 0 0 4 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 2 2 2 3 0 1 1 0 2 2 3 0 2 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 1 2 0 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 2 2 2 3 0 1 1 0 2 2 3 0 2 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 4 0 3 3 0 2 2 3 1 0 2 0 4 1]
   [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]]


%%%% Players description %%%%

  NbBombers = 10
  Bombers = [player033DP player033DP player033AI player033AI player105Cerbere player105Cerbere playerSmart02 playerSmart02 player033name player033name]
  ColorBombers = [red red green green c(255 128 192) c(255 128 192) blue blue yellow yellow] %%green = luigi, red = mario, blue = toad, yellow = wario et c(255 128 192) = peach

%%%% Parameters %%%%

  NbLives = 3
  NbBombs = 1

  ThinkMin = 400  % in millisecond
  ThinkMax = 600 % in millisecond

  Fire = 2
  TimingBomb = 3
  TimingBombMin = 2000 % in millisecond
  TimingBombMax = 3000 % in millisecond
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  elseif (Mode==6) then
  IsTurnByTurn = false
  UseExtention = true
  GUIOpt = true
  PrintOK = false


%%%% Description of the map %%%%

  NbRow = 15
  NbColumn = 15
  Map = [[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
   [1 4 0 3 1 0 0 3 2 1 2 0 0 4 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 2 2 2 3 0 1 1 0 2 2 3 0 2 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 1 2 0 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 2 2 2 3 0 1 1 0 2 2 3 0 2 1]
   [1 1 2 1 0 3 1 1 1 3 0 2 1 0 1]
   [1 0 1 3 1 0 2 1 3 2 1 2 3 0 1]
   [1 4 0 3 3 0 2 2 3 1 0 2 0 4 1]
   [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]]


%%%% Players description %%%%

  NbBombers = 5
  Bombers = [player033DP player033AI player105Cerbere playerSmart02 player033name]
  ColorBombers = [red green c(255 128 192) blue yellow] %%green = luigi, red = mario, blue = toad, yellow = wario et c(255 128 192) = peach

%%%% Parameters %%%%

  NbLives = 3
  NbBombs = 1

  ThinkMin = 400  % in millisecond
  ThinkMax = 600 % in millisecond

  Fire = 2
  TimingBomb = 3
  TimingBombMin = 2000 % in millisecond
  TimingBombMax = 3000 % in millisecond
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  else
     raise
        unknownedMode('This number of mode does not exist '#Mode)
     end
  end
end
