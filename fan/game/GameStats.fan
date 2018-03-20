
@Js class GameStats {
	Duration	startTime	:= startTime = Duration.now
	Duration?	timePlayed
	Int			noOfCmds		{ private set }
	Int			noOfMoves 		{ private set }
	Int			noOfSnacksEaten { private set }
	Int			bellySize := 5	{ private set }
	private Int	legWork
	private Str[]	parcels		:= Str[,]
	private Str[]	hi5s		:= Str[,]
	
	
	// TODO have a list of Game durations to allow pausing / saving
	
	Duration gameTime() {
		d := Duration.now - startTime
		if (timePlayed != null)
			d += timePlayed
		return d
	}
	
	Void hi5(Str what) {
		if (!hi5s.contains(what))
			hi5s.add(what)
	}
	
	Bool hasOpenedParcel(Str name) {
		parcels.contains(name)
	}
	
	Void openParcel(Str name) {
		if (!hasOpenedParcel(name))
			parcels.add(name)
	}

	Void incCmds() {
		noOfCmds++
	}

	Describe? incMoves() {
		noOfMoves++
		legWork++
		if (legWork >= 4) {
			legWork = 0
			return decBellySize
		}
		return null
	}

	Describe? incSnacks() {
		noOfSnacksEaten++
		return incBellySize
	}

	Describe? incBellySize() {
		oldBelly := bellySize
		bellySize = bellySize.increment.min(9)
		return oldBelly != bellySize || bellySize == 9
			? Describe([
				null,				// 0
				"Food, at last!",	// 1
				"Hunger wanes.",	// 2
				null,				// 3
				null,				// 4
				null,				// 5
				null,				// 6
				"You look a little tubby.",	// 7
				"\"Urgh. I think I ate too much.\"",	// 8
				"\"Oh my God, my belly is sooo full I think I'm gonna die!\"",	// 9
			][bellySize])
			: null
	}

	Describe? decBellySize() {
		oldBelly := bellySize
		bellySize = bellySize.decrement.max(0)
		return oldBelly != bellySize || bellySize == 0
			? Describe([
				"\"Oh my God, I'm sooo hungry!\"",	// 0
				"Argh, hunger pains!",	// 1
				"Your tummy grumbles.",	// 2
				null,				// 3
				null,				// 4
				null,				// 5
				null,				// 6
				"You're looking trim!.",	// 7
				"Phew, your belly is not quite so full anymore.",	// 8
				null,	// 9
			][bellySize])
			: null
	}
	
	Str print() {
		str := StrBuf()
		str.add("Time played ........ ${DurationLocale.approx(gameTime)}\n")
		str.add("Commands entered ... ${noOfCmds}\n")
		str.add("Moves made ......... ${noOfMoves}\n")
		str.add("Snacks eaten ....... ${noOfSnacksEaten}\n")
		str.add("Belly size ......... ${bellySize}/9 (" + ("X" * bellySize) + ")\n")
		str.add("High fives given ... ${hi5s.size}/7" + (hi5s.isEmpty ? "" : (" - " + hi5s.join(", "))) + "\n")
		str.add("Presents opened..... ${parcels.size}/6" + (parcels.isEmpty ? "" : (" - " + parcels.join(", "))) + "\n")
		return str.toStr
	}
	
	override Str toStr() { print }
}
