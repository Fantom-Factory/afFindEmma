
@Js class Player {
	
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

	Str:Obj?	meta		:= Str:Obj?[:]

	// todo to avoid future bugs, these should err if you attempt to overwrite a non-null value
	// thus forcing you to explicitly set null first
	|Exit  , Player -> Describe?|?	onMove
	|Object, Player -> Describe?|?	onPickUp
	|Object, Player -> Describe?|?	onDrop
	|Object, Player -> Describe?|?	onWear
	|Object, Player -> Describe?|?	onTakeOff
	|Object, Player -> Describe?|?	onUse
	|Object?, Player -> Describe?|?	onHi5
	|Player -> Describe?|?			onRollover

	GameStats	gameStats	:= GameStats()
	
	@Transient
	internal GameData	gameData
	
	new make(|This| f) { f(this) }

	GameData world() { gameData }
	
	Describe look(Describe? at := null) {
		if (at == null) at = room

		descs := Describe?[at]
		
		if (at is Object)
			descs.add(((Object) at).onLook?.call(at, this))
		
		gameStats.incCmds
		return Describe(descs)
	}
	
	Describe statistics() {
		Describe(gameStats.print)
	}
	
	Describe lookInventory() {
		str := StrBuf()
		if (inventory.isEmpty)
			str.add("You hold nothing.\n")
		else {
			str.add("You are holding ").add(inventory.join(", ") { it.fullName }).addChar('.').addChar('\n')
		}
		return Describe(str)		
	}
	
	Describe lookClothes() {
		str := StrBuf()
		if (clothes.isEmpty)
			str.add("You wear nothing.\n")
		else {
			str.add("You are wearing ").add(clothes.join(", ") { it.fullName }).addChar('.').addChar('\n')
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
		descs.add(gameStats.incMoves)
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
					desc = Describe("You pick up the ${object.name}.")
			} else {
				if (desc == null)
					desc = Describe("You cannot pick up the ${object.name}.")				
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
					desc = Describe("You drop the ${object.name}.")
			} else {
				if (desc == null)
					desc = Describe("You cannot drop the ${object.name}.")				
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
					desc = Describe("You wear ${object.fullName}.")
			} else {
				if (desc == null)
					desc = Describe("You cannot wear ${object.fullName}.")				
			}

			descs.add(desc)
		}
		
		gameStats.incCmds
		return Describe(descs)
	}
	
	Describe? takeOff(Object object) {
		descs := Describe?[,]
		descs.add(onTakeOff?.call(object, this))

		if (canTakeOff) {
			desc := object.onTakeOff?.call(object, this)

			if (object.canTakeOff) {
				clothes.remove(object)
				room.objects.add(object)	// place in room, as inventory may be full
				if (desc == null)
					desc = Describe("You take off the ${object.name}.")
			} else {
				if (desc == null)
					desc = Describe("You cannot take off the ${object.name}.")				
			}

			descs.add(desc)
		}
		
		gameStats.incCmds
		return Describe(descs)
	}
	
	Describe? use(Object object1) {
		descs := Describe?[,]
		descs.add(onUse?.call(object1, this))

		if (canUse) {
			desc := object1.onUse?.call(object1, this)
			
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
	
	Bool isHolding(Str str) {
		inventory.any { it.matches(str) }
	}
	
	Bool has(Str str) {
		isHolding(str) || isWearing(str)
	}
	
	Bool hasSmallBelly() {
		gameStats.bellySize <= 3
	}

	Bool hasLargeBelly() {
		gameStats.bellySize >= 6
	}
	
	Void transportTo(Uri roomId) {
		room = gameData.room(roomId)
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
