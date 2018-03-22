
** Known Bug - if you take off your coat just before hoisting yourself up the washing line, you can wander the map without it on.
** If can then become trapped inside as you can't go outside without a coat. 
@Js class XEscape : Loader {
	
	private static const Str openDoorDesc := "You toss the lead into the air and its loop catches on the handle. You grasp the other end with your teeth and give it a tug. The door swings open."
	
	override GameData load() {
		prelude := "You awake from a long cosy slumber and fondly remember the exciting, long walks from yesterday."
		
		// todo have factories that make new objects
		
		msgFn := |Str msg-> |->Describe| | { |->Describe| { Describe(msg) } }
		
		newSnack := |->Object| {
			snack := [
				Object("dog biscuit", "A crunchy dog treat."),
				Object("dog chew", "Real rawhide coated with chicken flavouring."),
				Object("dog bone", "A large bone stuffed with extra marrow."),
				Object("dog treat", "A tasty snack for dogs"),
				Object("scooby snack", "Scooby, scooby, doo!"),
			].random
			// everything must match everything else for the load cmd to work
			snack.aliases = "biscuit|chew|bone|treat|snack|dog biscuit|dog chew|dog bone|dog treat|scooby snack".split('|')
			snack.edible([
				"Om nom nom. Tasty!",
				"Yum, delicious!",
				"Chomp! Chomp! Chomp!",
				"Nom nom nom nom.",
				"Chew. Gnaw. Chomp. Swallow.",
				"Gulp!",
				"Bursting with energy, you feel ready for action like Scrappy Doo!",
			].random)
			return snack
		}
		
		spiderFight := |Player player, Str attackType, Int damage, Str msg -> Describe?| {
			spider := player.room.findObject("spider")
			if (spider == null) return null
			
			health := spider.meta["health"] as Int
			if (spider.meta.containsKey("attack.${attackType}")) {
				desc := Describe("The spider is clever and learns fast. This time it dodges your attack and stands its ground.")
				desc += "Spider health: ${health}/10"
				return desc
			}
			
			spider.meta["attack.${attackType}"] = true
			desc   := Describe(msg)
			health -= damage
			spider.meta["health"] = health
			if (health <= 0) {
				player.room.objects.remove(spider)
				desc += "The spider, fearing more retribution, retreats and curls up in the corner of the greenhouse. With its legs curled up around him, the spider looks a lot smaller and a lot less threatening. You decide you can now safely ignore it."
				health = 0
				player.room.objects.remove(spider)
				player.achievement("4 legs are better than 8")
				player.room.add(newSnack())
				player.room.add(Object("trough of frog spawn", "Someone has placed the frog spawn in the plastic trough, presumably to prevent it from freezing over in the pond.") {
					it.aliases = "frogspawn spawn".split
					it.meta["hydrated"] = false
					it.onLook = |Object trough -> Describe?| {
						if (trough.meta["hydrated"] == false)
							return Describe("But now it looks dehydrated and is in danger of drying out. What can you do?") 
						return Describe("But the trough has no food and you're concerned the tadpoles, once hatched, will go hungry.") 
					}
					it.onPickUp = |Object trough -> Describe?| {
						if (trough.meta["hydrated"] == false)
							return Describe("The dehydrated frogspawn looks too delicate to move.")
						if (!player.has("bucket") && !player.room.has("bucket"))
							return Describe("You try picking up the frog spawn but it just dribbles through your paws and slops back in the trough.")
						bucket := player.findObject("bucket") ?: player.room.findObject("bucket") 
						bucket.meta["hasSpawn"] = true
						return Describe("You dip the bucket in the trough and scoop up some frog spawn.")
					}
				})
			}
			desc += "Spider health: ${health}/10"
			if (health <= 0)
				desc += "Time to look around the greenhouse and see what else there is!"
			return desc
		}
		newVeg := |->Object| {
			snack := [
				Object("carrot", "A crunchy carrot."),
				Object("potato", "An ugly potato with lots of eyes."),
				Object("strawberry", "A sweet wild strawberry. Lucky the birds didn't find it!"),
				Object("slug", "A fat slimy slug. Looks edible though!"),
			].random
			// everything must match everything else for the load cmd to work
			snack.aliases = "veg vegetable carrot potato strawberry slug".split
			if (snack.name == "slug")
				snack.edible("Lick. Slurp. Gulp. Proof that dogs will eat anything!")
			else
				snack.edible([
					"Om nom nom.",
					"Chomp! Chomp! Chomp!",
					"Nom nom nom nom.",
					"Chew. Gnaw. Chomp. Swallow.",
					"A bit bitter, but not bad.",
				].random)
			return snack
		}

		parcelUp := |Object inside, Str from->Object| {
			Object("parcel", "A small parcel wrapped up in gift paper. I wonder what's inside?") {
				it.canPickUp = true
				it.aliases = "present gift".split
				it.verbs = "open|rip open|tear open|rip|tear".split('|')
				it.onUse = |Object me, Player player -> Describe| {
					player.room.objects.add(inside)
					player.room.objects.remove(me)
					player.openParcel(from)
					return Describe("You excitedly rip open the parcel, sending wrapping paper everywhere, to reveal ${inside.fullName}.")
				}
			}
		}

		presentBirds := Object("bottle of gin", "An expensive bottle of fine English gin.") {
			it.aliases = "gin".split
			it.verbs = "drink swig sip gulp".split
			it.canPickUp = true
			it.onUse = |Object me, Player player -> Describe?| {
				spider := spiderFight(player, "gin", 5, "You grab a rag from the floor, stuff it in the end of the gin bottle and set light to it. \"Let's see how this thirsty spider drinks a Molotov cocktail!\" you think as you hurl your home made fire bomb.\n\nThe bottle fragments on the spiders's head, coating it in fire. The spider screams and rolls around in the web, putting the flames out. Defiantly, it springs back to its feet ready for more.")
				if (spider != null) {
					player.achievement("Russian bartender")
					player.room.objects.remove(me)
					player.inventory.remove(me)
					return spider
				}
				// TODO max 3 swigs - stagger about to exits-2, exits-1
				return Describe("You swig the gin. You feel woozy.") + player.gameStats.incSnacks
			}
		}
		presentGoldfish := Object("box of chocolates", "A small box of assorted milk chocolates.") {
			it.aliases = "box chocolates chocs".split
			it.edible("You scoff the chocolates with all the finesse you'd expect from a dog.")
		}
		presentKoi := Object("pulley blueprints", "It's a hand drawn picture of a pulley system used to lever heavy objects out of the pond, but you figure the principle it could be applied to other uses. It comprises of a bucket, some rope, and a harness.") {
			it.namePrefix = ""
			it.aliases = "blueprints".split
		}
		presentMole := Object("comfortable pyjamas", "A stripy pair of comfortable cotton pyjamas.") {
			it.canWear = true
			it.onWear = msgFn("Ah! Soft and comfortable. In fact, you feel a little sleepy.")
		}
		presentSquirrel := Object("tea bag", "Of the English breakfast variety.") {
			it.aliases = "tea bag".split
			it.verbs = "drink brew".split
			it.edible("Ah! You brew a perfect cup of tea!")
		}
		presentFrogs := Object("bubble bath", "A bottle of bright green, relaxing bubble bath.") {
			it.canPickUp = true
			it.onDrop = |Object bubbles, Player player -> Describe?| {
				if (player.room.has("frogs")) {
					bubbles.canDrop = false
					player.room.objects.remove(bubbles)
					player.inventory.remove(bubbles)
					player.achievement("The green party")
					return Describe("You accidently knock the bottle of bubble bath into the pond of frogs. Before you know it, bubbles and foam is flying everywhere. The frogs love it and start jumping and swimming, croaking and singing even more! Boy, those frogs sure know how to party!")
				}
				return null
			}
			it.redirectOnUse(it.onDrop)
		}
		presentLarry := Object("women's underwear", "A pair of racy red, slinky women's underwear. Your size too!") {
			it.namePrefix = ""
			it.aliases = "underwear knickers".split
			it.verbs = "give".split
			it.canPickUp = true
			it.canWear = true
			it.onWear = msgFn("You slip the knickers on over your back legs. You're not too sure about the frilly bits, but at least they don't make your bum look big!")
			it.onDrop = |Object knickers, Player player -> Describe?| {
				if (player.room.has("mole")) {
					player.inventory.remove(knickers)
					player.clothes.remove(knickers)
					player.room.objects.remove(knickers)
					knickers.canDrop = false
					knickers.canTakeOff = false
					mole := player.room.findObject("mole")
					player.room.objects.remove(mole)
					if (player.hasOpenedParcel("mole"))
						player.room.objects.add(newSnack())
					else {
						player.room.objects.add(parcelUp(presentMole, "mole"))
						player.achievement("Return the reds")
					}
					return Describe("\"Oh! My wife's knickers!\" exclaims the mole. \"Thank you Larry for giving them back, they are wife's favourite after all! Here you go, have something in return.\" The mole tosses a parcel out, up ends, and burrows away out of sight.")
				}
				return null
			}
			it.redirectOnUse(it.onDrop)
		}

		photoOfEmma := |->Object| {
			Object("photo of emma", "It is a photo of your favourite play pal, Emma. You really miss her and long for some tender strokes. You remember walks in the long grass, frolics, and sausage surprises. You wish you could do it all again. But where is she? You feel a mission brewing...") {
				it.aliases = "photo emma".split
				it.verbs = "show give".split
				it.canPickUp = true
				it.onUse = |Object me, Player player -> Describe?| {
					if (player.room.has("birds")) {
						desc := Describe("You show the birds the photo of Emma. The birds gather round and chirp excitedly at the sight of their feeder. You point at the photo and shrug your shoulders to ask where Emma may be. A couple of crows land and yell, \"Carr, Carr!\" You think they may be trying to tell you something.")
						if (player.hasOpenedParcel("birds"))
							return desc
						player.room.objects.add(parcelUp(presentBirds, "birds"))
						return desc += "In appreciation of their favourite feeder, the birds drop a present for you."
					}
					if (player.room.has("goldfish") && !player.room.has("frogs")) {	// frogs come first!
						desc := Describe("You show the goldfish the photo of Emma. They swim around in excited circles - they love the sight of their feeder!")
						if (player.hasOpenedParcel("goldfish"))
							return desc
						player.room.objects.add(parcelUp(presentGoldfish, "goldfish"))
						return desc += "So much so, they nose up a little gift from the bottom of the pond!"
					}
					if (player.room.has("koi carp")) {
						if (!player.isWearing("snorkel"))
							return Describe("You try to show the koi the photo of Emma, but from the bottom of the pond they can't see it.")

						if (!player.room.has("bubbles")) {
							player.room.add(Object("Bubbles the Koi Carp", "A large joyful, orange and white fish who likes to swim by the surface and blow bubbles!") {
								it.aliases = "bubbles".split
								it.onHi5 = |->Describe| {
									player.incHi5("Bubbles")
									return Describe("Bubbles rolls onto his side to expose a fishy fin. You slap paw and fin and exclaim, \"High five!\" Bubbles then performs a victory roll in acknowledgement.")
								}
							})
						}

						desc1 := Describe("With the mask and snorkel firmly attached, you thrust your head deep into the pond. When the bubbles clear, giant fish appear.\n\n\"I am Ginger.\" said one, \"The king of the wet lands. And this is Bubbles.\" Bubbles blew some. It seems he's quite aptly named.\n\nGinger continued, \"To find the feeder, thou shalt require a water containment vessel.\"")
						desc2 := Describe("You try talking back, but it doesn't work, what with the snorkel and all. So you just wave goodbye instead.")
						if (player.hasOpenedParcel("koi carp"))
							return desc1 + desc2 
						player.room.objects.add(parcelUp(presentKoi, "koi carp"))
						return desc1 + "\"And here is a small gift to help you on your quest.\"" + desc2
					}
					if (player.room.has("larry the badger")) {
						desc := Describe("You show the photo of Emma to Larry. Larry whistles and says, \"Yeah, she's hot alright!\"")
						if (player.hasOpenedParcel("Larry"))
							return desc
						player.room.objects.add(parcelUp(presentLarry, "Larry"))
						return desc += "\"Actually,\" says Larry, \"That reminds me. Here's a little something I found. Just don't ask me where I got it!\""
					}
					if (player.room.has("mole")) {
						desc := Describe("You show the photo of Emma to the mole.")
						return desc += "\"Yep, that's my wife alright.\" he says, \"I recognise them raspberries anywhere!\"\n\nYou check the photo and it's definitely a facial portrait of Emma. You decide the mole must be very blind indeed."
					}
					if (player.room.has("spider")) {
						return spiderFight(player, "photo", 2, "The spider lunges at you but you whip out the photo of Emma and guard yourself with it. The spider stops its attack and instead stares at the photo in a trance like state. Beauty has tamed the beast, and with fours times as many eyes, it sees four times as much beauty.\n\nBut this advantage won't last forever. Best attack it again while you can.")
					}
					if (player.room.has("frogs")) {
						desc := Describe("You hold the photo of Emma up to the frogs and exclaim, \"Has anyone seen this girl!?\".\n\nThe pond goes eerily quiet. A crowned frog hops onto a stone next to you and proudly proclaims, \"I am the frog king. Lore from old tells of a hairy beast that saved us from a barren and scorched land and transported us here, to the pond of plenty. So yes, we will help you in your quest.\n\n\"The koi have blueprints to a pulley system you can use to ascend the washing line. You may have to improvise a little, but once up there, you should be able to find your friend.\"\n\nAnd with that, he hops back in the pond and the frog partying continues!")
						player.achievement("Times of old")
						if (player.hasOpenedParcel("frogs"))
							return desc
						player.room.objects.add(parcelUp(presentFrogs, "frogs"))
						desc += "The frogs then yell, \"Elixir of life!\" and chuck you a parcel."
						return desc
					}
					
					if (player.room.has("squirrel")) {
						desc := Describe("You show the photo to NutSack. \"Emma the Feeder, she's great she is! Try making like a squirrel and climb up high somewhere. You may spot here from there.\"")
						if (player.hasOpenedParcel("NutSack"))
							return desc
						player.room.objects.add(parcelUp(presentSquirrel, "NutSack"))
						return desc += "\"And here's a little something that reminds me of her!\" says NutSack and tosses you a parcel."
					}
					return null
				}
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
			}
		}
		
		buzzardCheck := |Player player, Describe desc->Describe| {
			gardens := (Room[]) [`room:lawn`, `room:backLawn`, `room:frontLawn`].map |id->Room| { player.world.room(id) }
			if (gardens.all { it.meta["birdsInGarden"] == true }) {
				desc += "A loud screech pierces the air and all the birds instantly scatter.\n\nDaylight is eclipsed by the shadow of the enormous wingspan of a swooping buzzard. Attracted by the constant hive of activity in the gardens, the buzzard is here to feed. Its talons take a tight grip on your coat and it pounds the air with its wings. You no longer feel the ground under your feet."
				if (player.hasSmallBelly) {
					gardens.each { it.objects = it.objects.exclude { it.id == `obj:birds` } }
					player.inventory.each { player.room.add(it) }; player.inventory.clear	// drop everything so you can pick up the key
					player.transportTo(`room:birdsNest`)
					desc += "Before you know it, you're high above the garden looking down on the ponds below. The buzzard takes you into the trees before dropping you in a large makeshift nest and flying away, leaving you alone once more."
				} else {
					player.transportTo(`room:lawn`)
					desc += "The buzzard struggles with the weight of its new found prey and beats the air furiously. As much as it wanted to carry you to its lair, sheer will is no match for the size your belly. It drops you and powers away empty handed.\n\nAs thankful as you are that the danger has passed, you do wonder where you may have been taken otherwise."
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
			if (player.room.id == `room:goldfishPond`) {
				goldfish := player.room.findObject("goldfish")
				player.room.objects.remove(goldfish)
				return Describe("You roll on to your back, teeter on the edge of the pond, and loose your balance.\n\nSplosh!\n\nAs fast you fell in, you spring right out again - hoping nobody saw you. You give a little shake, trying to act cool. It may have worked too, if it wasn't for the pond weed on your head!\n\nIt impressed no-one.") 				
			}
			if (player.room.id == `room:koiPond`) {
				koiCarp := player.room.findObject("koi carp")
				bubbles := player.room.findObject("bubbles")
				player.room.objects.remove(koiCarp)
				player.room.objects.remove(bubbles)
				return Describe("You roll on to your back, teeter on the edge of the pond, and loose your balance.\n\nSplosh!\n\nAs fast you fell in, you spring right out again - hoping nobody saw you. You give a little shake, trying to act cool. It may have worked too, if it wasn't for the pond weed on your head!\n\nIt impressed no-one.") 				
			}
			if (player.room.id == `room:garageRoof`) {
				player.room.meta["buzzard.avoided"] = true
				return Describe("A loud screech once again pierces the air and a buzzard swoops in from behind. You react fast and rollover.\n\nSparks explode around you as powerful talons drag across the roof and claws grasp nothing. Momentum carries the buzzard onward and it is forced to fly away empty handed. The danger has passed.") 
			}
			emma := player.room.findObject("emma")
			if (emma != null && !emma.name.contains("photo")) {
				snacksGiven := (emma.meta["snacksGiven"] as Int) ?: 0
				if (snacksGiven >= 5)
					return Describe("Aww, Emma is all out of dog treats.")
				emma.meta["snacksGiven"] = snacksGiven + 1
				player.room.objects.add(newSnack())
				return Describe("You rollover onto your back and Emma rubs your belly. You writhe your head in joy as Emma cries out \"Who's a good girl!?\" She's so impressed!\n\nEmma digs around in her coat pocket and fishes out a dog treat.")
			}
			larry := player.room.findObject("larry the badger")
			if (larry != null) {
				snacksGiven := (larry.meta["snacksGiven"] as Int) ?: 0
				if (snacksGiven >= 5)
					return Describe("Aww, Larry is all out of dog treats.")
				larry.meta["snacksGiven"] = snacksGiven + 1
				player.room.objects.add(newSnack())
				return Describe("You rollover onto your back and on to your front again. Larry watches in amazement before doing the same! He giggles at learning a new trick and hands you a treat in appreciation.\n\n\"Thanks for all the peanuts.\" says Larry, \"Say, if you've not already, try feeding *all* the birds round here, they're looking a bit hungry too!\"")
			}
			mole := player.room.findObject("mole")
			if (mole != null) {
				return Describe("You roll and wriggle around on your back, accidently caving in some freshly dug holes as you do so. The mole is not impressed.")
			}
			spider := player.room.findObject("spider")
			if (spider != null) {
				return spiderFight(player, "rollover", 2, "You observe the spider is more agile on its bed of cobwebs. So thinking fast you start to rollover, and over, and over around the greenhouse, taking out the sticky cobwebs as you go. You break free before getting cocooned yourself, and dust yourself down.\n\nThe spider howls in anguish at having its home destroyed.")
			}
			squirrel := player.room.findObject("squirrel")
			if (squirrel != null) {
				return Describe("You rollover and the squirrel is very impressed!\n\n\"That's great!\" he says. \"I'll tell you what, if you ever get hassled by any of them eight legged freaks, give 'em a poke with a sturdy stick, that'll sort them right out!\"")
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
				player.room.objects.add(parcelUp(boots, "Postman"))
				player.room.objects.remove(me)
				player.room.findExit("north")
					.block(
						"But it looks so cold and windy outside.", 
						"As soon as you step outside, the cold hits you. Brr! You dash back in side to the safety of the warm house.", 
						"Your coat keeps you warm."
					) { !player.isWearing("coat") }
				player.incHi5("Postman")
				return Describe("You hang your paw in the air. The Postman kneels down, but instead of a 'high five' he whips out a signature scanner and collects your paw print!\n\n\"Thanks!\" he cheerfully says, tosses a parcel into the hallway, and disappears off down the garden path.")
			}
		}

		climbWashingLine := |Object obj, Player player->Describe?| {
			if (player.room.id != `room:backLawn`) return null

			if (obj.matches("hosepipe")) {
				hosepipe := obj
				if (player.meta["washingLine.clipped"] == true) {

					// drop whatever you're holding - it makes no sense to jump with it
					hose := player.inventory.first
					if (hose != null) {
						player.inventory.remove(hose)
						player.room.add(hose)
					}

					player.transportTo(`room:washingLine`)
					player.meta.remove("washingLine.clipped")
					player.canMove = true
					player.onMove = null
					return Describe("You aim the hosepipe nozzle at the suspended bucket and pull the trigger. Excitement mounts as the bucket begins to fill with water.\n\nAt first, the washing line sags. But then, the line tightens. As the bucket gets heavier, the laws of physics pull you sky ward. Nearing the washing line itself you scrabble and grab hold of the iron pipe support.\n\nYou unclip the lead, drop the hose, and look around.")
				}
				return null
			}
			
			canClimbWashingLine :=
				(player.has("lead"  ) || player.room.has("lead"  )) &&
				(player.has("bucket") || player.room.has("bucket")) &&
				 player.isWearing("harness")

			if (canClimbWashingLine) {
				if (player.meta["washingLine.clipped"] == true) {
					player.meta.remove("washingLine.clipped")
					player.canMove = true
					player.onMove = null
					return Describe("You unclip yourself and the bucket from the home made pully system.")
				} else {
					player.meta["washingLine.clipped"] = true
					player.canMove = false
					player.onMove = |->Describe| { Describe("You move forward but are pulled back by the harness / bucket contraption to which you're attached.") }
					return Describe("You clip one end of the lead to your harness and the other to the bucket, which you swing over the washing line.\n\nLooking at the bucket swaying in the air above you, you note that it could make a good pully system; if only you had something to fill it with to counter balance your weight!")
				}
			}
			return null
		}
		
		rooms := Room[
			Room("cage", "The cage is just small enough for you to fit in and the floor is lined with a soft duvet. There is a pink handkerchief tied across the top, it reads, \"Ssecnirp\".") {
				it.namePrefix = "in a"
				it.meta["inside"] = true
				Exit(ExitType.out, `room:diningRoom`, "You see the main dining room of the house and recall many a happy day stretched out in the sun as it streamed in through the wide windows.")
					.oneTimeMsg("You crawl out of the cage. You arch your back, stretch out your front legs, and let out a large yawn - it was a good nights sleep!"), 
				photoOfEmma(),
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
					it.onUse = 	|Object lead, Player player -> Describe?| {
						desc := climbWashingLine(lead, player)
						if (desc != null) return desc
						sdes := spiderFight(player, "lead", 2, "You take the lead and whip the spider. It dodges the first one, but the second catches it in the eye. It winces and you whip it again, taking out another eye.\n\nIt growls like a wounded animal, but you're now at an advantage.")
						if (sdes != null) return sdes
						door := player.room.findObject("door")
						if (door != null)
							return door.onUse?.call(door, player)
						return null
					}
				},
				Object("mystery box", "A cardboard box filled with scrunched up newspaper, although your nose also detects traces of food.") {
					it.aliases = "box".split('|')
					it.verbs   = "lookin|look in|rummage|rummage in".split('|')
					it.onUse   = |Object me, Player player -> Describe?| {
						win := [1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0]
						idx := (Int) me.meta.getOrAdd("win") { -1 }
						idx ++
						if (idx >= win.size) idx = 0
						me.meta["win"] = idx
						
						desc  := "You thrust your head into the box and have a good snort around. You rustle around the newspaper to find "
						if (win[idx] == 0)
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
				Object("television", "The door guards the hallway. Its handle looms high overhead, out of your reach.") {
					it.aliases = "tv".split
					it.onHi5 = |Object tv, Player player->Describe?| {
						player.incHi5("TV")
						if (tv.meta["on"] == true) {
							tv.meta.remove("on")
							return Describe("You slap the power button once more and the TV flickers off.")
						}
						tv.meta["on"] = true
						return Describe("You high five the TV and slap the power button. The TV blinks, flashes, then tunes in.\n\nIt's a TV show about flying super heros, all dressed in capes and everything! If only Emma and Steve were here to watch it with you!")
					}
				},
			},

			Room("hallway", "You hear a door bell ring.") {
				it.meta["inside"] = true
				Exit(ExitType.east, `room:lounge`),
				Exit(ExitType.north, `room:frontLawn`)
					.block("It is closed.", "You move forward and bang your head on the door. It remains closed."),
				Object("front door", "It is the main door to the house. Its handle looms high overhead, out of your reach.") {
					it.aliases = "door".split
					it.openExit("lead", "north", openDoorDesc + ".. to reveal a burly Postman!") |door, exit, player| {
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
					it.openExit("lead", "south", openDoorDesc) |door, exit, player| {
						exit.block(
							"But it looks so cold and windy outside.", 
							"As soon as you step outside, the cold hits you. Brr! You dash back in side to the safety of the warmth.", 
							"Your coat keeps you warm."
						) { !player.isWearing("coat") }
					}
				},
				Object("door", "The door to the driveway outside. Its handle looms high overhead, out of your reach.") {
					it.openExit("lead", "north", openDoorDesc) |door, exit, player| {
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
							it.canPickUp = true
							it.canWear	 = true
							it.onWear	 = |->Describe| {
								if (player.meta["tooColdToMove"] == true) {
									player.canMove = true
									player.onMove = null
									player.meta.remove("tooColdToMove")
								}
								return Describe("You pull the coat on over your head and tie the velcro straps around your waist. Ahh, toasty warm!")
							}
							it.onDrop = |->Describe?| {
								// taking the coat off outside immobilises you
								if (player.room.meta["inside"] != true) {
									player.meta["tooColdToMove"] = true
									player.canMove = false
									player.onMove = |->Describe?| { Describe("Your mind lunges forward, but your body does not. It is so cold, you've frozen to the spot!") }
									return Describe("You take your coat off and immediately regret it as you start shivering. It's sooo cold out here!")
								}
								return null
							}
							it.onTakeOff = it.onDrop
						}
						player.room.objects.add(coat)
						oven.onLook = null
						return Describe("You open the washing machine door and pull out a clean and dry, pink dog coat.")
					}
					it.redirectOnUse(it.onLook)
				},
				Object("sack of peanuts", "A large 15Kg sack of peanuts. There's a note pinned to it that reads, \"Larry the Badger's favourite.\"") {
					it.aliases = "peanuts nuts".split
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("peanuts", "A small scoop of peanuts.") {
							it.aliases = "peanuts nuts".split
//							it.verbs = "throw scatter feed".split	// this is for eating!
							it.namePrefix = ""
							it.edible("Unable to contain your desires, you gobble down the nuts.")
							it.onDrop = |Object nuts->Describe?| {
								if (player.room.id == `room:outHouse`) {
									nuts.canDrop = false
									player.inventory.remove(nuts)
									return Describe("You place the peanuts back in the sack.")									
								}
								if (player.room.id == `room:lawn`) {
									nuts.canDrop = false
									player.inventory.remove(nuts)
									player.room.add(Object("squirrel", "\"Hi!\" says the squirrel standing proud. \"I'm NutSack! On account of my, um, sack of nuts here.\"\n\nIndeed, you can not argue. For his diminutive size, the squirrel does have an impressive sack of nuts.") {
										it.onHi5 = |Object squirrel->Describe?| {
											player.incHi5("NutSack")
											return Describe("You high five NutSack, and then wipe your hand as you're not quite sure where it's been.")
										}
									})
									return Describe("You scatter the peanuts, and as if by magic a squirrel appears and starts filling its face.")									
								}
								if (player.room.id == `room:backLawn`) {
									nuts.canDrop = false
									player.inventory.remove(nuts)
									if (player.room.has("badger")) {
										return Describe("Larry thanks you for the nuts and quickly gobbles them up!")
									} else {
										player.room.onEnter = |Room backLawn->Describe?| {
											times := (Int) backLawn.meta.get("onEnter.num", 0)
											backLawn.meta["onEnter.num"] = ++times
											if (times < 2)
												return Describe("Nope, the garden guest has still not arrived.")
											if (times == 2) {
												player.room.add(Object("Larry the Badger", "Larry is a large black and white striped mammal, the same size as yourself. He is rare to see and a sight to behold.") {
													it.namePrefix = ""
													it.aliases = "larry badger".split
													it.onHi5 = |Object larry->Describe?| {
														player.incHi5("Larry")
														return Describe("You raise your paw and exclaim, \"High Five!\" Larry raises his paw also and gives a little excited badger grunt. Paw on paw, you slap some skin. Yeah, garden buddies for life!")
													}
												})
												return Describe("You freeze. He's here! The majestic beast know as Larry the Badger is snuffling about on the lawn, hovering up peanuts as he goes!")
											}
											if (times < 5)
												return Describe("Larry the Badger is busy hovering up peanuts.")
											if (times == 5) {
												backLawn.meta.remove("onEnter.num")
												player.room.onEnter = null
												badger := backLawn.findObject("badger")
												backLawn.objects.remove(badger)
												return Describe("As you enter, Larry the Badger leaves in search of more food, wagging his stumpy tail as he goes.")
											}
											return null
										}
										return Describe("You pile the peanuts on a paving slab in the corner and wait for a special guest to arrive.")
									}
								}
								return null
							}
						})
						return Describe("Using a small plastic tray, you grab a scoop of peanuts.")

					}
					it.redirectOnUse(it.onPickUp)
				},
				Object("sack of bird seed", "A large 15Kg sack of bird seed. There's a note pinned to it that reads, \"If you feed them, they will come.\"") {
					it.aliases = "bird seed|birdseed|seed".split('|')
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("bird seed", "A small scoop of bird seed.") {
							it.aliases = "birdseed seed".split
//							it.verbs = "throw scatter feed".split	// this is for eating!
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
				Object("box of fish food", "A large biscuit tin full of fish food. There's a note pinned to it that reads, \"If you feed them, they will come.\"") {
					it.aliases = "fish food|fishfood|food".split('|')
					it.onPickUp = |Object tin, Player player -> Describe?| {
						player.inventory.add(Object("fish food", "A small scoop of fish food.") {
							it.aliases = "fishfood food".split
//							it.verbs = "throw scatter feed".split	// this is for eating!
							it.namePrefix = ""
							it.inedible("Out of curiosity you gobble up some fish food. But an instant rumbling in your belly makes you sick it all up again. You ponder if fish food is good for dogs?")
							it.onDrop = |Object food->Describe?| {
								if (player.room.id == `room:outHouse`) {
									food.canDrop = false
									player.inventory.remove(food)
									return Describe("You place the fish food back in the box.")									
								}
								if (player.room.id == `room:goldfishPond`) {
									food.canDrop = false
									player.inventory.remove(food)
									if (player.room.has("goldfish")) {
										return Describe("You scatter the food about the pond and the goldfish dart about, nibbling for nourishment.")									
									} else {
										player.room.add(Object("goldfish", "A plethora of gold, yellow, and mottled white gold fish.") {
											it.namePrefix = ""
										})
										return Describe("You scatter the food about the pond and then, out from behind rocks, weeds, and crevices, goldfish begin to appear!")									
									}
								}
								if (player.room.id == `room:koiPond`) {
									food.canDrop = false
									player.inventory.remove(food)
									if (player.room.has("koi carp")) {
										return Describe("You scatter the food about the pond and the koi largely ignore it, instead waiting for it to sink to the bottom before picking at it. It's not the feeding frenzy you were expecting!")									
									} else {
										player.room.add(Object("koi carp", "You see several orange, white, and gold mottled koi fish - although they keep themselves fairly well hidden at the bottom of the pond.") {
											it.namePrefix = ""
											it.aliases = "koi carp fish".split
										})
										return Describe("You scatter the food about the pond and then, from the murky depths below, several koi carp appear!")									
									}
								}
								return null
							}
						})
						return Describe("Using a small plastic tray, you grab a scoop of fish food.")
					}
					it.redirectOnUse(it.onPickUp)
				},
			},

			Room("front lawn", "The front lawn is an odd triangle shaped piece of land that adjoins the driveway. It is hemmed in by a thick hedge.\n\nThere's a bird table in the middle which suggests Emma feeds the birds here.") {
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
				Exit(ExitType.in, `room:garage`, "A small garage fronted with a large bright red, vertical lift, metal door.") {
					it.block("The door is closed.", "You sprint at the door and bounce off with a large clang. The door remains closed.")
				},

				Object("car", "A Golf 1.9 TDI. Colour, shark grey. The car is locked and all the doors are closed."),

				Object("garage door", "It is a large vertical lift, bright red, metal door.") {
					it.aliases = "door garage".split
					it.openExit("silver key", "in", "You use the key to unlock the door. The sprung hinge at the top lifts the door up and into the garage.") |Object door, Exit exit, Player player| {
						key := player.findObject("silver key")
						player.inventory.remove(key)
					}
				},
			},
			Room("garage", "A new paint job hides the drab looking pre-fabricated concrete walls. The garage is filled with boxes and bric-a-brac.") {
				Exit(ExitType.out, `room:driveway`),
				Object("harness", "A black and yellow walking harness adorned with the words, \"Dog's Trust\".") {
					it.canPickUp = true
					it.canWear = true
					it.onWear = |->Describe| { Describe("You slip the harness on over your coat and snap the buckles closed.") }
				},
				Object("mask and snorkel", "A well used, but perfectly adequate, mask and snorkel.") {
					it.aliases = "mask snorkel".split
					it.canPickUp = true
					it.canWear = true
					it.onWear = |->Describe| { Describe("You pull the mask on over your head and fix the snorkel in your mouth.") }
				},
				newSnack(),
			},

			Room("the avenue", "The Avenue, also known as The Ave.") {
				it.meta["noExits"] = true	// no entrance, no exits!
			},

			Room("patio", "Large paving slabs adorn the floor, lined with potted trees and shrubs.") {
				it.namePrefix = "on the"
				Exit(ExitType.north, `room:backPorch`, "A door leads into the back porch."),
				Exit(ExitType.south, `room:goldfishPond`, "A couple of stone steps lead up to the goldfish pond"),
				Object("expandable hosepipe", "A long expandable hosepipe with spray nozzle attachment.") {
					it.aliases = "hose|hosepipe|hose pipe".split('|')
					it.canPickUp = true
					it.onUse = |Object hosepipe, Player player -> Describe?| {
						sdes := spiderFight(player, "hosepipe", 3, "You pull the trigger on the nozzle and hose down the spider. The water jets pummel it into a corner.\n\nIt tries to fight its way back but its legs become heavy as its hairy legs soak up the water. Disorientated with water in its eyes the spider drags itself back and stands there, wobbling with uncertainty.")
						if (sdes != null) return sdes
						desc := climbWashingLine(hosepipe, player)
						if (desc != null) return desc
						if (player.room.has("trough of frog spawn")) {
							trough := player.room.findObject("trough of frog spawn")
							trough.meta["hydrated"] = true
							return Describe("You pull the trigger and fill the trough with fresh water. The frog spawn begins to swell and looks a lot more healthy and juicy.\n\nBut you notice the trough has no food for when the tadpoles hatch. You figure it's best to move them.")
						}
						return Describe("You pull the trigger on the nozzle and fire out soaking jets of water! It makes a mess, but not much else.")
					}
				}
			},

			Room("goldfish pond", "It is a shallow square pond full of weeds.") {
				it.namePrefix = "next to the"
				it.meta["hasSpawn"]		= false
				it.meta["hasTadpoles1"] = false
				it.meta["hasTadpoles2"] = false
				it.meta["hasFrogs"]		= false
				it.onLook  = |Room pond->Describe?| {
					if (pond.has("frogs"))
						return Describe("It is also full of frogs, swimming, croaking, and playing!")
					return null
				}
				it.onEnter = |Room pond, Player player->Describe?| {
					if (pond.meta["hasSpawn"]) {
						pond.meta["hasSpawn"]	  = false
						pond.meta["hasTadpoles1"] = true
						return Describe("You delight to see that, during your absence, the frog spawn has turned into little tadpoles! They're wriggling around, nibbling on the pond weed.")
					}
					if (pond.meta["hasTadpoles1"]) {
						pond.meta["hasTadpoles1"] = false
						pond.meta["hasTadpoles2"] = true
						return Describe("The little tadpoles have turned into big tadpoles! They're still wriggling around, nibbling on pond weed.")
					}
					if (pond.meta["hasTadpoles2"]) {
						pond.meta["hasTadpoles2"] = false
						pond.meta["hasFrogs"] = true
						return Describe("Oh wow, some of the tadpoles now have little legs! You're so excited! Now they're swimming around and sheltering under the pond weed.")
					}
					if (pond.meta["hasFrogs"]) {
						pond.meta["hasFrogs"] = false
						pond.add(Object("frogs", "A multitude of common frogs are frolicking in the pond.") {
							it.namePrefix = ""
							it.onHi5 = |Object frogs -> Describe?| {
								player.incHi5("frogs")
								return Describe("You scream, \"High five!\" and all the frogs line up in the pond with a little arm extended. You run along the side and high five them all. Yeah!")
							}
						})
						return Describe("You are surrounded by a cacophony of croaking. You look around to see a pond full of happy slimy frogs! They're all swimming around and climbing over each other.")
					}
					return null
				}
				Exit(ExitType.east, `room:koiPond`),
				Exit(ExitType.north, `room:patio`, "A couple of stone steps lead down to the patio."),
				Exit(ExitType.south, `room:vegetablePatch`),
			},

			Room("koi pond", "The koi pond is a deep picturesque garden pond with a slate surround, complete with a cascading waterfall feature in the corner.") {
				it.namePrefix = "next to the"
				Exit(ExitType.west, `room:goldfishPond`),
				Exit(ExitType.north, `room:backLawn`),
				Exit(ExitType.south, `room:lawn`),
			},

			Room("back lawn", "The back lawn is a patch of grass that backs up to the dining room window.\n\nIt is a popular feeding ground for birds and other animals as the adjoining hedgerow gives plenty of shelter.") {
				it.namePrefix = "on the"
				it.meta["isGarden"] = true
				Exit(ExitType.south, `room:koiPond`),
				Exit(ExitType.up, `room:washingLine`)
					.block("A tall cast iron pipe sunk deep in the ground leads up into the sky to support the washing line.", "You make like a squirrel and frantically paw, scrabble, and clamber at the washing line support. But as you slide back down the pipe you realise you're not a squirrel.", ""),
				Object("washing line", "A tall cast iron pipe sunk deep in the ground has a series of pullies at the top that holds up a make shift washing line. There must be quite a view from the top!") {
					it.aliases = "line".split
					it.verbs = "climb".split
					it.onUse = |Object washingLine, Player player -> Describe?| {
						desc := climbWashingLine(washingLine, player)
						if (desc != null) return desc
						return null
					}
				}
			},

			Room("lawn", "A featureless patch of grass in front of the summer house that's popular with the local avian wildlife, should there be enough food around.\n\nThe lawn also sports a lot of earth mounds and a couple of small holes.") {
				it.namePrefix = "on the"
				it.meta["isGarden"] = true
				it.onLeave = |Room lawn->Describe?| {
					if (lawn.has("mole")) {
						mole := lawn.findObject("mole")
						lawn.objects.remove(mole)
						return Describe("The mole up ends and burries away out of sight.")
					}
					return null
				}
				Exit(ExitType.north, `room:koiPond`),
				Exit(ExitType.west, `room:vegetablePatch`),
				Exit(ExitType.in, `room:summerHouse`, "A patchwork of rotting wood that once was decking leads up to a small decaying door.") {
					it.isBlocked	= true
					it.descBlocked	= "A sea of dusty cobwebs roll from the summer house door to the nether reaches of the back walls."
					it.onExit = |Exit exit, Player player -> Describe?| {
						if (!player.has("rhubarb"))
							return Describe("You disturb the sea of dusty cobwebs as you enter. Spiders scuttle out from all directions and then stop. They hunch down, waiting, staring. All eight of their eyes watching, anticipating your next movement. Which, unsurprisingly, is to leg it back out of the summer house!")
						exit.isBlocked = false
						exit.onExit = |->Describe?| { Describe("Without webs to trap and ensnare, the spiders remain in hiding.") }
						return Describe("Gripping the the rhubarb firmly between your teeth you fearlessly bound into the summer house. You swing your head from side to side and brandish the stalk like a crazed sword fighter. With the cobwebs now all but destroyed the spiders retreat into the dark recesses of the cabin.")
					}
				},
			},

			Room("summer house", "Constructed of rotting wood the summer house is a dark and foreboding death trap. Inside, amongst the muddy garden tools a hundred eyes shine back at you from within the dim light.") {
				Exit(ExitType.out, `room:lawn`),
				Object("bucket", "A plastic yellow bucket with a handle, useful for carrying.") {
					it.meta["hasSpawn"] = false
					it.canPickUp = true
					it.onLook = |Object bucket, Player player -> Describe?| {
						if (bucket.meta["hasSpawn"] == true)
							return Describe("It is half full of frog spawn.")
						return null
					}
					it.onUse = |Object bucket, Player player -> Describe?| {
						desc := climbWashingLine(bucket, player)
						if (desc != null) return desc
						sdes := spiderFight(player, "bucket", 1, "You swing the bucket but the spider catches it with a couple of its many legs and places it on its head, using it as an armoured helmet for protection.\n\nBut because it looks so funny, it dies a little inside.")
						if (sdes != null) return sdes
						if (player.room.has("trough of frog spawn")) {
							trough := player.room.findObject("trough of frog spawn")
							return trough.onPickUp(trough, player)
						}
						if (bucket.meta["hasSpawn"] == true)
							return bucket.onDrop(bucket, player)
						return null
					}
					it.onDrop = |Object bucket, Player player -> Describe?| {
						if (bucket.meta["hasSpawn"] == true && player.room.id == `room:koiPond`) {
							bucket.meta["hasSpawn"] = false
							return Describe("You tip the bucket of frog spawn into the koi pond. All of a sudden the koi dart up from the deep and initiate a feeding frenzy, gulping down the tasty treats.\n\nYou don't have to worry about that frog spawn anymore!")
						}
						if (bucket.meta["hasSpawn"] == true && player.room.id == `room:goldfishPond`) {
							bucket.meta["hasSpawn"] = false
							player.room.meta["hasSpawn"] = true
							return Describe("You tip the bucket of frog spawn into the goldfish pond where there are plenty of weeds for food. You hope that one day the spawn will hatch and turn into tadpoles, and then maybe even frogs!")
						}
						return null
					}
				},
				Object("spade", "A stout digging utensil.") {
					it.canPickUp = true
					it.verbs = "dig".split
					it.onUse = |Object spade, Player player -> Describe?| {
						if (player.room.id == `room:vegetablePatch`) {
							veg := newVeg()
							player.room.objects.add(veg)
							return Describe("You start digging over the vegetable patch with the spade until you discover a ${veg.name}!")
						}
						if (player.room.id == `room:lawn`) {
							if (player.room.has("mole")) {
								return Describe("You keep digging the lawn. The mole is not impressed. He can do it half the time you can.")
							}
							player.room.add(Object("mole", "A small creature with big claws. His eyesight is very poor due to having tiny peepers.") {
								it.onHi5 = |Object larry->Describe?| {
									player.incHi5("mole")
									return Describe("You shout \"High five!\" and raise your paw. Moley does the same but, on account of him having poor eyesight, he slaps a mound of earth instead.\n\nIntent is everything so you figure it still counts!")
								}
							})
							desc := Describe("You start digging up the lawn making some of the small holes even bigger. And then, out from one pops a mole!")
							if (!player.hasOpenedParcel("mole"))
								desc += "\"Larry!?\" shouts the mole. \"Is that you!? My wife says you've been stealing her knickers again!\""
							return desc
						}
						desc := spiderFight(player, "spade", 5, "You swing the spade and watch it slam the spider full in the face. It staggers back and trips up as three of its legs give way. You wang the spade over your head and bring it down on the spider's with a satisfying 'Thwack!'.")
						return desc
					}
				},
				newSnack(),
			},

			Room("vegetable patch", "An old vegetable patch that's now mostly covered in wild strawberry creepers. In the corner sits a huge crown of rhubarb.") {
				Exit(ExitType.east,  `room:lawn`),
				Exit(ExitType.north, `room:goldfishPond`),
				Exit(ExitType.in,	 `room:greenhouse`, "As you peer in through the murky windows, all you can make out is what appears to be rugby ball with hairy legs!?"),
				Object("rhubarb", "The rhubarb has eagerly grown into huge monster of a plant as if it were auditioning for a role in The Little Shop of Horrors! Its size means it gives a seemingly endless supply of stalks.") {
					it.namePrefix = ""
					it.aliases = "stick|stalk|stalk of rhubarb|stick of rhubarb".split('|')
					it.onPickUp = |Object food, Player player -> Describe?| {
						player.inventory.add(Object("stalk of rhubarb", "A large sturdy red stick of rhubarb. Good for whacking things with!") {
							it.aliases = "rhubarb stick stalk".split
							it.canPickUp = true
							it.verbs = verbs.rw.addAll("eat chomp gnaw chew trough swallow gulp scoff".split)
							it.onUse = |Object rhubarb -> Describe?| {
								desc := spiderFight(player, "rhubarb", -1, "You go to jab the spider with the sturdy stick of rhubarb, but the spider is faster. It grabs the rhubarb with its jaws, chews it up, and spits it out.\n\nRejuvenated with rhubarb juice, the spider is healthy, fighting fit, and ready for more!")
								if (desc != null)  {
									player.inventory.remove(rhubarb)
									player.room.objects.remove(rhubarb)
									return desc 
								}
								return Object.edibleFn("Nibbling on the bulbous red end, you decide it's almost as tasty as rawhide.")(rhubarb, player)
							}
							it.onDrop = |Object rhubarb->Describe?| {
								if (player.room.id == `room:vegetablePatch`) {
									rhubarb.canDrop = false
									player.inventory.remove(rhubarb)
									return Describe("You drop the rhubarb back in the patch.")
								}
								return null
							}
						})
						return Describe("You jam your head into the plant and snap off a juicy stalk.")
					}
					it.redirectOnUse(it.onPickUp)
				},
			},

			Room("greenhouse", "An old dis-used greenhouse that's used more for storage than growing things.") {
				it.onEnter = |Room gh, Player player -> Describe?| {
					if (!gh.has("spider")) return null
					spider := gh.findObject("spider")
					health := spider.meta["health"] as Int
					desc := Describe("You've disturbed the lair of a GIANT HOUSE SPIDER!")
					desc += "The spider leaps out from the corner and crouches down in front of you. Its long hairy legs stretch from one side of the greenhouse to the other. All eight eyes watch you with a malevolent intelligence. It must be destroyed."
					desc += "Spider health: ${health}/10"
					return desc
				}
				it.onLeave = |Room gh, Player player -> Describe?| {
					if (!gh.has("spider")) return null
					spider := gh.findObject("spider")
					health := spider.meta["health"] as Int
					desc := Describe("You bolt out of the greenhouse with your heart pumping and your tail between your legs.")
					
					return desc
				}
				Exit(ExitType.out, `room:vegetablePatch`),
				Object("giant spider", "A colossal hairy house spider, bigger than your head!") {
					it.aliases = "spider monster".split
					it.meta["health"] = 10
					it.onHi5 = |Object spider, Player player->Describe?| {
						player.incHi5("spider")
						return spiderFight(player, "hi5", 3, "You raise your paw and slog the beast with a right hook. The spider rolls with the blow before scrabbling back to its feet. It shakes its head and leans at you, menacingly.")
					}
					it.onUse = |Object spider, Player player->Describe?| {
						spiderFight(player, "spider", 1, "You race in and attack the spider, drawing first blood with a savage bite to a leg. The spider kicks you off and now looks meaner and more determined than ever.")
					}
					it.onPickUp = |Object spider, Player player->Describe?| {
						spiderFight(player, "spiderPickUp", 1, "You pick up the spider and hurl it against the far wall. The spider springs back to it's feet, it is bruised but down yet.")
					}
					it.verbs = "attack fight punch kick bite".split
				},
			},
			
			Room("birds nest", "You are high in the trees with no obvious route back. The garden and house is sprawled out below you, and you see the car in the driveway. Wait! Was that movement you saw in the car just now?") {
				it.namePrefix = "in a large"
				Object("large egg", "A freshly laid bird egg.") {
					it.aliases = "egg".split
					it.edible("You gnaw a hole in the top and suck the contents out. A bit runny, but not bad. You use your paw to wipe your mouth and toss the empty husk over the side.")
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
					it.onUse = |Object me, Player player -> Describe?| {
						player.transportTo(`room:lawn`)
						return Describe("You stare back at the fluffy squeaky thing in front of you. Your eyes widen, you can't contain yourself! Must chase!\n\nThe squirrel senses danger and darts off the roof, climbing down a wooden beam holding up the roof. Without a thought you do the same.\n\nBefore you know it, you're on the lawn. The squirrel has disappeared and you're left wondering how you got there!")
					}
					it.onHi5 = onUse
				},
				Exit(ExitType.down, `room:lawn`, "You can see the garden lawn below, but it's way to far to jump!") {
					it.block("", "You teeter to the edge but crawl back when vertigo sets in!")
				},
			},

			Room("washing line", "Yikes! The ground looks much further away than you expected. You cling to the top of the pipe and look around at the garden and all the animals. Looking over the garage you see the car. The sun-roof is open and there appears to be a person inside.") {
				it.namePrefix = "on the"
				Exit(ExitType.down, `room:backLawn`, "You see the back lawn, a long way down.") {
					it.onExit = msgFn("You make like a squirrel and scamper down the pipe head first to the safety of Mother Earth.")
				},
				Exit(ExitType.north, `room:garageRoof`, "A vast expanse of thin air separates you and the corrugated metal roof of the garage.") {
					it.onExit = |Exit exit, Player player -> Describe?| {
						if (!player.isWearing("coat")) {
							exit.isBlocked = true
							return Describe("You have a plan! But it requires your coat...")
						}
						exit.isBlocked = false
						return Describe("All that time watching superhero films on the couch with Emma and Steve seemed to have paid off, because you have a plan! It's quite an easy one too.\n\nYou check your coat. It's loose and flappy enough to be considered a cape. And as every superdog knows, if you have a cape... you can fly!\n\nYou tense all the muscles in your legs then release an enormous burst of energy that sends you hurtling through the sky. But then gravity starts to take hold.\n\nYou begin to fall and the garage roof approaches fast. Your outstretched arms just manage to grab hold, quickly followed by a frantic scrabble of the hind legs.")
					}
				},
			},

			Room("garage roof", "The new roof is of polished corrugated steel. With the garden behind you, you peer over the north edge to see the driveway and the car. Ah, the car! That gateway to wondrous walks.\n\nStaring through the open sun-roof you see... Emma! Your heart quickens, there is no time to waste!") {
				it.namePrefix = "on the"
				Exit(ExitType.north, `room:car`, "The car and the open sun-roof is but a short jump away. You're sure you can make it!") {
					it.onExit = |Exit exit, Player player->Describe?| {
						buzzardAvoided := player.room.meta["buzzard.avoided"] == true
						player.room.meta.remove("buzzard.avoided")
						if (buzzardAvoided) {
							exit.isBlocked = false
							return Describe("Heart racing, you make one final heroic leap towards the car and the open sun-roof. You tuck your head and legs in, travel through the opening, and land on the passenger seat.")
						}
							
						desc := Describe("A loud screech once again pierces the air and you freeze with fear.\n\nFrom behind the buzzard swoops in and snatches you up in huge claws. You rise into the air as the powerful wings beat the air around.") 
						if (player.hasSmallBelly) {
							exit.isBlocked = true
							player.transportTo(`room:birdsNest`)
							desc += "Before you know it, you're high above the garden looking down on the ponds below. The buzzard takes you into the trees, drops you its nest, and flies away.\n\nYou berate yourself for being so close to your goal, and yet so careless. But what could you have done differently?"
						} else { 
							exit.isBlocked = true
							player.transportTo(`room:driveway`)
							desc += "The buzzard's eyes were larger than its stomach and it beats the air furiously as it struggles with your weight. You start to loose altitude, the buzzard finally gives up its breakfast and lets you go.\n\nYou wriggle in mid air to see where you're falling, and it appears to be towards the car! But alas, you bounce off the bonnet and land heavily on the floor. You curse yourself for being so careless, but what could you have done differently?"
						}

						return desc
					}
				},
			},

			Room("car", "\"Oh boy, oh boy, it's Emma the feeder, Emma the walker! Right here, next to me!\" You're so excited!\n\nYou run around on the seat, jump up at her, and lick her face. \"Oh there you are!\" says Emma, pushing you back down on the seat. \"I've been wondering where you got to, I've been waiting to take you out on a walk to the waterfalls, you'd like that wouldn't you!?\"\n\n\"And good, I see you're already dressed and ready to go out! Hop on the back seat then, and we'll go!\"\n\nWow, this all sounds fantastic!") {
				// oh, you're all dressed ready to go out!
				Exit(ExitType.north, `room:backSeatOfTheCar`, "The back seat of the car. It is covered in a dog blanket to keep mud and hair off the seat."),
				Object("Emma", "A beautiful Welsh woman dressed in wellies and a rain jacket.") {
					it.namePrefix = ""
					it.onHi5 = |Object emma, Player player -> Describe| {
						snacksGiven := (emma.meta["snacksGiven"] as Int) ?: 0
						if (snacksGiven >= 5)
							return Describe("Aww, Emma is all out of dog treats.")
						emma.meta["snacksGiven"] = snacksGiven + 1
						player.room.objects.add(newSnack())
						player.incHi5("Emma")
						return Describe("You high five Emma and Emma high fives back. It's what best buddies do! She digs around in her coat pocket and fishes out a dog treat.")
					}
				},
			},

			Room("back seat of the car", "You're so happy you've found Emma, all the morning's adventures were worth it! But the day is not over yet, and there may be more adventures to come.\n\nYou look eagerly out of the window as Emma starts the engine. This is going to be a great day!\n\n  - THE END -\n\n") {
				meta["noExits"] = true
				it.onEnter = |Room room, Player player->Describe?| {
					player.achievement("Found Emma")
					player.endThis
					return null
				}
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
