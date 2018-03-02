
class Game {
	
	Player?		player
	GameData?	gameData
	
	new make(|This| f) { f(this) }

	
	Describe start() {
		Describe([Describe(gameData.prelude), player.room])
	}
	
	
	static Game load() {
		gameData := XEscape().load
		player	 := Player {
			it.inventory 	= Object[,]
			it.room		 	= gameData.rooms[gameData.startRoomId]
			it.gameData	 	= gameData
			it.onMove		= gameData.onMove
			it.onPickUp		= gameData.onPickUp
			it.onDrop		= gameData.onDrop
			it.onWear		= gameData.onWear
			it.onTakeOff	= gameData.onTakeOff
			it.onUse		= gameData.onUse
			it.onHi5		= gameData.onHi5
			it.onRollover	= gameData.onRollover
		}
		return Game {
			it.player 	= player
			it.gameData	= gameData
		}
	}
	Void save() {
	}
}

@Serializable
class GameData {
	Str			prelude
	Uri:Room 	rooms
	Uri:Object	objects
	Uri			startRoomId
	Uri[]		startInventory

	|Exit  , Player -> Describe?|?	onMove
	|Object, Player -> Describe?|?	onPickUp
	|Object, Player -> Describe?|?	onDrop
	|Object, Player -> Describe?|?	onWear
	|Object, Player -> Describe?|?	onTakeOff
	|Object, Object?, Player -> Describe?|?	onUse
	|Object?, Player -> Describe?|?	onHi5
	|Player -> Describe?|?			onRollover

	new make(|This| f) { f(this) }

	
	Room room(Uri id) {
		rooms.getOrThrow(id)
	}
	
	Object object(Uri id) {
		objects.getOrThrow(id)
	}
	
	** Walk through all the data, making sure the IDs exist / match up
	This validate() {
		room(startRoomId)
		startInventory.each { object(it) }
		
		rooms.each |room| {
			if (room.desc.isEmpty)
				log.warn("$room.id desc is empty")
			if (room.exits.isEmpty)
				log.warn("$room.id has no exits")
			room.exits.each |exit| {
				this.room(exit.exitToId)
			}
		}
		
		// TODO check for reserved ID names such as east, west, in, out...
		
		return this
	}
	
	private Log log() { typeof.pod.log }
}

mixin Loader {
	abstract GameData load()
}

class GameStats {
	Duration	startTime	:= startTime = Duration.now
	Int			noOfCmds		{ private set }
	Int			noOfMoves 		{ private set }
	Int			noOfSnacksEaten { private set }
	Int			bellySize := 5	{ private set }
	private Int	legWork
	
	// TODO have a list of Game durations to allow pausing / saving
	
	Duration gameTime() {
		Duration.now - startTime
	}

	Void incCmds() {
		noOfCmds++
	}

	Void incMoves() {
		noOfMoves++
		legWork++
		if (legWork >= 3) {
			legWork = 0
			decBellySize
		}
	}

	Void incSnacks() {
		noOfSnacksEaten++
		incBellySize
	}
	
	Void incBellySize() {
		bellySize = bellySize.increment.min(9)
	}

	Void decBellySize() {
		bellySize = bellySize.decrement.max(0)
	}
	
	Str print() {
		str := StrBuf()
		str.add("Time played ........ ${DurationLocale.approx(gameTime)}\n")
		str.add("Commands entered ... ${noOfCmds}\n")
		str.add("Moves made ......... ${noOfMoves}\n")
		str.add("Snacks eaten ....... ${noOfSnacksEaten}\n")
		str.add("Belly size ......... (" + ("X" * bellySize) + ")\n")
		return str.toStr
	}
	
	override Str toStr() { print }
}
