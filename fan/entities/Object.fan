
@Serializable
class Object : Describe {
	Uri			id
	Str			name
	Str			desc

	new make(|This| f) {
		f(this)
		if (id == null) id = `obj:${name.fromDisplayName}`
	}
	
	override Str describe() {
		describe := desc
		if (!describe.endsWith("\n")) describe = describe + "\n"
		return describe
	}
	
	override Str toStr() { id.toStr }
}
