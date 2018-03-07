
@Js class PromptHistory {
	
	private Int		index	:= 0
	private	Str[]	history	:= Str[,]
	
	Void add(Str cmd) {
		history.add(cmd)
		if (history.size > 100)
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
	
	Void each(Int num, |Str, Int| fn) {
		if (history.size > num) {
			fn("...", 0)
			history.eachRange(-num..-1, fn)
		} else
			history.each(fn)
	}
}
