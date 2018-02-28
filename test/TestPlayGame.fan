
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
 		LOOK PHOTO 		
 		MOVE OUT
 		PICKUP LEAD
 		MOVE SOUTH
 		MOVE WEST
 		
 		LOOK DOOR
 		USE LEAD ON DOOR
 		MOVE WEST
 		
 		LOOK SOUTH
 		MOVE SOUTH
 		throw LEAD ON DOOR
 		LOOK
 		
 		LOOK SOUTH
 		MOVE SOUTH
 		drop lead
 		rollover
 		get snack
 		eat snack
 		stats
 		hi5 postman
 		look
 		use parcel
 		look
 		
 		wear boots
 		l n
 		move n
 		
 ".splitLines.each { executeCmd(it) }
		
//		 executeCmd("eat snack")
		
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
