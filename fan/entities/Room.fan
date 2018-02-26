
@Serializable
class Room : Describe {
	Uri				id
	Str				name
	Str				desc
	Exit[]			exits
	Object[]		objects
	Str?			namePrefix
	
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

	override Str describe() {
		str := StrBuf()
		str.add("You are ").add(namePrefix ?: "in the ").add(name).addChar('.').addChar('\n')
		str.addChar('\n')

		if (desc.size > 0) {
			str.add(desc).addChar('\n')
			str.addChar('\n')
		}

		if (objects.size > 0) {
			str.add("You see ").add(objects.join(", ") { it.fullName }).addChar('.').addChar('\n')
			str.addChar('\n')
		}

		if (visibleExits.isEmpty)
			str.add("There are no exits").addChar('\n')
		else
			str.add("Exits are ").add(visibleExits.join(", ") { it.type.name }).addChar('.').addChar('\n')
		
		describe := str.toStr
		if (!describe.endsWith("\n")) describe = describe + "\n"
		return describe
	}
	
	override Str toStr() { id.toStr }
}
