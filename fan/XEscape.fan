
// FIXME open door with lead OR simplify use?

** Rhubarb patch
** clear spiders with rubarb - find bucket - find spade
** koi in deep pond
** snorkel in garage (with brick a brack) - wear - show photo to koi
** 
** delete shed - use summer house - go IN greenhouse
** squirrel?
** 
** dig veg patch to find... carrots? potatoes? nom
** dig lawn to find... mole! show photo
** 
** hose in patio
** harness in garage
** 
** spawn in greenhouse -> use hose to add water
** pickup (endless) spawn (with bucket)
** drop spawn in koi pond -> fish food!
** drop spawn in gold fish pond -> nothing, but set onEnter action (x2 ?) to make frogs -> pressie!
** 
** back lawn -> peanuts -> badger -> pressie
** 
** finish: backlawn, washing line (+buck+harnes+lead) -> new room, top of pole, garage roof, buzzard, car
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
		
		parcelUp := |Object inside->Object| {
			Object("parcel", "A small parcel wrapped up in gift paper. I wonder what's inside?") {
				it.canPickUp = true
				it.aliases = Str[,]
				it.verbs = "open|rip open|tear open|rip|tear".split('|')
				it.onUse = |Object me, Object? obj, Player player -> Describe| {
					player.room.objects.add(inside)
					player.room.objects.remove(me)
					player.gameStats.incParcelsOpened
					return Describe("You excitedly rip open the parcel, sending wrapping paper everywhere, to reveal ${inside.fullName}.")
				}
			}
		}
		
		present1 := Object("bottle of gin", "An expensive bottle of fine English gin.") {
			it.aliases = "gin".split
			it.verbs = "drink swig sip gulp".split
			it.canPickUp = true
			it.onUse = |Object me, Object? obj, Player player -> Describe?| {
				if (obj == null) {
					// TODO max 5 swigs - stagger about to exits-2, exits-1
					return Describe("You swig the gin. You feel woozy.")
				}
				return null
			}
		}

		newBirds := |Room room->Object| {
			Object("birds", "An assortment of tits, sparrows, and chaffinchs. All hopping around, chirping insistently, and scoffing the food.") {
				it.namePrefix = ""
				it.aliases = "bird".split
				it.verbs = "chase eat".split
				room.meta["birdsInGarden"] = true
				it.onPickUp = |Object me, Player player ->Describe?| {
					player.room.objects.remove(me)
					player.room.meta.remove("birdsInGarden")
					return Describe("You let your instinct take over and you manically sprint at the birds, tongue and drool handing out the side of your mouth. But alas, the birds are faster and fly away. All you can do is stand and watch them fly away.")
				}
				it.redirectOnUse(onPickUp)
				birds := it
				it.onUse = |Object me, Object? obj, Player player -> Describe?| {
					if (obj == null) return birds.onPickUp.call(me, player)
					else if (obj.matches("photo")) {
						desc := Describe("The birds gather round and chirp excitedly at the sight of their feeder. You point at the photo and shrug your shoulders to ask where Emma may be. A couple of crows land and yell, \"Carr, Carr!\" You think they may be trying to tell you something.")
						if (player.meta.containsKey("present.birds"))
							return desc
						else {
							player.room.objects.add(parcelUp(present1))
							player.meta["present.birds"] = true
							return desc += "In appreciation of their favourite feeder, the birds drop a present for you."
						}
					}
					return null
				}
			}
		}
		
		buzzardCheck := |Player player, Describe desc->Describe| {
			gardens := (Room[]) [`room:lawn`, `room:backLawn`, `room:frontLawn`].map |id->Room| { player.world.room(id) }
			if (gardens.all { it.meta["birdsInGarden"] == true }) {
				desc += "A loud screech pierces the air and all the birds instantly scatter.\n\nDaylight is eclipsed by the shadow of the enormous wingspan of a swooping buzzard. Attracted by the constant hive of activity in the gardens, the buzzard is here to feed. Its talons take a tight grip on your coat and it pounds the air with its wings. You no longer feel the ground under your feet."
				if (player.hasSmallBelly) {
					gardens.each { it.objects = it.objects.exclude { it.id == `obj:birds` } }
					player.transportTo(`room:birdsNest`)
					desc += "Before you know it, you're high above the garden looking down on the ponds below. The buzzard takes you into the trees before dropping you in a large makeshift nest and flying away, leaving you alone once more."
				} else {
					player.transportTo(`room:lawn`)
					desc += "The buzzard struggles with the weight of its new found prey and beats the air furiously. As much as it wanted to carry you to its lair, sheer will is no match for the size your belly. It drops you and powers away empty handed."
					birds := player.room.findObject("birds")
					player.room.objects.remove(birds)
				}
			}
			return desc
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
		
		postman := Object("Postman", "You see a burly figure in red costume carrying a large sack of goodies.") {
			it.onHi5 = |Object me, Player player -> Describe| {
				player.room.objects.add(parcelUp(boots))
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
					it.verbs = "show give".split
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
							it.namePrefix = ""
							it.edible("Unable to contain your desires, you gobble down the nuts.")
							it.onDrop = |Object seed->Describe?| {
								if (player.room.id == `room:outHouse`) {
									seed.canDrop = false
									player.inventory.remove(seed)
									return Describe("You place the peanuts back in the sack.")									
								}
								return null
							}
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
							it.namePrefix = ""
							it.edible("Unable to contain your desires, you lap up the seed.")
							it.onDrop = |Object seed->Describe?| {
								if (player.room.id == `room:outHouse`) {
									seed.canDrop = false
									player.inventory.remove(seed)
									return Describe("You place the seed back in the sack.")									
								}
								if (player.room.meta["isGarden"] == true && player.room.meta["birdsInGarden"] != true) {
									player.room.objects.add(newBirds(player.room))
									seed.canDrop = false
									player.inventory.remove(seed)
									desc := Describe("You scatter the seed around the garden and observe in wonder as a variety of garden birds appear from the hedgerows and start devouring the bird seed.")
									return buzzardCheck(player, desc)
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
							it.namePrefix = ""
							it.inedible("Out of curiosity you gobble up some fish food. But an instant rumbling in your belly makes you sick it all up again. You ponder if fish food is good for dogs?")
							it.onDrop = |Object seed->Describe?| {
								if (player.room.id == `room:outHouse`) {
									seed.canDrop = false
									player.inventory.remove(seed)
									return Describe("You place the fish food back in the box.")									
								}
								return null
							}
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
				Exit(ExitType.north, `room:theAvenue`).block("A heavy iron gate keeps you on the premises.", "A heavy iron gate keeps you on the premises"),
				Exit(ExitType.west, `room:driveway`),
			},

			Room("driveway", "The concrete driveway is adjacent to the front lawn and leads down to the avenue. A car is parked in the middle.") {
				it.namePrefix = "on the"
				Exit(ExitType.south, `room:backPorch`, "A door leads into the back porch."),
				Exit(ExitType.north, `room:theAvenue`).block("A heavy iron gate keeps you on the premises", "A heavy iron gate keeps you on the premises"),
				Exit(ExitType.east, `room:frontLawn`),
				Exit(ExitType.west, `room:garage`, "A small garage fronted with a large vertical lift, bright red, metal door.") {
					it.block("The door is closed.", "You sprint at the door and bounce off with a large clang. The door remains closed.")
				},
				Exit(ExitType.in, `room:car`, "A Golf 1.9 TDI. Colour, shark grey.").block("It is locked and all the doors are closed.", "The car is locked and all the doors are closed."),

				Object("garage door", "It is a large vertical lift, bright red, metal door.") {
					it.aliases = "door".split
					it.openExit("silver key", "west", "You use the key to unlock the door. The sprung hinge at the top lifts the door up and into the garage. ")
				},
			},
			Room("garage", "A new paint job hides the drab looking pre-fabricated concrete walls.") {
				Exit(ExitType.east, `room:driveway`),
			},
			Room("car", "A Golf 1.9 TDI. Colour, shark grey.") {
				it.meta["noExits"] = true	// no exit - it's the end!
			},
			Room("the avenue", "The Avenue, also known as The Ave.") {
				it.meta["noExits"] = true	// no entrance, no exits!
			},

			Room("patio", "Large paving slabs adorn the floor.") {
				it.namePrefix = "on the"
				Exit(ExitType.north, `room:backPorch`, "A door leads into the back porch."),
				Exit(ExitType.south, `room:goldfishPond`, "A couple of stone steps lead up to the goldfish pond"),
			},

			Room("goldfish pond", "It is a shallow square pond full of weeds and goldfish.") {
				it.namePrefix = "next to the"
				Exit(ExitType.east, `room:koiPond`),
				Exit(ExitType.north, `room:patio`, "A couple of stone steps lead down to the patio."),
				Exit(ExitType.south, `room:vegetablePatch`),
			},

			Room("koi pond", "The koi pond is a deep picturesque pond with a slate surround, complete with a stone waterfall feature in the corner.") {
				it.namePrefix = "next to the"
				Exit(ExitType.west, `room:goldfishPond`),
				Exit(ExitType.north, `room:backLawn`),
				Exit(ExitType.south, `room:lawn`),
			},

			Room("back lawn", "The back lawn is a patch of grass that backs up to the dining room.") {
				it.namePrefix = "on the"
				it.meta["isGarden"] = true
				Exit(ExitType.south, `room:koiPond`),
			},

			Room("lawn", "A featureless patch of grass in front of the summer house that's popular with the local avian wildlife, should there be enough food around.") {
				it.namePrefix = "on the"
				it.meta["isGarden"] = true
				Exit(ExitType.north, `room:koiPond`),
				Exit(ExitType.west, `room:vegetablePatch`),
				Exit(ExitType.in, `room:summerHouse`) {
//					it.block(onLookBlockMsg, onExitBlockMsg)
				},
			},

			Room("summer house", "") {
				Exit(ExitType.out, `room:lawn`),
			},

			Room("vegetable patch", "") {
				Exit(ExitType.in,    `room:shed`) {
					it.block(
						"A sea of dusty cobwebs roll from the shed door to the nether reaches of the back walls.",
						"You disturb the sea of dusty cobwebs as you enter. Spiders scuttle out from all directions and then stop. They hunch down, waiting, staring. All 8 of their eyes watching, anticipating your next movement. Which, unsurprisingly, is to leg it back out of the shed!",
						"Without webs to trap and ensnare, the spiders remain in hiding.")
				},
				Exit(ExitType.east,  `room:lawn`),
				Exit(ExitType.north, `room:goldfishPond`),
				Exit(ExitType.west,	 `room:greenhouse`),
			},

			Room("shed", "The shed is a dark and foreboding place. Amongst the muddy garden tools a hundred eyes shine back at you from within the dim light.") {
				Exit(ExitType.out, `room:vegetablePatch`),
			},

			Room("greenhouse", "") {
				Exit(ExitType.out, `room:vegetablePatch`),
			},
			
			Room("birds nest", "You are high in the trees with no obvious route back. The garden and house is sprawled out below you, and you see the car in the driveway. Wait! Was that movement you saw in the car just now?") {
				it.namePrefix = "in a large"
				Object("large egg", "A freshly laid bird egg.") {
					it.aliases = "egg".split
					it.edible("You gnaw a hole in the top and suck the contents out. A bit runny, but not bad. You use your paw to wipe your mouth and chuck the empty husk over the side.")
//					it.canPickUp = false	// ??? it's just for the description
				},
				Exit(ExitType.out, `room:tree2`, "Twigs give way to a precarious looking branch.") {
					it.oneTimeMsg("You climb out of the nest, slip, and tumble on to a branch below. The ground looks a long way down and tree climbing is not strong point of yours!")
				},
			},

			Room("tree", "You are in a maze of twisty tree branches, all alike.") {
				it.namePrefix = "in a"
				it.id = `room:tree1`
				Exit(ExitType.up,    `room:tree4`),
				Exit(ExitType.down,  `room:tree3`),
				Exit(ExitType.north, `room:tree2`),
				Exit(ExitType.south, `room:tree2`),
			},
			Room("tree", "You are in a maze of twisty tree branches, all alike.") {
				it.namePrefix = "in a"
				it.id = `room:tree2`
				Object("silver key", "The silver key must have found its way to the nest the same you did! It's small but looks important.") {
					it.aliases = "key".split
					it.canPickUp = true
				},
				Exit(ExitType.west, `room:tree1`),
				Exit(ExitType.east, `room:tree1`),
				Exit(ExitType.up,   `room:tree3`),
				Exit(ExitType.down, `room:tree4`),
			},
			Room("tree", "You are in a maze of twisty tree branches, all alike.") {
				it.namePrefix = "in a"
				it.id = `room:tree3`
				Exit(ExitType.up,    `room:tree1`),
				Exit(ExitType.north, `room:tree4`),
				Exit(ExitType.south, `room:tree4`),
				Exit(ExitType.down,  `room:summerHouseRoof`, "This part of the tree looks recognisable, maybe all is not lost!") {
					it.oneTimeMsg("You drop down on to the roof of the summer house. Fantastic! Salvation of the garden awaits!\n\nOnly as you look around, you realise it's still a long, bone breaking, drop to the floor. Suddenly you feel a little scared again.")
				},
			},
			Room("tree", "You are in a maze of twisty tree branches, all alike.") {
				it.namePrefix = "in a"
				it.id = `room:tree4`
				Exit(ExitType.down, `room:tree1`),
				Exit(ExitType.up,   `room:tree4`),
				Exit(ExitType.east, `room:tree3`),
				Exit(ExitType.west, `room:tree3`),
			},
			Room("summer house roof", "You sit on the apex and wonder what to do.") {
				it.namePrefix = "on the"
				Object("squirrel", "A grey squirrel with a large bushy tail sits quietly on the opposite end. It stares at you, chewing nonchalantly.") {
					it.verbs = "chase|eat|grab|follow|stare at".split('|')
					it.onUse = |Object me, Object? obj, Player player -> Describe?| {
						if (obj == null) {
							player.transportTo(`room:lawn`)
							return Describe("You stare back at the fluffy squeaky thing in front of you. Your eyes widen, you can't contain yourself! Must chase!\n\nThe squirrel senses danger and darts off the roof, climbing down a wooden beam holding up the roof. Without a thought you do the same.\n\nBefore you know it, you're on the lawn. The squirrel has disappeared and you're left wondering how you got there!")
						}
						return null
					}
				},
				Exit(ExitType.down, `room:lawn`, "You can see the garden lawn below, but it's way to far to jump!") {
					it.block("", "You teeter to the edge but crawl back when vertigo sets in!")
				},
			}
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
