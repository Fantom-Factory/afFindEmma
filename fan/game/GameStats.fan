
@Js class GameStats {
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

	Describe? incMoves() {
		noOfMoves++
		legWork++
		if (legWork >= 3) {
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
		str.add("Belly size ......... (" + ("X" * bellySize) + ")\n")
		return str.toStr
	}
	
	override Str toStr() { print }
}
