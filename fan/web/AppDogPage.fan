using dom
using graphics

@Js class AppDogPage : Commander, DomBob {
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
		box := null as Elem
		doc.body.add(
			box = div("box") {
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
					div("screen") {
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
						it.setAttr("download", "saveEmmaCmds.txt")
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
		)
	
		prompt.focus
		
		startGame
		scrollScreen
	}
	
	Void exeCmd(Str cmdStr) {
		cmdStr = cmdStr.trim.lower
		screen.add(div("usrCmd", "\n> ${cmdStr.upper}"))

		switch (cmdStr) {
			case "help":
				log(help)
			
			case "more help":
			case "help more":
				log(helpMore)

			case "cls":
			case "clear":
				screen.removeAll

			case "logo":
				screen.add(div("logo", logo))

			case "history":
				msg := ""
				promptHis.each(20) |str| { msg += "> $str\n" }
				log(msg)
		
			case "save":
				win.localStorage["cmdHistory"] = cmdHis.save
				log("Saved ${cmdHis.size} commands at " + cmdHis.savedAt.toLocale("D MMM YYYY, hh:mm") + ".")
				log("You may now close the browser and restart the game at this saved point using the \"LOAD\" command.")

			case "load":
				log("Loading saved game...")
				restoreFromLocalStorage("cmdHistory")
			
			case "download":
				form := doc.elemById("downloadForm")
				form.children.first->value = cmdHis.save
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

			case "ch":
			case "cheat":
				cheat
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
			log("Could not find saved game.")
		else {
			silent = true
			try {
				cmdHis = CmdHistory.load(history)
				screen.removeAll
				startGame
				cmdHis.each {
					executeCmd(it)
					promptHis.add(it)
				}
			} catch (Err err) {
				silent = false
				log(err.traceToStr)
			}
			silent = false
			log("Loaded ${cmdHis.size} commands from save point " + cmdHis.savedAt.toLocale("D MMM YYYY, hh:mm") + ".")
			executeCmd("LOOK")
		}
	}
	
	override Void log(Obj? obj) {
		if (silent) return
		des := obj as Describe ?: Describe(obj?.toStr)
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
		str.add("  - load / save\n")
		str.add("  - upload / download\n")
		str.add("\n")
		str.add("Now go find Emma.\n")
		return Describe(str)
	}
}
