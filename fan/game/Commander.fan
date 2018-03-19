
@Js mixin Commander {
	abstract Game?		game
	abstract Player?	player
	abstract Syntax?	syntax

	Bool executeCmd(Str cmdStr) {
		cmdStr = cmdStr.trim.lower
		if (cmdStr.startsWith("//") || cmdStr.trim.isEmpty) return false
		ds := cmdStr.index("//")
		if (ds != null) cmdStr = cmdStr[0..<ds].trim
	
		cmd := syntax.compile(player, cmdStr)
		old := player.room
		obj := player.room.objects.dup
		inv := player.inventory.dup
		clo := player.clothes.dup
		des := cmd?.execute(player)
		if (des != null)
			log(des)
	
		if (cmd == null)
			log("I do not understand.")
	
		if (player.room != old) {
			log(player.look)

		} else {
			// if we tried to move but were blocked, restate which room we're in
			if (cmd?.method == Player#move)
				log(player.room.lookName)
			
			wasPickUpCmd	:= (player.room.objects.size == obj.size - 1) && (player.inventory.size == inv.size + 1)
			wasDropCmd		:= (player.room.objects.size == obj.size + 1) && (player.inventory.size == inv.size - 1)
			wasWearCmd		:= (player.room.objects.size == obj.size - 1) && (player.clothes  .size == clo.size + 1)
			wasTakeOffCmd	:= (player.room.objects.size == obj.size + 1) && (player.clothes  .size == clo.size - 1)
			
			// if we didn't move but an object has (dis)appeared, then list it
			if (player.room.objects != obj && !wasPickUpCmd && !wasDropCmd && !wasWearCmd && !wasTakeOffCmd)
				// suppress basic uneventful cmds because: "You drop a spade; You see a spade" is a bit much!
				log(player.room.lookObjects)

			// if we didn't move but an object has (dis)appeared, then list it
			if (player.inventory != inv && !wasPickUpCmd && !wasDropCmd)
				log(player.lookInventory)

			// if we didn't move but an object has (dis)appeared, then list it
			if (player.clothes != clo && !wasWearCmd && !wasTakeOffCmd)
				log(player.lookClothes)
		}

		return cmd != null
	}
	
	Void startGame() {
		game	= Game.load
		player	= game.player
		syntax	= Syntax()
		log(game.start)
	}
	
	Str cheat() {
"
 		get photo		// start
 		out
 		drop photo
 		get lead
 		north
 		open door
 		west
 		open door
 		rollover
 		eat snack
 		hi5 postman
 		rip open parcel
 		wear boots
 		east
 		hi5 tv
 		south
 		west
 		open oven
 		eat cake
 		open door
 		west
 		open door
 		open door
 		drop lead
 		west
 		open washing machine
 		wear coat
 		
 	// goldfish
 		get fishfood
 		east
 		south
 		south
 		drop fishfood
 		north
 		north
 		east
 		east
 		get photo
 		west
 		west
 		south
 		south
 		show photo
 		open parcel		// parcel goldfish
 		drop photo
 		north
 		north
 		west
 		
 	// birds
 		get seed
 		east
 		north
 		east
 		drop seed
 		west
 		south
 		west
 		get seed
 		east
 		south
 		south
 		east
 		north
 		drop seed
 		south
 		west
 		get photo
 		east
 		north
 		show photo
 		open parcel		// parcel birds
 		south
 		drop photo		// photo by koi
 		west
 		north
 		north
 		west
 		get seed
 		east
 		south
 		south
 		east
 		south

 	// buzzard
 		drop seed
 		eat egg
 		out
 		get key
 		up
 		down
 		follow squirrel
 		west
 		north
 		north
 		north
 		north
 		open garage
 		in
 		wear harness

 	// koi carp
 		wear snorkel
 		out
 		south
 		west
 		get fishfood
 		east
 		south
 		south
 		east
 		drop fishfood
 		show photo
 		open parcel		// parcel koi
 		hi5 bubbles

 	// larry the badger
 		west
 		north
 		north
 		west
 		get peanuts
 		east
 		south
 		south
 		east
 		north
 		drop nuts
 		south
 		get photo
 		north
 		drop photo
 		south
 		north
 		rollover
 		hi5 larry
 		show photo
 		open parcel		// parcel larry
 		wear underwear
 		
 		south
 		south
 		west
 		
 	// finale from veg patch
 		get rhubarb
 		east
 		in
 		eat rhubarb
 		get bucket
 		out
 		north
 		north
 		drop bucket
 		south
 		west
 		north
 		north
 		get lead
 		south
 		south
 		east
 		north
 		drop lead
 		south
 		west
 		north
 		get hosepipe
 		south
 		east
 		north
 		use washing line
 		use hosepipe
 		north
 		rollover
 		north
 		hi5 emma
 		north
 "}
	
	abstract Void log(Obj? obj)
}
