
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
		if (history.isEmpty) return ""
		his := history[index]
		index = index.decrement.max(0)
		return his
	}
	
	Str down() {
		if (history.isEmpty) return ""
		index = index.increment.min(history.size-1)
		return history[index]
	}
	
	Void each(Int num, |Str| fn) {
		if (history.size > num) {
			fn("... ${history.size - num} more ...")
			history.eachRange(-num..-1, fn)
		} else
			history.each(fn)
	}
	
	Int size() {
		history.size
	}
	
	Void clear() {
		history.clear
		index = 0
	}
}
