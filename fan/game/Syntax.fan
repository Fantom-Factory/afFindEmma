
@Js class Syntax {

	static const Str[]	lookSynonyms		:= "look |l "						.split('|', false)
	static const Str[]	moveSynonyms		:= "move |go |exit "				.split('|', false)
	static const Str[]	pickupSynonyms		:= "pickup |pick up |take |get "	.split('|', false)
	static const Str[]	dropSynonyms		:= "drop "							.split('|', false)
	static const Str[]	wearSynonyms		:= "wear |put on "					.split('|', false)
	static const Str[]	takeOffSynonyms		:= "take off "						.split('|', false)
//	static const Str[]	useSynonyms			:= "use "							.split('|', false)
	static const Str[]	useActions			:= "to |on |at |with |against"		.split('|', false)

	static const Str[]	hi5Synonyms			:= "hi5 |high five "				.split('|', false)
	static const Str[]	rolloverSynonyms	:= "rollover "						.split('|', false)

	static const Str[]	statisticsSynonyms	:= "stats |statistics "				.split('|', false)
	static const Str[]	inventorySynonyms	:= "inv |inventory "				.split('|', false)
	
//	static const Str	lookSyntax			:= "^(?:CMD)(?: (EXIT|ROOM.OBJECT|USER.OBJECT))?\$"
//	static const Str	moveSyntax			:= "^(?:CMD) (EXIT)\$"
//	static const Str	pickupSyntax		:= "^(?:CMD) (ROOM.OBJECT)\$"
//	static const Str	dropSyntax			:= "^(?:CMD) (USER.OBJECT)\$"
//	static const Str	useSyntax			:= "^[USER.OBJECT.VERB] (USER.OBJECT) [to|on|at|with] (ROOM.OBJECT)\$"
//	static const Str	statsSyntax			:= "^(?:CMD)\$"
//	static const Str	inventorySyntax		:= "^(?:CMD)\$"
//	static const Str	hi5Syntax			:= "^(?:CMD) (ROOM.OBJECT)?\$"
	
	** Note there are game cmds and sys cmds
	Cmd? compile(Player player, Str cmdStr) {
		cmdStr = cmdStr.trim.lower
		cmd := null as Cmd
		
		// do custom matching so we keep parsing context and are able to give customised error messages
		// regex's just give a yes / no, it worked / it didn't work answer
		
		if (cmd == null)	// use first - so it may override other cmds 
			cmd = matchUse(player, cmdStr)
		if (cmd == null)
			cmd = matchLook(player, cmdStr)
		if (cmd == null)
			cmd = matchMove(player, cmdStr)
		if (cmd == null)
			cmd = matchWear(player, cmdStr)
		if (cmd == null)
			cmd = matchTakeOff(player, cmdStr)	// check for 'take off' before 'take'
		if (cmd == null)
			cmd = matchPickup(player, cmdStr)
		if (cmd == null)
			cmd = matchDrop(player, cmdStr)
		if (cmd == null)
			cmd = matchHi5(player, cmdStr)
		if (cmd == null)
			cmd = matchRollover(player, cmdStr)
		if (cmd == null)
			cmd = matchStatistics(player, cmdStr)
		if (cmd == null)
			cmd = matchInventory(player, cmdStr)

		return cmd
	}
	
	Cmd? matchLook(Player player, Str cmdStr) {
		lookCmd := lookSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (lookCmd == null) return null
		
		if (cmdStr == lookCmd.trimEnd)
			return Cmd {
				it.method	= Player#look
				it.args		= Obj#.emptyList
			}

		cmdStr = cmdStr[lookCmd.size..-1] 
		lookAt := null as Describe

		if (lookAt == null)
			lookAt = player.room.findExit(cmdStr)

		if (lookAt == null)
			lookAt = player.room.findObject(cmdStr)

		if (lookAt == null)
			lookAt = player.findObject(cmdStr)

		if (lookAt == null)
			return Cmd("404 - ${cmdStr.upper} not found.")

		return Cmd {
			it.method	= Player#look
			it.args		= [lookAt]
		}
	}

	Cmd? matchMove(Player player, Str cmdStr) {
		isExit := ExitType.vals.any {
			it.name == cmdStr || it.name[0].toChar == cmdStr
		}
		if (isExit) {
			exit := player.room.findExit(cmdStr)
			if (exit == null)
				return Cmd("There is no ${cmdStr.upper}.")
			return Cmd {
				it.method	= Player#move
				it.args		= [exit]
			}
		}
		
		moveCmd := moveSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (moveCmd == null) return null
		
		if (cmdStr == moveCmd.trimEnd)
			return Cmd("Move where?")

		cmdStr = cmdStr[moveCmd.size..-1] 
		exit := player.room.findExit(cmdStr)
		if (exit == null)
			return Cmd("There is no ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#move
			it.args		= [exit]
		}
	}

	Cmd? matchPickup(Player player, Str cmdStr) {
		pickupCmd := pickupSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (pickupCmd == null) return null
		
		if (cmdStr == pickupCmd.trimEnd)
			return Cmd("Pick up what?")

		cmdStr = cmdStr[pickupCmd.size..-1] 
		object := player.room.findObject(cmdStr)
		if (object == null)
			return Cmd("There is no ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#pickup
			it.args		= [object]
		}
	}

	Cmd? matchDrop(Player player, Str cmdStr) {
		dropCmd := dropSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (dropCmd == null) return null
		
		if (cmdStr == dropCmd.trimEnd)
			return Cmd("Drop what?")

		cmdStr = cmdStr[dropCmd.size..-1] 
		object := player.findObject(cmdStr)
		if (object == null)
			return Cmd("There is no ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#drop
			it.args		= [object]
		}
	}

	Cmd? matchUse(Player player, Str cmdStr) {
		// use ROOM.OBJECT
		object := player.room.objects.find |obj| {
			verbCmd := obj.verbsLower.find { cmdStr == it || cmdStr.startsWith(it + " ") }
			if (verbCmd == null)
				return false
			if (cmdStr == verbCmd)
				return false
			
			verbStr := cmdStr[verbCmd.size+1..-1] 

			// check the verb belongs to the obj
			objStr := obj.startsWith(verbStr)
			if (objStr != null) {
				cmdStr = verbStr[objStr.size..-1].trimStart
				return true
			}
			return false
		}
		
		if (object != null) {
			if (!cmdStr.trimEnd.isEmpty)
				return Cmd("Too much information!")

			return Cmd {
				it.method	= Player#use
				it.args		= [object, null]
			}
		}
		
		// use PLAYER.OBJECT on ROOM.OBJECT
		object = player.inventory.find |obj| {
			verbCmd := obj.verbsLower.find { cmdStr == it || cmdStr.startsWith(it + " ") }
			if (verbCmd == null)
				return false
			if (cmdStr == verbCmd)
				return false
		
			verbStr := cmdStr[verbCmd.size+1..-1] 

			// check that the verb belongs to the obj
			objStr := obj.startsWith(verbStr)
			if (objStr != null) {
				cmdStr = verbStr[objStr.size..-1].trimStart
				return true
			}
			return false
		}
		
		if (object == null)
			return null
		
		// allow players to use objects if they're holding them
		if (cmdStr.trimEnd.isEmpty)
//			return Cmd("Use ${object.name} on what?")
			return Cmd {
				it.method	= Player#use
				it.args		= [object, null]
			}
		
		joinCmd := useActions.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (joinCmd == null) return Cmd("Please rephrase.")
		
		if (cmdStr == joinCmd.trimEnd)
			return Cmd("Use ${object.name} on what?")

		cmdStr = cmdStr[joinCmd.size..-1] 
		object2 := player.room.findObject(cmdStr)
		if (object2 == null)
			return Cmd("There is no ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#use
			it.args		= [object, object2]
		}
	}
	
	Cmd? matchWear(Player player, Str cmdStr) {
		wearCmd := wearSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (wearCmd == null) return null
		
		if (cmdStr == wearCmd.trimEnd)
			return Cmd("Wear what?")

		cmdStr = cmdStr[wearCmd.size..-1] 
		object := player.room.findObject(cmdStr)
		if (object == null)
			object = player.findObject(cmdStr)
		if (object == null)
			return Cmd("There is no ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#wear
			it.args		= [object]
		}
	}

	Cmd? matchTakeOff(Player player, Str cmdStr) {
		takeOffCmd := takeOffSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (takeOffCmd == null) return null
		
		if (cmdStr == takeOffCmd.trimEnd)
			return Cmd("Take off what?")

		cmdStr = cmdStr[takeOffCmd.size..-1] 
		object := player.findObject(cmdStr)
		if (object == null || !player.clothes.contains(object))
			return Cmd("You are not wearing ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#takeOff
			it.args		= [object]
		}
	}

	Cmd? matchHi5(Player player, Str cmdStr) {
		hi5Cmd := hi5Synonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (hi5Cmd == null) return null
		
		if (cmdStr == hi5Cmd.trimEnd)
			return Cmd("High five what?")

		cmdStr = cmdStr[hi5Cmd.size..-1] 
		object := player.room.findObject(cmdStr)
		if (object == null)
			return Cmd("There is no ${cmdStr.upper}.")

		return Cmd {
			it.method	= Player#hi5
			it.args		= [object]
		}
	}

	Cmd? matchRollover(Player player, Str cmdStr) {
		rollCmd := rolloverSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (rollCmd == null) return null
		
		return Cmd {
			it.method	= Player#rollover
			it.args		= Obj#.emptyList
		}
	}

	Cmd? matchStatistics(Player player, Str cmdStr) {
		moveCmd := statisticsSynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (moveCmd == null) return null
		
		return Cmd {
			it.method	= Player#statistics
			it.args		= Obj#.emptyList
		}
	}
	
	Cmd? matchInventory(Player player, Str cmdStr) {
		moveCmd := inventorySynonyms.find { cmdStr.startsWith(it) || cmdStr == it.trimEnd }
		if (moveCmd == null) return null
		
		return Cmd {
			it.method	= Player#listInventory
			it.args		= Obj#.emptyList
		}
	}
}

@Js class Cmd {
	Method?	method
	Obj?[]?	args
	Str?	msg
	
	new make(|This| f) { f(this) }

	new makeMsg(Str msg) { this.msg = msg }
	
	Describe? execute(Player player) {
		msg != null
			? Describe(msg)
			: method.callOn(player, args)
	}
	
	override Str toStr() {
		msg != null
			? msg
			: method.name + "(" + args.join(", ") { it.toStr.upper } + ")"
	}
}
