
@Js mixin Describe {
	** All strings MUST end with '\n'.
	abstract Str describe()

	@Operator
	Describe plus(Describe d) {
		makeMulti([this, d])
	}

	@Operator
	Describe plusStr(Str d) {
		makeMulti([this, Describe(d)])
	}
	
	static new makeStr(Str? desc) {
		desc == null ? null : DescribeStr(desc)
	}
	
	static new makeStrBuf(StrBuf? desc) {
		desc == null ? null : DescribeStr(desc.toStr)
	}

	static new makeMulti(Describe?[] descs) {
		descs = descs.exclude { it == null }
		return descs.isEmpty ? null : DescribeMulti(descs)
	}
}

@Js internal class DescribeStr : Describe {
	override Str describe

	new make(Str describe) {
		if (!describe.endsWith("\n")) describe = describe + "\n"
		this.describe = describe
	}
}

@Js internal class DescribeMulti : Describe {
	private Describe[] describes

	new make(Describe[] describes) {
		this.describes = describes
	}

	override Str describe() {
		describes.join("\n") |d->Str| {
			describe := d.describe
			if (!describe.endsWith("\n")) describe = describe + "\n"
			return describe
		}
	}
}