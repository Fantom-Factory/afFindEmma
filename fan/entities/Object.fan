
@Serializable
class Object : Describe {
	const	Uri			id
	const	Str			name
			Str			desc
			Bool		canPickUp
			Bool		canDrop
			Bool		canWear
			Bool		canTakeOff
//			Bool		canUse		// this makes no sense as it is queried *after* onUse() is called! There is no default use action.
//			Bool		canHi5		// as above - not needed if there is no default action
			Str[]		aliases
			Str[]		verbs

	|Object, Player -> Describe?|?	onPickUp
	|Object, Player -> Describe?|?	onDrop
	|Object, Player -> Describe?|?	onWear
	|Object, Player -> Describe?|?	onTakeOff
	|Object, Player -> Describe?|?	onHi5
	|Object, Object?, Player -> Describe?|?	onUse
	
	Str:Obj?	data		:= Str:Obj?[:]

	private new make(|This| f) { f(this) }

	new makeName(Str name, Str desc, |This|? f := null) {
		this.id			= `obj:${name.fromDisplayName}`
		this.name		= name
		this.desc		= desc
		this.canPickUp	= true
		this.canDrop	= true
//		this.canUse		= true
		this.canWear	= false
		this.canTakeOff	= true
		this.aliases	= Str#.emptyList
		this.verbs		= Str#.emptyList	// "use" added to verbs lower
		
		f?.call(this)
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
	
	private once Str[] aliasesLower() {
		// do the lowering here, so we don't have to set aliases in the ctor
		aliases.map { it.lower }
	}
	
	internal once Str[] verbsLower() {
		// do the lowering here, so we don't have to set verbs in the ctor
		["use"].addAll(verbs.map { it.lower })
	}
	
	Void openExit(Str objStr, Str exitStr, Str desc, |Object, Object?, Exit, Player|? onOpen := null) {
		canPickUp	= false
		canDrop		= false
		onUse		= openExitFn(objStr, exitStr, desc, onOpen)
	}
	
	static |Object, Object?, Player->Describe?| openExitFn(Str objStr, Str exitStr, Str desc, |Object, Object?, Exit, Player|? onOpen := null) {
		|Object door, Object? obj, Player player -> Describe?| {
			if (obj != null && obj.matches(objStr)) {
				exit := player.room.findExit(exitStr)
				exit.isBlocked = false
				player.room.objects.remove(door)
				onOpen?.call(door, obj, exit, player)
				return Describe(desc)
			}
			return null
		}		
	}
}
