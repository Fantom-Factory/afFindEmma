
class TestPlayGame : Test, Commander {
	
	override Game?		game
	override Player?	player
	override Syntax?	syntax

	Void testRunThrough() {		
		log("\nSTART\n-----\n\n")
		startGame
		
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
	
	override Void log(Obj? obj, Str klass := "") {
		des := obj as Describe ?: Describe(obj?.toStr)
		des?.with { Env.cur.out.print(des.describe) }
	}
}
