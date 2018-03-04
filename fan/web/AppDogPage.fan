using dom
using graphics

@Js class AppDogPage : Commander, DomBob {
	override Game?		game
	override Player?	player
	override Syntax?	syntax
			 Elem?		screen
			 Elem?		prompt
			 CmdHistory	history	:= CmdHistory()

	Str logo := "
	                  _____^__
	                  |    |    \\
	                   \\   /  ^ |           ________)              _____)
	                  / \\_/   0  \\         (, /     ,       /)   /
	                 /            \\          /___,   __   _(/    )__   ___  ___   _  
	                /    ____      0      ) /     _(_/ (_(_(_  /       // (_// (_(_(_
	               /      /  \\___ _/     (_/                  (_____)
	                                                                           v${typeof.pod.version}
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
										history.add(prompt->value)
										win.setTimeout(10ms) { prompt->value = "" }
							    	}
							    	if (e.key == Key.esc) {
										history.reset
										win.setTimeout(10ms) { prompt->value = "" }
							    	}
							    	if (e.key == Key.up)
										win.setTimeout(10ms) { prompt->value = history.up }
							    	if (e.key == Key.down)
										win.setTimeout(10ms) { prompt->value = history.down }
								}
							},
						},
					},
				},
			}
		)
	
		prompt.focus
		
		startGame
		scrollScreen
	}
	
	Void exeCmd(Str cmdStr) {
		switch (cmdStr) {
			case "help":
				log("\n> ${cmdStr.upper}\n", "usrCmd")
				log(help)
			
			case "more help":
			case "help more":
				log("\n> ${cmdStr.upper}\n", "usrCmd")
				log(helpMore)

			case "cls":
			case "clear":
				screen.removeAll

			case "logo":
				screen.add(div("logo", logo))

			case "history":
				log("\n> ${cmdStr.upper}\n", "usrCmd")
				log("\n")
				history.history.eachr { log("> $it") }
		
			case "cheat":
				cheat
				screen.scrollPos = Point(0f, screen.scrollSize.h - screen.size.h)

			default:
				executeCmd(cmdStr)
		}
		scrollScreen		
	}
	
	override Void log(Obj? obj, Str klass := "") {
		des := obj as Describe ?: Describe(obj?.toStr)
		screen.add(div(klass, des.describe))
	}
	
	Void scrollScreen() {
		if ((screen.size.h + screen.scrollPos.y) < screen.scrollSize.h) {
			screen.scrollPos = Point(0f, screen.scrollPos.y + 16f)
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
		str.add("  - history\n")
		str.add("\n")
		str.add("Now go find Emma.\n")
		return Describe(str)
	}
}
