
@Serializable
class Player {
	
	Object[]	inventory	:= Object[,]
	Room		room
	Str:Obj?	data		:= Str:Obj?[:]
	
	@Transient
	internal GameData	gameData
	
	new make(|This| f) { f(this) }

	Describe look(Str? obj := null) {
		obj = obj?.lower
		lookAt := null as Describe

		if (obj == null)
			lookAt = room
		
		if (lookAt == null)
			lookAt = findExit(obj)
		
		if (lookAt == null)
			lookAt = findObject(obj)

		if (lookAt == null)
			lookAt = Describe("404 - ${obj.upper} not found")

		return lookAt
	}
	
	Describe move(Str cmd) {
		cmd = cmd.lower
		exit := findExit(cmd)
		if (exit == null)
			return Describe("There is no ${cmd.upper}.")

		// FIXME help!? should there be an onBlock() or just onExit()?
		if (exit.isBlocked)
			return exit.onBlock?.call(this, room, exit) ?: Describe(exit.blockedDesc)
		
		// FIXME help!? should I recheck block status?
		descs := Describe?[,]
		descs.add(exit.onExit?.call(this, room, exit))
		
		descs.add(room.onLeave?.call(this, room))
		
		room = gameData.room(exit.exitToId)

		descs.add(room.onEnter?.call(this, room))
		
		return Describe(descs)
	}
	
	private Exit? findExit(Str str) {
		exitType := ExitType(str, false)
		return room.findExit(exitType)
	}

	private Object? findObject(Str str) {
		obj := room.findObject(str)
		if (obj == null)
			obj = inventory.find { it.name.lower == str || it.id.path.last == str }
		return obj
	}


	
//	private GameCtx ctx() {
//		GameCtx {
//			it.player	= this
//			it.room		= this.room
//		}
//	}
}


//class GameCtx {
//	Player	player
//	Room	room
//	
//	new make(|This| f) { f(this) }
//}