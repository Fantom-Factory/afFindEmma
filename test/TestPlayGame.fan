
class TestPlayGame : Test {
	
	Game?	game
	Player?	player
	Syntax?	syntax

	Void testRunThrough() {
		game	= Game.load
		player	= game.player
		syntax	= Syntax()
		
		log("\nSTART\n-----\n\n")
		log(game.start)
		
"
 		LOOK 
 		LOOK OUT
 		LOOK PHOTO 		
 		MOVE OUT
 		
 		LOOK LEAD
 		PICKUP LEAD
 		
 		LOOK SOUTH
 		MOVE SOUTH
 		LOOK WEST
 		MOVE WEST
 		
 		LOOK DOOR
 		USE LEAD ON DOOR
 		
 		LOOK WEST
 		MOVE WEST
 		
 		LOOK SOUTH
 		MOVE SOUTH
 		USE LEAD ON DOOR
 		LOOK
 		
 		LOOK SOUTH
 		MOVE SOUTH
 		
 ".splitLines.each { executeCmd(it) }
		
		log("\n---\nEND\n\n")
	}
	
	Void executeCmd(Str cmdStr) {
		cmdStr = cmdStr.trim
		if (cmdStr.startsWith("//") || cmdStr.trim.isEmpty) return
		log("\n> ${cmdStr}\n")
	
		cmd := syntax.compile(player, cmdStr)
		old := player.room
		des := cmd?.execute(player)
		if (des != null) {
			log("\n")
			log(des)
		}
	
		if (cmd == null)
			log("\nI do not understand.")
	
		if (player.room != old) {
			log(divider)
			log(player.look)
		}
	}
	
	Str divider() {
		"\n----\n\n"
	}
	
	Void log(Obj? obj) {
		des := obj as Describe ?: Describe(obj?.toStr)
		des?.with { Env.cur.out.print(des.describe) }
	}
}
