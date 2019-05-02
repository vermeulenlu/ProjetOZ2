# ----------------------------
# group nb 33
# 5287 1500 : Bogaert Jeremie
# 4978 1600 : Vermeulen Lucas
# ----------------------------

# TODO complete the header with your group number, your noma's and full names

all:	Input.ozf compile run
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Input.oz

compile:	compilePlayer PlayerManager.oz GUI.oz GameState.oz Main.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c PlayerManager.oz GUI.oz GameState.oz Main.oz

Input.ozf: Input.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Input.oz

compilePlayer:	Player000name.oz Player033AI.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Player000name.oz Player033AI.oz

*.ozf :

run:	Main.ozf
	/Applications/Mozart2.app/Contents/Resources/bin/ozengine Main.ozf

clean :
	rm Input.ozf PlayerManager.ozf GUI.ozf GameState.ozf Player033AI.ozf Player033name.ozf

# TODO write your makefile here
