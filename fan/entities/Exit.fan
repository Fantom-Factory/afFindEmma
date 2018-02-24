
@Serializable
class Exit : Describe {
	Uri				id
	Str				name
	Str				desc
	ExitType		type
	Bool			isVisible
	Str?			blockedDesc
	Uri				exitToId

	|Exit, Player -> Describe?|?	onBlock
	|Exit, Player -> Describe?|?	onExit

	private new make(|This| f) { f(this) }
	
	new makeName(ExitType type, Uri exitToId, Str desc := "") {
		this.type		= type
		this.exitToId	= exitToId

		this.desc		= desc
		this.name		= type.name
		this.id			= `exit:$name.fromDisplayName`
		this.isVisible	= true
	}

	Bool isBlocked() {
		blockedDesc != null
	}
	
	static |Exit, Player->Describe?| oneTimeMsg(Str msg) {
		|Exit exit, Player player-> Describe?| {
			exit.onExit = null
			return Describe(msg)
		}
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
}

enum class ExitType {
	in, out,
	up, down,
	north, south, east, west;
}
