using dom
using graphics

@Js class AppQuestPage : Commander, DomBob {
	override Game?			game
	override Player?		player
	override Syntax?		syntax
			 Elem?			screen
			 Elem?			prompt
			 PromptHistory	promptHis	:= PromptHistory()
			 CmdHistory		cmdHis		:= CmdHistory()
			 Bool			silent		:= false

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
		echo("Find Emma v${typeof.pod.version} by Alien-Factory")
		box 	:= null as Elem
		cbox	:= null as CardBox
		doc.body.insertBefore(
			box = div("box") {
				div("topNav") {
					it.onEvent("click", false) |e| {
						href := e.target.get("href")
						if (href == null) return
						switch (href) {
							case "#game"		: cbox.selIndex = 0; prompt.focus
							case "#about"		: cbox.selIndex = 1
							case "#princess"	: cbox.selIndex = 2
							case "#hallOfFame"	: cbox.selIndex = 3
						}
						doc.querySelector(".topNav .active").style.removeClass("active")
						e.target.style.addClass("active")
						e.stop
					}
					elem("a", "active", "Game") 	{ it.setAttr("href", "#game") },
					elem("a", "", "About")			{ it.setAttr("href", "#about") },
					elem("a", "", "Princess")		{ it.setAttr("href", "#princess") },
					elem("a", "", "Hall of fame")	{ it.setAttr("href", "#hallOfFame") },
				},
				div("terminal") {
					div("minMax") {
						it.onEvent("click", false) |e| {
							box.style.toggleClass("maximise")
						}
						it->title = "Min/Max Terminal"
						div("sym"),
					},
					div("tvBg") {
						elem("img") {
							it.setAttr("src", "/images/tv.jpg")
						},
					},
					cbox = CardBox {
						it.style.addClass("screen")
						div("screen game") {
							div("output") {
								screen = div("text") {
									it.onEvent("click", true) {
										// let random clicks refocus the cmd box, but let users select text
										sel := Win.eval("window.getSelection().toString()")
										if (sel == "") prompt.focus
									}
									div("logo", logo),
								},
							},
							div("input") {
								prompt = elem("input", "usrCmd") {
									it.setAttr("type", "text")
									it.setAttr("autofocus", "")
								    it.onEvent("keydown", false) |e| {
								    	if (e.key == Key.enter) {
								    		promptHis.add(prompt->value)
											exeCmd(prompt->value)
											win.setTimeout(10ms) { prompt->value = "" }
								    	}
								    	if (e.key == Key.esc) {
											promptHis.reset
											win.setTimeout(10ms) { prompt->value = "" }
								    	}
								    	if (e.key == Key.up)
											win.setTimeout(10ms) { prompt->value = promptHis.up }
								    	if (e.key == Key.down)
											win.setTimeout(10ms) { prompt->value = promptHis.down }
									}
								},
							},								
						},
						div("screen about") {
							div("output") {
								elem("span", "", "\"Find Emma\" is a Birthday present for my wife, Emma.\n\n"),

								elem("span", "", "It is a retro text adventure game in the ilk of "),
								elem("a", "", "Zork") { it.setAttr("href", "https://en.wikipedia.org/wiki/Zork") },
								elem("span", "", " and "),
								elem("a", "", "Colossal Cave Adventure") { it.setAttr("href", "https://en.wikipedia.org/wiki/Colossal_Cave_Adventure") },
								elem("span", "", ".\n\n"),

								elem("span", "", "The main protagonist, Princess, is a little dog we're currently fostering until she finds her forever home. "),
								elem("span", "", "The game map, including the house and gardens, is a representation of our village home in the valleys of South Wales, UK.\n\n"),
								elem("span", "", "We do have an extraordinary amount of wildlife visiting our gardens, and Emma does spend an extraordinary amount of time feeding them all! "),
								elem("span", "", "So this game was an attempt to capture it all through the eyes of our newest house member.\n\n"),
								elem("span", "", "\n"),
								elem("span", "", "               -----------------------------------------\n"),
								elem("span", "", "           --=% H A P P Y   B I R T H D A Y   E M M A ! %=--\n"),
								elem("span", "", "               -----------------------------------------\n"),
								elem("span", "", "\n"),
								elem("span", "", "Steve.\n"),
								elem("span", "", "\n"),
								elem("span", "", "23rd March 2018.\n"),
							},
						},
						div("screen princess") {
							div("output") {
								elem("span", "", "Princess is little 2 year old Staffordshire Bull Terrier who was picked up as a stray when just a puppy and handed over to the Dogs Trust charity. She's since spend her entire life in kennels and has never had a home.\n\n"),
								elem("span", "", "Emma and I (well, mainly Emma!) are fostering Princess until she can find her forever home. That is, we've welcomed her into our home on a temporary basis.\n\n"),
								elem("span", "", "Unfortunately Princess has wonky back legs due to a suspected spinal abnormality, which means she scuffs her back feet and wears her toes down until they bleed. It sounds bad, but on the plus side, it's nothing that dog booties and a bit of love and attention can't fix!\n\n"),
								elem("span", "", "Princess is more Bull Dozer than Bull Terrier, but she's a perfect pet. Loveable and adorable, she's also house trained, quiet as a ninja, and non-destructive in the house. She's also inquisitive, adventurous, and loves to run around in fields! Parts of us don't want to see her leave.\n\n"),
								elem("span", "", "To know more, follow the adoption link below:\n\n\n"),
								elem("span", "", "          --=%=-- "),
								elem("a", "", "-Princess's Profile on Dogs Trust-") { it.setAttr("href", "https://www.dogstrust.org.uk/rehoming/dogs/dog/filters/bri~308~~~~n~/1174940/princess") },
								elem("span", "", " --=%=-- "),
							},
						},
						div("screen hallOfFame") {
							div("output") {
								msg := "The \"Find Emma\" Hall of Fame!\n\n\n"
								[
									["When       ", "Who                           ", "Cmds", "Moves", "Hi5s", "Presents"],
									["-----------", "------------------------------", "----", "-----", "----", "--------"],
									["23 Mar 2018", "Emma", "519", "752", "6", "8"],
								].each {
									msg += it[0].justl(11) + "  "
									msg += it[1].justl(30) + "  "
									msg += it[2].justr( 4) + "  "
									msg += it[3].justr( 5) + "  "
									msg += it[4].justr( 4) + "  "
									msg += it[5].justr( 8) + "\n"
								}
								msg += "\n\nIf you Find Emma, email me the completed save file and I'll add your details to this screen!\n\n"
								elem("span", "", msg),
								elem("span", "", "Contact details can be found at the bottom of "),
								elem("a", "", "Fantom-Factory") { it.setAttr("href", "http://www.fantomfactory.org/") },
								elem("span", "", "."),
							},
						},
					},
					elem("form", "#downloadForm") {
						it.setAttr("action", "/dog/download")
						it.setAttr("method", "POST")
						elem("input") {
							it.id = "downloadVal"
							it.setAttr("type", "hidden")
							it.setAttr("name", "cmdHis")
							it.setAttr("value", "")
						},
					},
					elem("a", "#downloadLink") {
						it.setAttr("download", "findEmmaCmds.txt")
					}, 
					elem("form", "#uploadForm") {
						it.setAttr("action", "/dog/upload")
						it.setAttr("method", "POST")
						it.setAttr("enctype", "multipart/form-data")
						elem("input") {
							it.id = "uploadVal"
							it.setAttr("type", "file")
						},
					},
				},
			}
		, doc.body.querySelector("footer"))
	
		prompt.focus
		
		startGame
		scrollScreen
	}
	
	Void exeCmd(Str cmdStr) {
		try doExeCmd(cmdStr)
		catch (Err err) {
			screen.add(div("cmdErr", err.traceToStr))
			scrollScreen
			throw err	// log in browser for more detail
		}
	}

	private Void doExeCmd(Str cmdStr) {
		cmdStr = cmdStr.trim
//		if (cmdStr.isEmpty) return
		screen.add(div("usrCmd", "\n> ${cmdStr.upper}"))

		cmds := cmdStr.split
		switch (cmds.first.lower) {
			case "inv":
			case "inventory":
				log(player.lookInventory + player.lookClothes)

			case "stats":
			case "statistics":
				log(player.statistics)
			
			case "?":
			case "h":
			case "help":
				if (cmds.size == 1)
					log(help)
				if (cmds.getSafe(1) == "more")
					log(helpMore)
			case "more":
				if (cmds.getSafe(1) == "help")
					log(helpMore)

			case "cls":
			case "clear":
				screen.removeAll

			case "logo":
				screen.add(div("logo", logo))

			case "his":
			case "history":
				msg := ""
				promptHis.each(20) |str| { msg += "> $str\n" }
				log(msg)
		
			case "save":
				nom := cmdStr.lower == "save" ? "autosave" : cmdStr[5..-1].trim
				win.localStorage["afQuestCmds-${nom}"] = cmdHis.save(game.player.gameStats.gameTime)
				log("Saved ${cmdHis.size} commands at ${cmdHis.savedAtStr}.")
				log("You may now close the browser and restart the game at this saved point using the command:\n\n> LOAD " + (nom=="autosave" ? "" : nom.upper))

			case "load":
				nom := cmdStr.lower == "load" ? "autosave" : cmdStr[5..-1].trim
				restoreFromLocalStorage("afQuestCmds-${nom}")

			case "del":
			case "delete":
				if (cmdStr.lower == "delete") return
				nom := cmdStr[6..-1].trim
				win.localStorage.remove("afQuestCmds-${nom}")
				log("Deleted $nom")

			case "ls":
			case "dir":
			case "list":
				size  := win.localStorage.size
				saved := ""
				for (i := 0; i < size; ++i) {
					key := win.localStorage.key(i)
					if (key.startsWith("afQuestCmds-")) {
						nomStr := key[12..-1]
						hisStr := win.localStorage[key]
						cmdHis := CmdHistory.load(hisStr)
						saved  += "${cmdHis.savedAtStr} ... ${nomStr}\n"
					}
				}
				if (saved.isEmpty)	saved = "You have no saved games."
				log(saved)
			
			case "download":
				form := doc.elemById("downloadForm")
				form.children.first->value = cmdHis.save(game.player.gameStats.gameTime)
				Win.eval("document.getElementById('downloadForm').submit()")

				// Naa - nice idea but doesn't work on FF!
				// https://stackoverflow.com/questions/2897619/using-html5-javascript-to-generate-and-save-a-file
//				url := Win.eval("var data = []; data.push(document.getElementById('downloadVal').value); var properties = {type: 'text/plain'}; var file; try { file = new File(data, 'saveEmmaCmds.txt', properties); } catch (e) { file = new Blob(data, properties); }; var url = URL.createObjectURL(file); url;")
//				doc.elemById("downloadLink").setAttr("href", url.toStr)
//				Win.eval("document.getElementById('downloadLink').click();")

			case "upload":
				doc.elemById("uploadVal").onEvent("uploaded", false) |e| {
					restoreFromLocalStorage("uploadedCmds")					
				}
				doc.elemById("uploadVal").onEvent("change", false) |e| {
					Win.eval("var uVal = document.getElementById('uploadVal'); var file = uVal.files[0]; if (file) { var fReader = new FileReader(); fReader.onload = function() { localStorage.setItem('uploadedCmds', fReader.result); var e = document.createEvent('HTMLEvents'); e.initEvent('uploaded', false, true); uVal.dispatchEvent(e); }; fReader.readAsText(file); }")
				}
				Win.eval("document.getElementById('uploadVal').click();")

			case "replay":
				screen.removeAll
				promptHis.clear
				startGame
				cmdHis.each {
					screen.add(div("usrCmd", "\n> ${it.upper}"))
					executeCmd(it)
					promptHis.add(it)
				}
			
//			case "cheat":
			case "supercalifragilisticexpialidocious":
				solution.splitLines.each {
					screen.add(div("usrCmd", "\n> ${it.trim.upper}"))
					valid := executeCmd(it)
					if (valid)
						cmdHis.add(it.trim.upper)
				}
				screen.scrollPos = Point(0f, screen.scrollSize.h - screen.size.h)

			default:
				valid := executeCmd(cmdStr)
				if (valid)
					cmdHis.add(cmdStr.trim.upper)
		}
		scrollScreen		
	}
	
	Void restoreFromLocalStorage(Str key) {
		history := win.localStorage[key]
		if (history == null)
			log("Could not find game.")
		else {
			silent = true
			try {
				cmdHis = CmdHistory.load(history)
				screen.removeAll
				startGame
				cmdHis.each {
					if (!silent)
						screen.add(div("usrCmd", "\n> ${it.upper}"))
					executeCmd(it)
					promptHis.add(it)
				}
				game.player.gameStats.timePlayed = cmdHis.timePlayed
			} catch (Err err) {
				silent = false
				log(err.traceToStr)
			}
			silent = false
			log("Loaded ${cmdHis.size} commands from save point ${cmdHis.savedAtStr}.")
			executeCmd("LOOK")
		}
	}
	
	override Void log(Obj? obj) {
		if (silent) return
		des := obj as Describe ?: Describe(obj?.toStr)
		if (des != null)
			screen.add(div("", "\n" + des.describe))
	}
	
	Void scrollScreen() {
		if ((screen.size.h + screen.scrollPos.y) < screen.scrollSize.h) {
			screen.scrollPos = Point(0f, screen.scrollPos.y + 16f)
			win.reqAnimationFrame { scrollScreen }
		}
	}
	
	Describe? help() {
		str := StrBuf()
		str.add("Game commands:\n")
		str.add("  - look    [exit | item]\n")
		str.add("  - move    <exit>\n")
		str.add("  - pickup  <item>\n")
		str.add("  - drop    <item>\n")
		str.add("  - wear    <item>\n")
		str.add("  - takeoff <item>\n")
		str.add("  - use     <item>\n")
		str.add("  - where   <item>\n")
		str.add("\n")
		str.add("Player commands:\n")
		str.add("  - rollover\n")
		str.add("  - hi5 <item>\n")
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
		str.add("Alternative synonyms, verbs, and abbreviations are allowed:\n")
		str.add("  - north\n")
		str.add("  - n\n")
		str.add("  - stats\n")
		str.add("  - get snack\n")
		str.add("  - open door\n")
		str.add("\n")
		str.add("Some actions require items to be dropped or gathered together in the same room.\n")
		str.add("\n")
		str.add("Terminal commands:\n")
		str.add("  - help\n")
		str.add("  - more help\n")
		str.add("  - cls\n")
		str.add("  - history\n")
		str.add("  - list\n")
		str.add("  - load     [game]\n")
		str.add("  - save     [game]\n")
		str.add("  - delete   [game]\n")
		str.add("  - download [game]\n")
		str.add("  - upload\n")
		str.add("\n")
		str.add("Now go find Emma.\n")
		return Describe(str)
	}
}
