
class TestPlayGame : Test {
	
	Game?	game
	Player?	player

	Void testRunThrough() {
		game	= Game.load
		player	= game.player
		
		log("\nSTART\n")
		log(divider)
		
		look

		move("out")

		log(divider)
		log("END\n\n")
	}
	
	
	Void look() {
		log(player.look)		
	}
	
	Void move(Str exitName) {
		exitId := player.room.exits.find { it.type == ExitType.vals.find { it.name == exitName  } }.id
		log("\n> $exitId.path.last.upper\n\n")
		log(player.move(exitId))
		log(divider)
		look
	}
	
	Str divider() {
		"\n----\n\n"
	}
	
	Void log(Obj? obj) {
		des := obj as Describe ?: Describe(obj?.toStr)
		des?.with { Env.cur.out.print(des.describe) }
	}
}
