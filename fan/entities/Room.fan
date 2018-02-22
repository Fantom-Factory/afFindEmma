
@Serializable
class Room : Describe {
	Uri				id
	Str				name
	Str				desc
	Exit[]			exits
	Object[]		objects
	Str?			namePrefix
	
	|Player, Room -> Describe?|?	onEnter
	|Player, Room -> Describe?|?	onLeave
	
	new make(|This| f) {
		f(this)
		if (id == null)			id		= `room:${name.fromDisplayName}`
		if (desc == null)		desc	= ""
		if (exits == null)		exits	= Exit[,]
		if (objects == null)	objects	= Object[,]
	}
	
	new makeName(Str name, Str desc, |This f|? f) {
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
	This add(Obj thing) {
		if (thing is Exit)		exits.add(thing)
		if (thing is Object)	objects.add(thing)
		return this
	}
	
	Exit[] visibleExits() {
		exits.findAll { it.isVisible }
	}

//	Exit[] usableExits() {
//		exits.findAll { !it.isBlocked }
//	}

	override Str describe() {
		str := StrBuf()
		str.add("You are ").add(namePrefix ?: "in the ").add(name).addChar('.').addChar('\n')
		str.addChar('\n')
		if (desc.size > 0) {
			str.add(desc).addChar('\n')
			str.addChar('\n')
		}
		if (visibleExits.isEmpty)
			str.add("There are no exits")
		else
			str.add("Exits are ").add(visibleExits.join(", ") { it.name }).addChar('.').addChar('\n')
		return str.toStr
	}
	
	override Str toStr() { id.toStr }
}
