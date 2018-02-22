
class XEscape : Loader {
	
	override GameData load() {
		rooms := Room[
			Room("Cage", "The cage is just small enough for you to fit in. There is a pink handkerchief tied across the exit, it reads, \"Secnirp\".") {
				it.namePrefix = "in a"
				Exit(ExitType.out, `room:backRoom`) {
					onExit = |Player player, Room room, Exit exit -> Describe?| {
						exit.onExit = null
						return Describe("You crawl out of the cage. You arch your back, stretch your front legs out, and let out a large yawn - it was a good nights sleep!")
					}
				},
			},
			
			Room("Back Room", "") {
				Exit(ExitType.in, `room:cage`),
			},
		]
		
		objs := Object[
			,
		]
		
		roomMap 	:= Uri:Room[:].addList(rooms) { it.id }
		objectMap	:= Uri:Object[:].addList(objs) { it.id }
		return GameData {
			it.rooms			= roomMap
			it.objects			= objectMap
			it.startRoomId		= `room:cage`
			it.startInventory	= Uri[,]
		}.validate
	}

}
