using dom
using graphics

@Js class AppDogPage : Commander, DomBob {
	override Game?		game
	override Player?	player
	override Syntax?	syntax
			 Elem?		screen
			 Elem?		prompt

	Str logo := "
	                  _____^__
	                  |    |    \\
	                   \\   /  ^ |           ________)              _____)
	                  / \\_/   0  \\         (, /     ,       /)   /
	                 /            \\          /___,   __   _(/    )__   ___  ___   _  
	                /    ____      0      ) /     _(_/ (_(_(_  /       // (_// (_(_(_
	               /      /  \\___ _/     (_/                  (_____)
	             \n\n\n"
	
	Void init() {
		doc.body.add(
			div("box") {
				div("terminal") {
					div("tvBg") {
						elem("img") {
							it.setAttr("src", "/images/tv.jpg")
						},
					},
					div("screen") {
						div("output") {
							screen = div("text") {
								it.onEvent("click", true) { prompt.focus }
								div("logo", logo),
							},
						},
						div("input") {
							prompt = elem("input", "usrCmd") {
								it.setAttr("type", "text")
								it.setAttr("autofocus", "")
							    it.onEvent("keydown", false) |e| {
							    	if (e.key == Key.enter) {
										exeCmd(prompt->value->trim->lower)
										prompt->value = ""
							    	}
								}
							},
						},
					},
				},
			}
		)
	
		prompt.focus
		
		startGame
	}
	
	Void exeCmd(Str cmdStr) {
		if (cmdStr == "help") {
			log("\n> ${cmdStr.upper}\n", "usrCmd")
			return log(help)
		}
		if (cmdStr == "help more" || cmdStr == "more help") {
			log("\n> ${cmdStr.upper}\n", "usrCmd")
			return log(helpMore)
		}
		if (cmdStr == "clear" || cmdStr == "cls") {
			screen.removeAll
			return
		}
		if (cmdStr == "logo") {
			screen.add(div("logo", logo))
			scrollScreen
			return
		}
		executeCmd(cmdStr)
	}
	
	override Void log(Obj? obj, Str klass := "") {
		des := obj as Describe ?: Describe(obj?.toStr)
		screen.add(div(klass, des.describe))
		scrollScreen
	}
	
	Void scrollScreen() {
		if ((screen.size.h + screen.scrollPos.y) < screen.scrollSize.h) {
			screen.scrollPos = Point(0f, screen.scrollPos.y + 4f)
			win.reqAnimationFrame { scrollScreen }
		}
	}
	
	Describe? help() {
		str := StrBuf()
		str.add("\n")
		str.add("Game commands:\n")
		str.add("  - look    [exit | item]\n")
		str.add("  - move    <exit>\n")
		str.add("  - pickup  <item>\n")
		str.add("  - drop    <item>\n")
		str.add("  - wear    <item>\n")
		str.add("  - takeoff <item>\n")
		str.add("  - use <item> [on <item>]\n")
		str.add("\n")
		str.add("Player commands:\n")
		str.add("  - rollover\n")
		str.add("  - hi5 <item>\n")
		str.add("\n")
		str.add("Misc commands:\n")
		str.add("  - statistics\n")
		str.add("  - inventory\n")
		str.add("\n")
		str.add("Misc commands:\n")
		str.add("  - statistics\n")
		str.add("  - inventory\n")
		str.add("\n")
		str.add("Type > MORE HELP\n")
		return Describe(str)
	}

	Describe? helpMore() {
		str := StrBuf()
		str.add("\n")
		str.add("Alternative synonyms, verbs, and abbreviations are allowed:\n")
		str.add("  - north\n")
		str.add("  - get snack\n")
		str.add("  - hi5 squirrel\n")
		str.add("  - stats\n")
		str.add("\n")
		str.add("You can use items in the room:\n")
		str.add("  - eat snack\n")
		str.add("\n")
		str.add("But you must pick it before you can action it on another item:\n")
		str.add("  - pickup snack\n")
		str.add("  - throw snack at door\n")
		str.add("\n")
		str.add("Terminal commands:\n")
		str.add("  - help\n")
		str.add("  - more help\n")
		str.add("  - cls\n")
		str.add("\n")
		str.add("Now go find Emma.\n")
		return Describe(str)
	}
}

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
		} else
		if (player.room.objects != obj && player.room.objects.size > 0) {
			log("\n")
			log(player.room.lookObjects)
		}
	}
	
	Void startGame() {
		game	= Game.load
		player	= game.player
		syntax	= Syntax()
		log(game.start)
	}
	
	abstract Void log(Obj? obj, Str klass := "")
}
