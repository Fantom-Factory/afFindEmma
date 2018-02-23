
class XEscape : Loader {
	
	override GameData load() {
		prelude := "You awake from a long cosy slumber."
		
		rooms := Room[
			Room("Cage", "The cage is just small enough for you to fit in and the floor is lined with a soft duvet. There is a pink handkerchief tied across the top, it reads, \"Secnirp\".") {
				it.namePrefix = "in a"
				Exit(ExitType.out, `room:backRoom`) {
					onExit = Exit.oneTimeMsg("You crawl out of the cage. You arch your back, stretch out your front legs, and let out a large yawn - it was a good nights sleep!") 
				},
				Object {
					it.id	= `obj:photo`
					it.name	= "Photo of Emma"
					it.desc = "It is a photo of your favourite play pal, Emma. You really miss her and long for some tender strokes. But where is she? You feel a mission is brewing..."
				},
			},
			
			Room("Back Room", "") {
				Exit(ExitType.in, `room:cage`),
				Exit(ExitType.west, `room:kitchen`) {
					it.blockedDesc = "You step out onto the slippery tiles. Your little legs have no grip and you start slipping and sliding everywhere. You frantically try to run but your splayed legs are in all directions. With luck and determination you manage to return back to the safety of carpet and the back room."
				}
			},

			Room("Kitchen", "") {
				Exit(ExitType.east, `room:backRoom`),
			},
		]
		
		objs := Object[
			Object {
				it.id	= `obj:photo`
				it.name	= "Photo of Emma"
				it.desc = "It is a photo of your favourite play pal, Emma. You really miss her and long for some tender strokes. But where is she? You feel a mission is brewing..."
			}
		]

		roomMap 	:= Uri:Room[:].addList(rooms) { it.id }
		objectMap	:= Uri:Object[:].addList(objs) { it.id }
		return GameData {
			it.prelude			= prelude
			it.rooms			= roomMap
			it.objects			= objectMap
			it.startRoomId		= `room:cage`
			it.startInventory	= Uri[,]
		}.validate
	}

}
