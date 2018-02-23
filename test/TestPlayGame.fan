
class TestPlayGame : Test {
	
	Game?	game
	Player?	player

	Void testRunThrough() {
		game	= Game.load
		player	= game.player
		
		log("\nSTART\n-----\n\n")
		log(game.start)
		
		look("out")
		look("photo")
		
		move("out")
		
		move("east")
		move("west")

		log(divider)
		log("END\n\n")
	}
	
	
	Void look(Str? obj := null) {
		log("\n> LOOK ${obj?.upper ?: Str.defVal}\n\n")
		log(player.look(obj))
	}
	
	Void move(Str exit) {
		oldRoom := player.room
		log("\n> MOVE ${exit.upper}\n\n")
		log(player.move(exit))
		
		if (player.room != oldRoom) {
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
