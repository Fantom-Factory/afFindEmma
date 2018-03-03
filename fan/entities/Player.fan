
@Serializable
class Player {
	
	Object[]	inventory	:= Object[,]
	Object[]	clothes		:= Object[,]	// TODO rename to wearing?
	Room		room
	Bool		canMove		:= true
	Bool		canPickUp	:= true
	Bool		canDrop		:= true
	Bool		canWear		:= true
	Bool		canTakeOff	:= true
	Bool		canUse		:= true
	Bool		canHi5		:= true

	Str:Obj?	data		:= Str:Obj?[:]

	|Exit  , Player -> Describe?|?	onMove
	|Object, Player -> Describe?|?	onPickUp
	|Object, Player -> Describe?|?	onDrop
	|Object, Player -> Describe?|?	onWear
	|Object, Player -> Describe?|?	onTakeOff
	|Object, Object?, Player -> Describe?|?	onUse
	|Object?, Player -> Describe?|?	onHi5
	|Player -> Describe?|?			onRollover
	
	GameStats	gameStats	:= GameStats()
	
	@Transient
	internal GameData	gameData
	
	new make(|This| f) { f(this) }

	Describe look(Describe? at := null) {
		if (at == null) at = room

		descs := Describe?[at]
		
		if (at is Object)
			descs.add(((Object) at).onLook?.call(at, this))
		
		gameStats.incCmds
		return Describe(descs)
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
		str.add("Alternative synonyms, verbs, and abbreviations are allowed, e.g.:\n")
		str.add("  - go n\n")
		str.add("  - get snack\n")
		str.add("  - eat snack\n")
		str.add("  - hi5 squirrel\n")
		str.add("\n")
		str.add("You can use items in the room, but you must pick it up to action it on another item, e.g.:\n")
		str.add("  - eat snack\n")
		str.add("vs\n")
		str.add("  - pickup snack\n")
		str.add("  - throw snack at door\n")
		str.add("\n")
		str.add("You can only wear items in your inventory.\n")
		return Describe(str)
	}
	
	Describe statistics() {
		Describe(gameStats.print)
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

	Describe? move(Exit exit) {
		descs := Describe?[,]
		descs.add(onMove?.call(exit, this))
		
		if (canMove) {
			descs.add(exit.onExit?.call(exit, this))
			
			if (!exit.isBlocked) {
				descs.add(room.onLeave?.call(room, this))
				room = gameData.room(exit.exitToId)
				descs.add(room.onEnter?.call(room, this))
			}
		}
		
		gameStats.incCmds
		gameStats.incMoves
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
		
		gameStats.incCmds
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
		
		gameStats.incCmds
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
		
		gameStats.incCmds
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
		
		gameStats.incCmds
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

		gameStats.incCmds
		return Describe(descs)
	}
	
	Describe? hi5(Object object) {
		descs := Describe?[,]
		descs.add(onHi5?.call(object, this))

		if (canHi5) {
			desc := object.onHi5?.call(object, this)
			descs.add(desc)
		}

		descs = descs.exclude { it == null }
		if (descs.isEmpty)
			descs.add(Describe("You high five! But sadly, the ${object.name} leaves you hanging. It's kind of embarrassing."))				
		
		gameStats.incCmds
		return Describe(descs)
	}
	
	Describe? rollover() {
		desc := onRollover?.call(this)

		if (desc == null)
			desc = Describe("You rollover. It impresses no one.")

		gameStats.incCmds
		return desc
	}
	
	Bool isWearing(Str str) {
		clothes.any { it.matches(str) }
	}

	internal Object? findObject(Str str) {
		obj := null as Object
		if (obj == null)
			obj = inventory.find { it.matches(str) }
		if (obj == null)
			obj = clothes.find { it.matches(str) }
		return obj
	}
}
