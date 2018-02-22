
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
	
	override Str describe() {
		desc
	}
	
	override Str toStr() { id.toStr }
}

enum class ExitType {
	in, out,
	up, down,
	north, south, east, west;
}
