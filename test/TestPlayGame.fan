
class TestPlayGame : Test, Commander {
	
	override Game?		game
	override Player?	player
	override Syntax?	syntax

	Void testRunThrough() {		
		log("\nSTART\n-----\n\n")
		startGame
		cheat
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
 		
 ".splitLines.each { executeCmd(it) }
		
//		 executeCmd("eat snack")
		
		log("\n---\nEND\n\n")
	}
	
	override Void log(Obj? obj, Str klass := "") {
		des := obj as Describe ?: Describe(obj?.toStr)
		des?.with { Env.cur.out.print(des.describe) }
	}
}
