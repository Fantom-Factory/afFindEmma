
@Js mixin Commander {
	abstract Game?		game
	abstract Player?	player
	abstract Syntax?	syntax

	Void executeCmd(Str cmdStr) {
		cmdStr = cmdStr.trim
		if (cmdStr.startsWith("//") || cmdStr.trim.isEmpty) return
		log("\n> ${cmdStr.upper}\n", "usrCmd")
	
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
		} else {
			// if we tried to move but were blocked, restate which room we're in
			if (cmd?.method == Player#move) {
				log("\n")
				log(player.room.lookName)				
			}
			
			// if we didn't move but an object has (dis)appeared, then list it
			if (player.room.objects != obj && player.room.objects.size > 0) {
				log("\n")
				log(player.room.lookObjects)
			}
		}
	}
	
	Void startGame() {
		game	= Game.load
		player	= game.player
		syntax	= Syntax()
		log(game.start)
	}
	
	Void cheat() {
"
 		move out
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
 		open oven
 		eat cake
 		use lead on door
 		west
 		west
 		open washing machine
 		wear coat
 		
 ".splitLines.each { executeCmd(it) }
	}
	
	abstract Void log(Obj? obj, Str klass := "")
}
