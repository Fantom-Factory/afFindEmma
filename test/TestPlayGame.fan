
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
 		look photo
 		move out
 		
 		use box
 		look in box
 		
 		pickup lead
 		north
 		use lead on door
 		west
 		use lead on door
 		
 		rollover
 		eat snack
 		hi5 postman
 		rip open parcel
 		wear boots
 		
 		east
 		south
 		west
 		use lead on door
 		stats
 		open oven
 		eat cake
 		west
 		west
 		
 		drop lead
 		use nuts
 		eat nuts
 		use bird seed
 		eat seed
 		use bird seed
 		eat seed
 		use bird seed
 		eat seed
 		use bird seed
 		eat seed
 		
 ".splitLines.each { executeCmd(it) }
		
//		 executeCmd("eat snack")
		
		log("\n---\nEND\n\n")
	}
	
	Void executeCmd(Str cmdStr) {
		cmdStr = cmdStr.trim
		if (cmdStr.startsWith("//") || cmdStr.trim.isEmpty) return
		log("\n> ${cmdStr.upper}\n")
	
		cmd := syntax.compile(player, cmdStr)
		old := player.room
		obj := player.room.objects.dup
		des := cmd?.execute(player)
		if (des != null) {
			log("\n")
			log(des)
		}
	
		if (cmd == null)
			log("\nI do not understand.")
	
		if (player.room != old) {
			log("\n")
			log(player.look)
		} else
		if (player.room.objects != obj) {
			log("\n")
			log(player.room.lookObjects)			
		}
	}
	
	Void log(Obj? obj) {
		des := obj as Describe ?: Describe(obj?.toStr)
		des?.with { Env.cur.out.print(des.describe) }
	}
}
