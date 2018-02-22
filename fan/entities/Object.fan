
@Serializable
class Object : Describe {
	Uri			id
	Str			name
	Str			desc

	new make(|This| f) {
		f(this)
		if (id == null) id = `room:${name.fromDisplayName}`
	}
	
	override Str describe() {
		desc
	}
	
	override Str toStr() { id.toStr }
}
