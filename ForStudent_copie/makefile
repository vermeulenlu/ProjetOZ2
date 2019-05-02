# ----------------------------
# group nb 33
# 5287 1500 : Bogaert Jeremie
# 4978 1600 : Vermeulen Lucas
# ----------------------------

# TODO complete the header with your group number, your noma's and full names

all:	Input.ozf compile run
	ozc.exe -c Input.oz

compile:	compilePlayer PlayerManager.oz GUI.oz GameState.oz Main.oz
	ozc.exe -c PlayerManager.oz GUI.oz GameState.oz Main.oz

Input.ozf: Input.oz
	ozc.exe -c Input.oz

compilePlayer:	Player000name.oz Player033AI.oz Player033DP.oz
	ozc.exe -c Player000name.oz Player033AI.oz Player033DP.oz

*.ozf :

run:	Main.ozf
	ozengine.exe Main.ozf

clean :
	rm Input.ozf PlayerManager.ozf GUI.ozf GameState.ozf Player033AI.ozf Player033name.ozf

# TODO write your makefile here
