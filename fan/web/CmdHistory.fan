
@Serializable
@Js class CmdHistory {
			Version?	version
			DateTime?	savedAt
			Duration?	timePlayed
	private Str[]		history	:= Str[,]
	
	new make(|This|? f := null) { f?.call(this) }
	
	Void add(Str cmd) {
		history.add(cmd)
	}
	
	static CmdHistory load(Str his) {
		his.toBuf.readObj
	}
	
	Str savedAtStr() {
		savedAt.toLocale("D MMM YYYY, hh:mm").justr(18)
	}

	Str save(Duration gameTime) {
		version = typeof.pod.version
		savedAt = DateTime.now(1sec)
		timePlayed = gameTime
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
