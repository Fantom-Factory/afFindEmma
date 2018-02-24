
@Serializable
class Object : Describe {
	Uri			id
	Str			name
	Str			desc
	Bool		canPickUp
	Bool		canDrop
	Bool		canUse
	Str[]		aliases
	Str[]		aliasesLower

	|Object, Player -> Describe?|?	onPickUp
	|Object, Player -> Describe?|?	onDrop
	|Object, Player -> Describe?|?	onUse
	
	private new make(|This| f) { f(this) }

	new makeName(Str name, Str desc, |This|? f) {
		this.id			= `obj:${name.fromDisplayName}`
		this.name		= name
		this.desc		= desc
		this.canPickUp	= true
		this.canDrop	= true
		this.canUse		= true
		this.aliases	= Str#.emptyList
		
		f?.call(this)
		
		this.aliasesLower	= this.aliases.map { it.lower }
	}
	
	override Str describe() {
		describe := desc
		if (!describe.endsWith("\n")) describe = describe + "\n"
		return describe
	}
	
	internal Bool matches(Str str) {
		name.lower == str || id.path.last == str || aliasesLower.contains(str)
	}
	
	override Str toStr() { id.toStr }
}
