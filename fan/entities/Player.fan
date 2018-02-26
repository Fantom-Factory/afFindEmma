
@Serializable
class Player {
	
	Object[]	inventory	:= Object[,]
	Room		room
	Bool		canMove		:= true
	Bool		canPickUp	:= true
	Bool		canDrop		:= true
	Bool		canUse		:= true

	Str:Obj?	data		:= Str:Obj?[:]

	|Exit  , Player -> Describe?|?	onMove
	|Object, Player -> Describe?|?	onPickUp
	|Object, Player -> Describe?|?	onDrop

	|Object, Object?, Player -> Describe?|?	onUse
	
	GameStats	gameStats	:= GameStats()
	
	@Transient
	internal GameData	gameData
	
	new make(|This| f) { f(this) }

	Describe look(Describe? at := null) {
		if (at == null) at = room
		gameStats.noOfCmds++
		return at
	}
	
	Describe? move(Exit exit) {
		descs := Describe?[,]
		descs.add(onMove?.call(exit, this))
		
		if (canMove) {
			descs.add(exit.onMove?.call(exit, this))
			
			if (!exit.isBlocked) {
				descs.add(room.onLeave?.call(room, this))
				room = gameData.room(exit.exitToId)
				descs.add(room.onEnter?.call(room, this))
			}
		}
		
		gameStats.noOfCmds++
		gameStats.noOfMoves++
		return Describe(descs)
	}
	
	Describe? pickup(Object object) {
		descs := Describe?[,]
		descs.add(onPickUp?.call(object, this))

		if (canPickUp) {
			desc := object.onPickUp?.call(object, this)

			if (object.canPickUp) {
				room.objects.remove(object)
				inventory.add(object)
				if (desc == null)
					desc = Describe("You pick up the ${object.name}")
			} else {
				if (desc == null)
					desc = Describe("You cannot pick up the ${object.name}")				
			}

			descs.add(desc)
		}
		
		gameStats.noOfCmds++
		return Describe(descs)
	}
	
	Describe? drop(Object object) {
		descs := Describe?[,]
		descs.add(onDrop?.call(object, this))

		if (canDrop) {
			desc := object.onDrop?.call(object, this)

			if (object.canDrop) {
				inventory.remove(object)
				room.objects.add(object)
				if (desc == null)
					desc = Describe("You drop the ${object.name}")
			} else {
				if (desc == null)
					desc = Describe("You cannot drop the ${object.name}")				
			}

			descs.add(desc)
		}
		
		gameStats.noOfCmds++
		return Describe(descs)
	}
	
	Describe? use(Object object1, Object? object2) {
		descs := Describe?[,]
		descs.add(onUse?.call(object1, object2, this))

		if (canUse) {
			desc := null as Describe
			if (object2 != null)
				desc = object2.onUse?.call(object2, object1, this)
			else
				desc = object1.onUse?.call(object1, null, this)
			
			if (desc == null)
				desc = Describe("Apparently, nothing of interest happened.")
			descs.add(desc)
		}

		gameStats.noOfCmds++
		return Describe(descs)
	}
	
	Describe listInventory() {
		msg := "state"
		return Describe(msg)		
	}

	Describe statistics() {
		msg := "state"
		return Describe(msg)
	}

	internal Object? findObject(Str str) {
		inventory.find { it.matches(str) }
	}
}
