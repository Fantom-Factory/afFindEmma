
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
	
	Str solution() {
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
 		
 	// the mole
 		get photo
 		south
 		south
 		drop photo
 		west
 		get rhubarb
 		east
 		in
 		eat rhubarb
 		get spade
 		out
 		use spade
 		rollover
 		hi5 mole
 		show photo
 		drop knickers
 		open parcel

 	// eight legged freak
 		west
 		in
 		attack spider
 		rollover
 		hi5 spider
 		use spade

 	// frog spawn
 		drop spade
 		out
 		north
 		north
 		get hose
 		south
 		south
 		in
 		drop hose
 		out
 		east
 		in
 		get bucket
 		out
 		west
 		in
 		use hose
 		use bucket
 		out
 		north
 		drop bucket
 		east
 		south
 		get photo
 		west
 		north
 		north
 		south
 		north
 		south
 		north
 		south
 		show photo
 		open present	// parcel frogs
 		use bubble bath
 		hi5 frogs
 
 	// squirrel
 		drop photo
 		north
 		north
 		west
 		get nuts
 		east
 		south
 		south
 		south
 		east
 		drop nuts
 		rollover
 		hi5 squirrel
 		north
 		west
 		get photo
 		south
 		east
 		show photo
 		open parcel
 		drink tea
 		drop photo
 
 		west
 		north
 		
 	// finale from frog pond
 		get bucket
 		east
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
 		south
 		in
 		get hosepipe
 		out
 		north
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
