
@Serializable
class Player {
	
	Object[]	inventory	:= Object[,]
	Room		room
	Bool		canPickUp	:= true
	Bool		canDrop		:= true
	Bool		canUse		:= true

	Str:Obj?	data		:= Str:Obj?[:]

	|Object, Player -> Describe?|?	onPickUp
	|Object, Player -> Describe?|?	onDrop
	|Object, Player -> Describe?|?	onUse
	
	@Transient
	internal GameData	gameData
	
	new make(|This| f) { f(this) }

	Describe look(Str? obj := null) {
		obj = obj?.lower
		lookAt := null as Describe

		if (obj == null)
			lookAt = room
		
		if (lookAt == null)
			lookAt = room.findExit(obj)
		
		if (lookAt == null)
			lookAt = room.findObject(obj)

		if (lookAt == null)
			lookAt = findObject(obj)

		if (lookAt == null)
			lookAt = Describe("404 - ${obj.upper} not found")

		return lookAt
	}
	
	Describe? move(Str cmd) {
		cmd = cmd.lower
		exit := room.findExit(cmd)
		if (exit == null)
			return Describe("There is no ${cmd.upper}.")

		// FIXME help!? should there be an onBlock() or just onExit()?
		if (exit.isBlocked)
			return exit.onBlock?.call(exit, this) ?: Describe(exit.blockedDesc)
		
		// FIXME help!? should I recheck block status?
		descs := Describe?[,]
		descs.add(exit.onExit?.call(exit, this))
		
		// FIXME should onExit be called before or after leave / enter?
		
		descs.add(room.onLeave?.call(room, this))
		
		room = gameData.room(exit.exitToId)

		descs.add(room.onEnter?.call(room, this))
		
		return Describe(descs)
	}
	
	Describe? pickUp(Str obj) {
		object := room.findObject(obj)
		if (object == null)
			return Describe("There is no ${obj.upper}.")

		descs := Describe?[,]
		descs.add(onPickUp?.call(object, this))

		if (canPickUp) {
			descs.add(object.onPickUp?.call(object, this))

			if (object.canPickUp) {
				room.objects.remove(object)
				inventory.add(object)
			}
		}
		
		return Describe(descs)
	}
	
	Describe? drop(Str obj) {
		object := findObject(obj)
		if (object == null)
			return Describe("There is no ${obj.upper}.")

		descs := Describe?[,]
		descs.add(onDrop?.call(object, this))

		if (canDrop) {
			descs.add(object.onDrop?.call(object, this))

			if (object.canDrop) {
				inventory.remove(object)
				room.objects.add(object)
			}
		}
		
		return Describe(descs)
	}
	
	Describe? use(Str obj) {
		object := findObject(obj)
		if (object == null)
			return Describe("There is no ${obj.upper}.")

		descs := Describe?[,]
		descs.add(onUse?.call(object, this))

		if (canUse) {
			desc := object.onUse?.call(object, this)
			if (desc == null && descs.first == null)
				desc = Describe("Apparently, nothing of interest happened.")
			descs.add(desc)
		}

		return Describe(descs)
	}
	
	private Object? findObject(Str str) {
		inventory.find { it.matches(str) }
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