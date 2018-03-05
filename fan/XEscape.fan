
@Js class XEscape : Loader {
	
	private static const Str openDoorDesc := "You toss the lead into the air and its loop catches on the handle. You grasp the other end with your teeth and give it a tug. The door swings open."
	
	override GameData load() {
		prelude := "You awake from a long cosy slumber and fondly remember the exciting, long walks from yesterday."
		
		// todo have factories that make new objects
		
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
			return snack
		}
		
		newBirds := |->Object| {
			Object("birds", "An assortment of tits, sparrows, and chaffinchs. ") {
				it.namePrefix = ""
				it.aliases = "bird".split
				it.verbs = "chase".split
				// FIXME chase birds
//				it.onUse
			}
		}
		
		onRollover := |Player player -> Describe?| {
			postman := player.room.findObject("postman")
			if (postman != null) {
				snacksGiven := (postman.meta["snacksGiven"] as Int) ?: 0
				if (snacksGiven >= 3)
					return Describe("Aww, the Postman is all out of dog treats.")
				postman.meta["snacksGiven"] = snacksGiven + 1
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
				player.room.findExit("north")
					.block(
						"But it looks so cold and windy outside.", 
						"As soon as you step outside, the cold hits you. Brr! You dash back in side to the safety of the warm house.", 
						"Your coat keeps you warm."
					) { !player.isWearing("coat") }
				return Describe("You hang your paw in the air. The Postman kneels down, but instead of a 'high five' he whips out a signature scanner and collects your paw print!\n\n\"Thanks!\" he cheerfully says, tosses a parcel into the hallway, and disappears off down the garden path.")
			}
		}
		
		rooms := Room[
			Room("cage", "The cage is just small enough for you to fit in and the floor is lined with a soft duvet. There is a pink handkerchief tied across the top, it reads, \"Ssecnirp\".") {
				it.namePrefix = "in a"
				it.meta["inside"] = true
				Exit(ExitType.out, `room:diningRoom`, "You see the main dining room of the house and recall many a happy day stretched out in the sun as it streamed in through the wide windows.")
					.oneTimeMsg("You crawl out of the cage. You arch your back, stretch out your front legs, and let out a large yawn - it was a good nights sleep!"), 
				Object("photo of emma", "It is a photo of your favourite play pal, Emma. You really miss her and long for some tender strokes. You remember walks in the long grass, frolics, and sausage surprises. You wish you could do it all again. But where is she? You feel a mission brewing...") {
					it.aliases = "photo emma".split
					it.canPickUp = true
				},
				newSnack(),
			},
			
			Room("dining room", "The dining room is where you spend the majority of your contented days, sunning yourself in beams of light that stream through the windows.") {
				it.meta["inside"] = true
				Exit(ExitType.in, `room:cage`, "The cage is where you sleep at night, dreaming of chasing ducks by the canal."),
				Exit(ExitType.north, `room:lounge`, "An open archway leads to the lounge."),
				Exit(ExitType.west, `room:kitchen`, "The kitchen! That tiled floor looks slippery though.") {
					it.block(
						"", 
						"You step out onto the slippery tiles. The pads on your little legs have no grip and you start slipping and sliding everywhere. You frantically try to run but your splayed legs are in all directions. With luck and determination you manage to return back to the safety of carpet and the back room.", 
						"Your little booties give you traction on the slippery tiles."
					) |me, player| { !player.isWearing("boots") }
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
						desc  := "You thrust your head into the box and have a good snort around. You rustle around the newspaper to find "
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
			
			Room("lounge", "The lounge is where you spend your evenings, happily gnawing bones on the Sofa with Emma and Steve.") {
				it.meta["inside"] = true
				Exit(ExitType.south, `room:diningRoom`, "An open archway leads to the dining room."),
				Exit(ExitType.west, `room:hallway`, "A door leads to the hallway.")
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Object("door", "The door guards the hallway. Its handle looms high overhead, out of your reach.") {
					it.openExit("lead", "west", openDoorDesc)
				},
			},

			Room("hallway", "You hear a door bell ring.") {
				it.meta["inside"] = true
				Exit(ExitType.east, `room:lounge`),
				Exit(ExitType.north, `room:frontLawn`)
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Object("front door", "It is the main door to the house. Its handle looms high overhead, out of your reach.") {
					it.aliases = "door".split
					it.openExit("lead", "north", openDoorDesc + ".. to reveal a burly Postman!") |door, obj, exit, player| {
						player.room.desc = ""
						player.room.objects.add(postman)
						exit.block("The Postman blocks your path.", "You quickly dash forward but the Postman is quicker. He blocks your exit and ushers you back inside.")
					}
				},
			},

			Room("kitchen", "Tall shaker style kitchen cabinets line the walls in a Cheshire Oak finish, with a real Welsh slate worktop peeking over the top. You know that food magically appears from up there somehow, if only you were a little bit taller!") {
				it.meta["inside"] = true
				Exit(ExitType.east, `room:diningRoom`),
				Exit(ExitType.west, `room:backPorch`)
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Object("back door", "The tradesman's entrance to the house. Its handle looms high overhead, out of your reach.") {
					it.aliases = "door".split
					it.openExit("lead", "west", openDoorDesc)
				},
				Object("oven", "A frequently used oven where baked delights are born.") {
					it.verbs = "open".split
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
					it.redirectOnUse(it.onLook)
				}
			},

			Room("back porch", "You see damp remains of an old coal shed with condensation and filtered rain water dripping from the ceiling.") {
				it.meta["inside"] = true
				Exit(ExitType.west, `room:outHouse`),
				Exit(ExitType.east, `room:kitchen`) {
					it.block(
						"", 
						"You step out onto the slippery tiles. The pads on your little legs have no grip and you start slipping and sliding everywhere. You frantically try to run but your splayed legs are in all directions. With luck and determination you manage to return back to the out house.", 
						"Your little booties give you traction on the slippery tiles."
					) |me, player| { !player.isWearing("boots") }
				},
				Exit(ExitType.north, `room:driveway`)
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Exit(ExitType.south, `room:patio`)
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Object("door", "The door to the patio outside. Its handle looms high overhead, out of your reach.") {
					it.openExit("lead", "south", openDoorDesc) |door, obj, exit, player| {
						exit.block(
							"But it looks so cold and windy outside.", 
							"As soon as you step outside, the cold hits you. Brr! You dash back in side to the safety of the warmth.", 
							"Your coat keeps you warm."
						) { !player.isWearing("coat") }
					}
				},
				Object("door", "The door to the driveway outside. Its handle looms high overhead, out of your reach.") {
					it.openExit("lead", "north", openDoorDesc) |door, obj, exit, player| {
						exit.block(
							"But it looks so cold and windy outside.", 
							"As soon as you step outside, the cold hits you. Brr! You dash back in side to the safety of the warmth.", 
							"Your coat keeps you warm."
						) { !player.isWearing("coat") }
					}
				},
			},

			Room("out house", "The converted coal shed is now used as a pantry and general utility room. It's been painted in an unusual yellow cream colour.") {
				it.meta["inside"] = true
				Exit(ExitType.east, `room:backPorch`),
				Object("washing machine", "A front loading washing machine. It looks like it's recently finished a wash.") {
					it.verbs = "open".split
					it.onLook = |Object oven, Player player -> Describe?| {
						coat := Object("coat", "A bright pink thermal dog coat, designed to keep the cold at bay.") {
							it.canWear	 = true
							it.onWear	 = |->Describe| {
								if (player.meta["tooColdToMove"] == true) {
									player.canMove = true
									player.onMove = null
									player.meta.remove("tooColdToMove")
								}
								return Describe("You pull the coat on over your head and tie the velcro straps around your waist. Ahh, toasty warm!")
							}
							it.onTakeOff = |->Describe?| {
								// taking the coat off outside immobilises you
								if (player.room.meta["inside"] != true) {
									player.meta["tooColdToMove"] = true
									player.canMove = false
									player.onMove = |->Describe?| { Describe("Your mind lunges forward, but your body does not. It is so cold, you've frozen to the spot!") }
									return Describe("You take your coat off and immediately regret it as you start shivering. It's sooo cold out here!")
								}
								return null
							}
						}
						player.room.objects.add(coat)
						oven.onLook = null
						return Describe("You open the washing machine door and pull out a clean and dry, pink dog coat.")
					}
					it.redirectOnUse(it.onLook)
				},
				Object("sack of peanuts", "A large 15Kg sack of peanuts.") {
					it.aliases = "peanuts nuts".split
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("peanuts", "A small scoop of peanuts.") {
							it.aliases = "peanuts nuts".split
							it.edible("Unable to contain your desires, you gobble down the nuts.")
						})
						return Describe("Using a small plastic tray, you grab a scoop of peanuts.")
					}
					it.redirectOnUse(it.onPickUp)
				},
				Object("sack of bird seed", "A large 15Kg sack of bird seed.") {
					it.aliases = "bird seed|birdseed|seed".split('|')
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("bird seed", "A small scoop of bird seed.") {
							it.aliases = "birdseed seed".split
							it.edible("Unable to contain your desires, you lap up the seed.")
							it.onDrop = |->Describe?| {
								if (player.room.meta["isGarden"] == true) {
									player.room.objects.add(newBirds())
									// FIXME check all gardens
									return Describe("You scatter the seed around the garden and observe in wonder as a variety of garden birds appear from the hedgerows and start devouring the bird seed.")
								}
								return null
							}
						})
						return Describe("Using a small plastic tray, you grab a scoop of bird seed.")
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
						return Describe("Using a small plastic tray, you grab a scoop of fish food.")
					}
					it.redirectOnUse(it.onPickUp)
				},
			},

			Room("front lawn", "The front lawn is an odd triangle shaped piece of land that adjoins the driveway. It is hemmed in by a thick hedge.") {
				it.namePrefix = "on the"
				it.meta["isGarden"] = true
				Exit(ExitType.south, `room:hallway`, "The front door to the house leading to the hallway."),
				Exit(ExitType.north, `room:theAvenue`).block("A heavy iron gate keeps you on the premises", "A heavy iron gate keeps you on the premises"),
				Exit(ExitType.west, `room:driveway`),
			},

			Room("driveway", "The concrete driveway is adjacent to the front lawn and leads down to the avenue. A car is parked in the middle.") {
				it.namePrefix = "on the"
				Exit(ExitType.south, `room:backPorch`),
				Exit(ExitType.north, `room:theAvenue`).block("A heavy iron gate keeps you on the premises", "A heavy iron gate keeps you on the premises"),
				Exit(ExitType.east, `room:frontLawn`),
				Exit(ExitType.west, `room:garage`, "A small garage fronted with a large vertical lift, bright red, metal door.") {
					it.block("The door is closed.", "You sprint at the door and bounce off with a large clang. The door remains closed.")
				},
				Exit(ExitType.in, `room:car`, "A Golf 1.9 TDI. Colour, shark grey.").block("It is locked and all the doors are closed.", "The car is locked and all the doors are closed.")
			},
			Room("garage", "A new paint job hide the drab looking pre-fabricated walls.") {
				Exit(ExitType.east, `room:driveway`),
			},
			Room("car", "A Golf 1.9 TDI. Colour, shark grey.") {
				it.meta["noExits"] = true
				// no exit - it's the end!
			},
			Room("the avenue", "The Avenue, also known as The Ave.") {
				it.meta["noExits"] = true
			},

			Room("patio", "Large paving slabs adorn the floor.") {
				it.namePrefix = "on the"
				Exit(ExitType.north, `room:backPorch`),
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
