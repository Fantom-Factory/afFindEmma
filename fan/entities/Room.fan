
@Js class Room : Describe {
	const Uri		id
	const Str		name		// I guess the name doesn't have to be fixed
	const Str?		namePrefix
	Str				desc
	Exit[]			exits
	Object[]		objects
	Str:Obj?		meta		:= Str:Obj?[:]

	|Room, Player -> Describe?|?	onEnter
	|Room, Player -> Describe?|?	onLeave
	
	private new make(|This| f) { f(this) }

	internal new makeName(Str name, Str desc, |This|? f) {
		this.name		= name
		this.desc		= desc
		this.id			= `room:${name.fromDisplayName}`
		this.exits		= Exit[,]
		this.objects	= Object[,]

		f?.call(this)
		
		this.exits.each { it.id = `${it.id.scheme}:${this.id.pathOnly}/${it.id.pathOnly}` }
		if (namePrefix != null && !namePrefix.endsWith(" "))
			this.namePrefix = namePrefix + " "
	}

	@Operator
	internal This add(Obj thing) {
		if (thing is Exit)		exits.add(thing)
		if (thing is Object)	objects.add(thing)
		return this
	}
	
	internal Exit[] visibleExits() {
		exits.findAll { it.isVisible }
	}
	
	internal Exit? findExit(Str str) {
		visibleExits.find { it.matches(str) }
	}
	
	internal Object? findObject(Str str) {
		objects.find { it.matches(str) }
	}

	Describe lookName() {
		Describe(StrBuf().add("You are ").add(namePrefix ?: "in the ").add(name).addChar('.').addChar('\n'))
	}

	Describe? lookObjects() {
		if (objects.isEmpty) return null
		str := StrBuf()
		str.add("You see ").add(objects.join(", ") { it.fullName }).addChar('.').addChar('\n')		
		return Describe(str)
	}

	Describe? lookExits() {
		str := StrBuf()
		if (visibleExits.isEmpty)
			str.add("There are no exits.").addChar('\n')
		else
			str.add("Exits are ").add(visibleExits.sort.join(", ") { it.type.name }).addChar('.').addChar('\n')
		return Describe(str)
	}
	
	override Str describe() {
		descs := Describe?[,]
		
		descs.add(lookName)

		if (desc.size > 0)
			descs.add(Describe(desc))

		descs.add(lookObjects)
		descs.add(lookExits)
		
		return Describe(descs).describe
	}
	
	override Str toStr() { id.toStr }
}
