
@Serializable
class Exit : Describe {
	Uri				id
	Str				desc
	Str?			descBlocked
	ExitType		type
	Uri				exitToId
	Bool			isVisible
	Bool			isBlocked

	|Exit, Player -> Describe?|?	onExit

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
		
		if (isBlocked && descBlocked != null)
			describe += " " + descBlocked
		
		if (!describe.endsWith("\n")) describe = describe + "\n"
		return describe
	}
	
	internal Bool matches(Str str) {
		type == ExitType(str, false)
	}

	override Str toStr() { id.toStr }

	Void oneTimeMsg(Str msg) {
		onExit = oneTimeMsgFn(msg)
	}
	
	Void block(Str msg, Str blockedMsg) {
		isBlocked	= true
		onExit  	= blockedMsgFn(msg)
		descBlocked	= blockedMsg
	}
	
	static |Exit, Player->Describe?| oneTimeMsgFn(Str msg) {
		|Exit exit, Player player-> Describe?| {
			exit.onExit = null
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
