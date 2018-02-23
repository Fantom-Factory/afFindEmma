
@Serializable
class Exit : Describe {
	Uri				id
	Str				name
	Str				desc
	ExitType		type
	Bool			isVisible
	Str?			blockedDesc
	Uri				exitToId

	|Player, Room, Exit -> Describe?|?	onBlock
	|Player, Room, Exit -> Describe?|?	onExit

	
	new make(|This| f) { f(this) }
	
	new makeName(ExitType type, Uri exitToId) {
		this.type		= type
		this.exitToId	= exitToId

		this.desc		= ""
		this.name		= type.name
		this.id			= `exit:$name.fromDisplayName`
		this.isVisible	= true
	}

	Bool isBlocked() {
		blockedDesc != null
	}
	
	static |Player, Room, Exit->Describe?| oneTimeMsg(Str msg) {
		|Player player, Room room, Exit exit -> Describe?| {
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
	
	override Str toStr() { id.toStr }
}

enum class ExitType {
	in, out,
	up, down,
	north, south, east, west;
}
