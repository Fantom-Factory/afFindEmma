
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
	
	Describe? move(Str str) {
		exit := room.findExit(str)
		if (exit == null)
			return Describe("There is no ${str.upper}.")

		descs := Describe?[,]
		descs.add(onMove?.call(exit, this))
		
		if (canMove) {
			descs.add(exit.onMove?.call(exit, this))
			
			if (exit.canMove) {
				descs.add(room.onLeave?.call(room, this))
				room = gameData.room(exit.exitToId)
				descs.add(room.onEnter?.call(room, this))
			}
		}
		
		return Describe(descs)
	}
	
	Describe? pickUp(Str obj) {
		object := room.findObject(obj)
		if (object == null)
			return Describe("There is no ${obj.upper}.")

		descs := Describe?[,]
		descs.add(onPickUp?.call(object, this))

		if (canPickUp) {
			desc := object.onPickUp?.call(object, this)

			if (object.canPickUp) {
				room.objects.remove(object)
				inventory.add(object)
				if (desc == null)
					desc = Describe("You pick up the ${obj.upper}")
			} else {
				if (desc == null)
					desc = Describe("You cannot pick up the ${obj.upper}")				
			}

			descs.add(desc)
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
			desc := object.onDrop?.call(object, this)

			if (object.canDrop) {
				inventory.remove(object)
				room.objects.add(object)
				if (desc == null)
					desc = Describe("You drop the ${obj.upper}")
			} else {
				if (desc == null)
					desc = Describe("You cannot drop the ${obj.upper}")				
			}

			descs.add(desc)
		}
		
		return Describe(descs)
	}
	
	Describe? use(Str obj, Str? receiver) {
		object1 := findObject(obj)
		if (object1 == null)
			return Describe("There is no ${obj.upper}.")

		object2 := null as Object
		if (receiver != null) {
			object2 = findObject(receiver)
			if (object2 == null)
				object2 = room.findObject(receiver)
			if (object2 == null)
				return Describe("There is no ${receiver.upper}.")
		}

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