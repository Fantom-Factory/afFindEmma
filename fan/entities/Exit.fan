
@Serializable
class Exit : Describe {
	Uri				id
	Str				desc
	ExitType		type
	Uri				exitToId
	Bool			isVisible
	Bool			isBlocked

	|Exit, Player -> Describe?|?	onMove

	private new make(|This| f) { f(this) }
	
	new makeName(ExitType type, Uri exitToId, Str desc := "", |This|? f := null) {
		this.type		= type
		this.exitToId	= exitToId
		this.desc		= desc
		this.id			= `exit:$type.name.fromDisplayName`
		this.isVisible	= true
		this.isBlocked	= false

		f?.call(this)
	}

	override Str describe() {
		describe := desc.isEmpty
			? "You see nothing special.\n"
			: desc
		if (!describe.endsWith("\n")) describe = describe + "\n"
		return describe
	}
	
	internal Bool matches(Str str) {
		type == ExitType(str, false)
	}

	override Str toStr() { id.toStr }

	Void oneTimeMsg(Str msg) {
		onMove = oneTimeMsgFn(msg)
	}
	
	Void block(Str msg) {
		isBlocked	= true
		onMove  	= blockedMsgFn(msg)
	}
	
	static |Exit, Player->Describe?| oneTimeMsgFn(Str msg) {
		|Exit exit, Player player-> Describe?| {
			exit.onMove = null
			return Describe(msg)
		}
	}
	
	static |Exit, Player->Describe?| blockedMsgFn(Str msg) {
		|Exit exit, Player player-> Describe?| {
			exit.isBlocked ? Describe(msg) : null
		}
	}
}

enum class ExitType {
	in, out,
	up, down,
	north, south, east, west;
}
