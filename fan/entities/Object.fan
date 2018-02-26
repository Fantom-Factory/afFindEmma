
@Serializable
class Object : Describe {
	Uri			id
	Str			name
	Str			desc
	Bool		canPickUp
	Bool		canDrop
//	Bool		canUse		// this makes no sense as it is queried *after* onUse() is called! There is no default use action.
	Str[]		aliases
	Str[]		aliasesLower
	Str[]		verbs
	Str[]		verbsLower

	|Object, Player -> Describe?|?	onPickUp
	|Object, Player -> Describe?|?	onDrop

	|Object, Object?, Player -> Describe?|?	onUse
	
	private new make(|This| f) { f(this) }

	new makeName(Str name, Str desc, |This|? f) {
		this.id			= `obj:${name.fromDisplayName}`
		this.name		= name
		this.desc		= desc
		this.canPickUp	= true
		this.canDrop	= true
//		this.canUse		= true
		this.aliases	= Str#.emptyList
		this.verbs		= Str#.emptyList
		
		f?.call(this)
		
		this.aliasesLower	= this.aliases.map { it.lower }
		this.verbsLower		= this.verbs  .map { it.lower }
	}
	
	override Str describe() {
		describe := desc
		if (!describe.endsWith("\n")) describe = describe + "\n"
		return describe
	}
	
	internal Str fullName() {
		"a ${name}"
	}
	
	internal Bool matches(Str str) {
		name.lower == str || id.path.last == str || aliasesLower.contains(str)
	}

	internal Str? startsWith(Str str) {
		if (str.startsWith(name.lower))
			return name
		if (str.startsWith(id.path.last))
			return id.path.last
		return aliasesLower.find { str.startsWith(it) }
	}
	
	override Str toStr() { id.toStr }
	
	Void openExit(Str objStr, Str exitStr, Str desc, Str? newExitDesc := null) {
		canPickUp	= false
		canDrop		= false
		onUse		= openExitFn(objStr, exitStr, desc, newExitDesc)
	}
	
	static |Object, Object?, Player->Describe?| openExitFn(Str objStr, Str exitStr, Str desc, Str? newExitDesc) {
		|Object door, Object? obj, Player player -> Describe?| {
			if (obj != null && obj.matches(objStr)) {
				exit := player.room.findExit(exitStr)
				exit.isBlocked = false
				if (newExitDesc != null)
					exit.desc = newExitDesc
				player.room.objects.remove(door)
				return Describe(desc)
			}
			return null
		}		
	}
}
