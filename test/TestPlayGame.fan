
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

		look("lead")
		take("lead")

		look("north")
		move("north")
		look("west")
		move("west")
		look("door")
		
		use("lead", "door")
		
		drop("lead")
		take("door")
		
		look("west")
		move("west")
		
//		move("north")
//		move("west")
//		move("up")
//
//		move("east")
//		move("south")
//		move("west")

		log("\n---\nEND\n\n")
	}
	
	
	Void look(Str? obj := null) {
		log("\n> LOOK ${obj?.upper ?: Str.defVal}\n\n")
		log(player.look(obj?.lower))
	}
	
	Void move(Str exit) {
		oldRoom := player.room
		log("\n> MOVE ${exit.upper}\n")
		des := player.move(exit.lower)	// this should be applied to ALL cmds, as with Game default msgs, there is no guarentee that a Desc will be returned
		if (des != null) {
			log("\n")
			log(des)
		}
		
		if (player.room != oldRoom) {
			log(divider)
			log(player.look)
		}
	}
	
	Void take(Str obj) {
		log("\n> TAKE ${obj.upper}\n\n")
		log(player.pickUp(obj.lower))
	}
	
	Void drop(Str obj) {
		log("\n> DROP ${obj.upper}\n\n")
		log(player.drop(obj.lower))
	}
	
	Void use(Str obj, Str? receiver := null) {
		cmd := "USE ${obj.upper}"
		if (receiver != null)
			cmd += " ON ${receiver.upper}"
		log("\n> ${cmd}\n\n")
		log(player.use(obj.lower, receiver.lower))
	}
	
	Str divider() {
		"\n----\n\n"
	}
	
	Void log(Obj? obj) {
		des := obj as Describe ?: Describe(obj?.toStr)
		des?.with { Env.cur.out.print(des.describe) }
	}
}
