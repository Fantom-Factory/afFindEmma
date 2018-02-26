
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
 		
 		MOVE
 		MOVE OUT
 		
 		LOOK LEAD
 		PICKUP LEAD
 		
 		LOOK SOUTH
 		MOVE SOUTH
 		LOOK EAST
 		MOVE EAST
 		
 		LOOK DOOR
 		USE
 		USE 
 		USE LEAD
 		USE LEAD 
 		USE LEAD ON
 		USE LEAD ON 
 		USE LEAD ON DOOR
 
 		throw
 		throw 
 		throw short LEAD
 		throw short LEAD 
 		throw short LEAD at
 		throw short LEAD at 
 		throw short LEAD at DOOR
 		
 		DROP LEAD
 		TAKE DOOR
 		
 		LOOK EAST
 		MOVE EAST
 		
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
