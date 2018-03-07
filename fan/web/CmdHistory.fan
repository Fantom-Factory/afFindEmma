
@Serializable
@Js class CmdHistory {
	
			DateTime?	savedAt
	private Str[]		history	:= Str[,]
	
	new make(|This|? f := null) { f?.call(this) }
	
	Void add(Str cmd) {
		history.add(cmd)
	}
	
	static CmdHistory load(Str his) {
		his.toBuf.readObj
	}
	
	Str save() {
		savedAt = DateTime.now(1sec)
		buf := StrBuf()
		buf.out.writeObj(this)
		return buf.toStr
	}
	
	Int size() {
		this.history.size
	}
	
	Void each(|Str| fn) {
		history.each(fn)
	}
}
