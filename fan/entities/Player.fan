
@Serializable
class Player {
	
	Object[]	inventory	:= Object[,]
	Object[]	clothes		:= Object[,]
	Room		room
	Bool		canMove		:= true
	Bool		canPickUp	:= true
	Bool		canDrop		:= true
	Bool		canWear		:= true
	Bool		canTakeOff	:= true
	Bool		canUse		:= true

	Str:Obj?	data		:= Str:Obj?[:]

	|Exit  , Player -> Describe?|?	onMove
	|Object, Player -> Describe?|?	onPickUp
	|Object, Player -> Describe?|?	onDrop
	|Object, Player -> Describe?|?	onWear
	|Object, Player -> Describe?|?	onTakeOff

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
	
	Describe? wear(Object object) {
		descs := Describe?[,]
		descs.add(onWear?.call(object, this))

		if (canWear) {
			desc := object.onWear?.call(object, this)

			if (object.canWear) {
				clothes.add(object)
				room.objects.remove(object)	// remove from both as we're not sure where it came from
				inventory.remove(object)
				if (desc == null)
					desc = Describe("You wear ${object.fullName}")
			} else {
				if (desc == null)
					desc = Describe("You cannot wear ${object.fullName}")				
			}

			descs.add(desc)
		}
		
		gameStats.noOfCmds++
		return Describe(descs)
	}
	
	Describe? takeOff(Object object) {
		descs := Describe?[,]
		descs.add(onWear?.call(object, this))

		if (canWear) {
			desc := object.onWear?.call(object, this)

			if (object.canWear) {
				clothes.remove(object)
				room.objects.add(object)	// place in room, as inventory may be full
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
		str := StrBuf()
		
		if (inventory.isEmpty)
			str.add("You hold nothing.\n")
		else {
			str.add("You are holding:\n")
			inventory.each {
				str.add("  - ${it.fullName}\n")
			}
		}
		str.addChar('\n')
		
		if (clothes.isEmpty)
			str.add("You wear nothing.\n")
		else {
			str.add("You are wearing:\n")
			clothes.each {
				str.add("  - ${it.fullName}\n")
			}
		}

		return Describe(str)		
	}

	Describe statistics() {
		Describe(gameStats.print)
	}

	internal Object? findObject(Str str) {
		obj := null as Object
		if (obj == null)
			inventory.find { it.matches(str) }
		if (obj == null)
			clothes.find { it.matches(str) }
		return obj
	}
}
