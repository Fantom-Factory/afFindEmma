
class TestPlayGame : Test, Commander {
	
	override Game?		game
	override Player?	player
	override Syntax?	syntax

	Void testRunThrough() {		
		log("START\n-----\n\n")
		startGame
		cheat.splitLines.each { log(it.trim.upper); executeCmd(it) }

"
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
 		
 ".splitLines.each { log(it.trim.upper); executeCmd(it) }
		
//		 executeCmd("eat snack")
		
		log("---\nEND\n\n")
	}
	
	override Void log(Obj? obj) {
		des := obj as Describe ?: Describe(obj?.toStr)
		des?.with { Env.cur.out.print("\n" + des.describe) }
	}
}
