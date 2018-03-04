
@Js class XEscape : Loader {
	
	private static const Str openDoorDesc := "You toss the lead into the air and its loop catches on the handle. You grasp the other end with your teeth and give it a tug. The door swings open."
	
	override GameData load() {
		prelude := "You awake from a long cosy slumber and fondly remember the exciting, long walks from yesterday."
		
		newSnack := |->Object| {
			snack := [
				Object("dog biscuit", "A crunchy dog treat."),
				Object("dog chew", "Real rawhide coated with chicken flavouring."),
				Object("dog bone", "A large bone stuffed with extra marrow."),
				Object("dog treat", "A tasty snack for dogs"),
			].random
			snack.aliases = "snack biscuit chew bone treat".split
			snack.edible([
				"Om nom nom. Tasty!",
				"Yum, delicious!",
				"Chomp! Chomp! Chomp!",
				"Nom nom nom nom.",
				"Chew. Gnaw. Chomp. Swallow.",
				"Gulp!",
			].random)
			snack.data["snack"] = true		// TODO used?
			return snack
		}
		
		onRollover := |Player player -> Describe?| {
			postman := player.room.findObject("postman")
			if (postman != null) {
				snacksGiven := (postman.data["snacksGiven"] as Int) ?: 0
				if (snacksGiven >= 3)
					return Describe("Aww, the Postman is all out of dog treats.")
				postman.data["snacksGiven"] = snacksGiven + 1
				player.room.objects.add(newSnack())
				return Describe("You rollover onto your back and the Postman rubs your belly. Amidst cries of \"You're so cute!\" the Postie digs around in his pocket, fishes out a dog treat, and tosses it into the hall.")
			}
			return null
		}
		
		boots := Object("pair of boots", "A pair of shiny red dog booties with sticky soles.") {
			it.canPickUp = true
			it.aliases = "boots".split
			it.canWear = true
			it.onWear = |->Describe| { Describe("You slip the booties on over your back paws and fasten the velcro. They're a nice snug fit.") }
		}

		parcel := |Object inside->Object| {
			Object("parcel", "A small parcel wrapped up in brown paper. I wonder what's inside?") {
				it.canPickUp = true
				it.aliases = Str[,]
				it.verbs = "open|rip open|tear open|rip|tear".split('|')
				it.onUse = |Object me, Object? obj, Player player -> Describe| {
					player.room.objects.add(inside)
					player.room.objects.remove(me)					
					return Describe("You excitedly rip open the parcel, sending wrapping paper everywhere, to reveal ${inside.fullName}.")
				}
			}
		}
		
		postman := Object("Postman", "You see a burly figure in red costume carrying a large sack of goodies.") {
			it.onHi5 = |Object me, Player player -> Describe| {
				player.room.objects.add(parcel(boots))
				player.room.objects.remove(me)
				player.room.findExit("north").block("As soon as you step outside, the cold hits you. Brr! You dash back in side to the safety of the warm house.", "But it looks so cold and windy outside.")
				return Describe("You hang your paw in the air. The Postman kneels down, but instead of a 'high five' he whips out a signature scanner and collects your paw print!\n\n\"Thanks!\" he cheerfully says, tosses a parcel into the hallway, and disappears off down the garden path.")
			}
		}
		
		rooms := Room[
			Room("Cage", "The cage is just small enough for you to fit in and the floor is lined with a soft duvet. There is a pink handkerchief tied across the top, it reads, \"Ssecnirp\".") {
				it.namePrefix = "in a"
				Exit(ExitType.out, `room:diningRoom`, "You see the main dining room of the house and recall many a happy day stretched out in the sun as it streamed in through the wide windows.") {
					it.oneTimeMsg("You crawl out of the cage. You arch your back, stretch out your front legs, and let out a large yawn - it was a good nights sleep!") 
				},
				Object("photo of emma", "It is a photo of your favourite play pal, Emma. You really miss her and long for some tender strokes. You remember walks in the long grass, frolics, and sausage surprises. You wish you could do it all again. But where is she? You feel a mission brewing...") {
					it.aliases = "photo emma".split
					it.canPickUp = true
				},
				newSnack(),
			},
			
			Room("Dining Room", "The dining room is where you spend the majority of your contented days, sunning yourself in beams of light that stream through the windows.") {
				Exit(ExitType.in, `room:cage`, "The cage is where you sleep at night, dreaming of chasing ducks by the canal."),
				Exit(ExitType.north, `room:lounge`, "An open archway leads to the lounge."),
				Exit(ExitType.west, `room:kitchen`, "The kitchen! That tiled floor looks slippery though.") {
					it.isBlocked	= true
					it.onExit = |Exit exit, Player player-> Describe?| {
						exit.isBlocked = !player.isWearing("boots")
						return exit.isBlocked
							? Describe("You step out onto the slippery tiles. The pads on your little legs have no grip and you start slipping and sliding everywhere. You frantically try to run but your splayed legs are in all directions. With luck and determination you manage to return back to the safety of carpet and the back room.")
							: Describe("Your little booties give you traction on the slippery tiles.")
					}
				},
				Object("short lead", "A short black training lead with a loop on one end.") {
					it.canPickUp = true
					it.aliases = ["Lead"]
					it.verbs = "throw".split
				},
				Object("mystery box", "A cardboard box filled with scrunched up newspaper, although your nose also detects traces of food.") {
					it.aliases = "box".split('|')
					it.verbs   = "lookin|look in|rummage|rummage in".split('|')
					it.onUse   = |Object me, Object? obj, Player player -> Describe?| {
						if (obj != null) return null
						desc  := "You thust your head into the box and have a good snort around. You rustle around the newspaper to find "
						found := (0..3).random == 2
						if (!found)
							return Describe(desc + "nothing.")
						snack := newSnack()
						player.room.objects.add(snack)
						return Describe(desc + snack.fullName + "!")
					}
				},
				newSnack(),
			},
			
			Room("Lounge", "The lounge is where you spend your evenings, happily gnawing bones on the Sofa with Emma and Steve.") {
				Exit(ExitType.south, `room:diningRoom`, "An open archway leads to the dining room."),
				Exit(ExitType.west, `room:hallway`, "A door leads to the hallway.") {
					it.block("You bang your head on the door. It remains closed.", "It is closed.")
				},
				Object("door", "The door guards the hallway. Its handle looms high overhead, out of your reach.") {
					it.openExit("lead", "west", openDoorDesc)
				},
			},

			Room("Hallway", "You hear a door bell ring.") {
				Exit(ExitType.east, `room:lounge`),
				Exit(ExitType.north, `room:frontLawn`, "The font garden leads to the avenue.") {
					it.block("You move forward and bang your head on the door. It remains closed.", "It is closed.")
				},
				Object("front door", "It is the main door to the house. Its handle looms high overhead, out of your reach.") {
					it.aliases = "door".split
					it.openExit("lead", "north", openDoorDesc + ".. to reveal a burly Postman!") |door, obj, exit, player| {
						player.room.desc = ""
						player.room.objects.add(postman)
						exit.block("You quickly dash forward but the Postman is quicker. He blocks your exit and ushers you back inside.", "The Postman blocks your path.")
					}
				},
			},

			Room("Kitchen", "Tall shaker style kitchen cabinets line the walls in a Cheshire Oak finish, with a real Welsh slate worktop peeking over the top. You know that food magically appears from up there somehow, if only you were a little bit taller!") {
				Exit(ExitType.east, `room:diningRoom`),
				Exit(ExitType.west, `room:backPorch`),
				Object("back door", "The tradesman's entrance to the house. Its handle looms high overhead, out of your reach.") {
					it.aliases = "door".split
					it.openExit("lead", "west", openDoorDesc)
				},
				Object("oven", "A frequently used oven where baked delights are born.") {
					it.verbs = "open".split
					it.onUse = |Object me, Object? obj, Player player -> Describe?| {
						obj == null ? me.onLook?.call(me, player) : null
					}
					it.onLook = |Object oven, Player player -> Describe?| {
						cake := Object("birthday cake", "A fat vanilla sponge with lemon drizzle on top and cream in the middle.") {
							it.aliases = "cake".split
							it.edible("You plunge your head in and devour the cake with all the finesse of a Tazmanian devil. Emma would be proud!")
							it.verbs.add("savage")
						}
						player.room.objects.add(cake)
						oven.onLook = null
						return Describe("You lower the oven door to be greeted with a blast of warm air. The room fills with the sweet fragrance of edible goodies. You peer inside to find to find a Birthday cake!")
					}
				}
			},

			Room("Back Porch", "You see damp remains of an old coal shed with condensation and filtered rain water dripping from the ceiling.") {
				Exit(ExitType.west, `room:outHouse`),
				Exit(ExitType.east, `room:kitchen`),
				Exit(ExitType.north, `room:driveway`),
				Exit(ExitType.south, `room:patio`),
			},

			Room("Out House", "") {
				Exit(ExitType.east, `room:backPorch`),
				Object("sack of peanuts", "A large 15Kg sack of peanuts.") {
					it.aliases = "peanuts nuts".split
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("peanuts", "A small scoop of peanuts.") {
							it.aliases = "peanuts nuts".split
							it.edible("Unable to contain your desires, you gobble down the nuts.")
						})
						return Describe("Using a small plastic tray, you grab a small scoop of peanuts.")
					}
					it.redirectOnUse(it.onPickUp)
				},
				Object("sack of bird seed", "A large 15Kg sack of bird seed.") {
					it.aliases = "bird seed|birdseed|seed".split('|')
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("bird seed", "A small scoop of bird seed.") {
							it.aliases = "birdseed seed".split
							it.edible("Unable to contain your desires, you lap up the seed.")
						})
						return Describe("Using a small plastic tray, you grab a small scoop of bird seed.")
					}
					it.redirectOnUse(it.onPickUp)
				},
				Object("box of fish food", "A large biscuit tin full of fish food.") {
					it.aliases = "fish food|fishfood|food".split('|')
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("fish food", "A small scoop of fish food.") {
							it.aliases = "fishfood".split
							it.edible("Unable to contain your desires, you lap up the fish food.")
						})
						return Describe("Using a small plastic tray, you grab a small scoop of fish food.")
					}
					it.redirectOnUse(it.onPickUp)
				},
			},

			Room("Front Lawn", "") {
				Exit(ExitType.south, `room:hallway`),
				Exit(ExitType.west, `room:driveway`),
			},

			Room("Driveway", "") {
				Exit(ExitType.south, `room:backPorch`),
				Exit(ExitType.east, `room:frontLawn`),
				Exit(ExitType.west, `room:garage`),		// ??? garage?
				Exit(ExitType.in, `room:car`),
			},
			Room("Garage", "") {						// ??? garage?
				Exit(ExitType.east, `room:driveway`),
			},
			Room("car", "") {
				// no exit - it's the end!
			},

			Room("patio", "") {
				
			},
		]
		
		objs := Object[,]

		roomMap 	:= Uri:Room[:].addList(rooms) { it.id }
		objectMap	:= Uri:Object[:].addList(objs) { it.id }
		return GameData {
			it.prelude			= prelude
			it.rooms			= roomMap
			it.objects			= objectMap
			it.startRoomId		= `room:cage`
			it.startInventory	= Uri[,]
			it.onPickUp			= |Object obj, Player player -> Describe?| {
				if (player.inventory.size >= 1) {
					player.canPickUp = false
					return Describe("You are a dog, you have one mouth, you can not carry any more items!")
				}
				player.canPickUp = true
				return null
			}
			it.onRollover		= onRollover
		}.validate
	}
}
