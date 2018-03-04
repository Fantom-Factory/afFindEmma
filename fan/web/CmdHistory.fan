
@Js class CmdHistory {
	
	private Int		index	:= 0
			Str[]	history	:= Str[,]
	
	Void add(Str cmd) {
		history.add(cmd)
		if (history.size > 15)
			history.removeAt(0)
		index = history.size-1
	}
	
	Void reset() {
		index = history.size-1
	}
	
	Str up() {
		his := history[index]
		index = index.decrement.max(0)
		return his
	}
	
	Str down() {
		index = index.increment.min(history.size-1)
		return history[index]
	}
}
