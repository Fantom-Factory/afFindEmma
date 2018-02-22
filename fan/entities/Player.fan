
@Serializable
class Player {
	
	Object[]	inventory	:= Object[,]
	Room		room
	Str:Obj?	data		:= Str:Obj?[:]
	
	@Transient
	internal GameData	gameData
	
	new make(|This| f) { f(this) }

	Describe look(Uri? id := null) {
		if (id == null)
			return room
		
		if (id.scheme == "obj")
			return inventory.find { it.id == id }
		
		if (id.scheme == "exit")
			return room.exits.find { it.id == id }
		
		throw UnsupportedErr(id.toStr)
	}
	
	Describe? move(Uri exitId) {
		exit := room.visibleExits.find { it.id == exitId }
		
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