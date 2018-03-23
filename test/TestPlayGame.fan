
class TestPlayGame : Test, Commander {
	
	override Game?		game
	override Player?	player
	override Syntax?	syntax

//	Void testLook() {
//		startGame
//		executeCmd("out")
//		executeCmd("n")
//		executeCmd("l tv")
//	}

	Void testRunThrough() {
		log("START\n-----\n\n")
		startGame
		solution.splitLines.each { log(it.trim.upper); executeCmd(it) }		
		log("---\nEND\n\n")
	}
	
	override Void log(Obj? obj) {
		des := obj as Describe ?: Describe(obj?.toStr)
		des?.with { Env.cur.out.print("\n" + des.describe) }
	}
}
