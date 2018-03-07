
@Js class Exit : Describe {
	      Uri		id
	const ExitType	type
	const Uri		exitToId
	Str				desc
	Str?			descBlocked
	Bool			isVisible
	Bool			isBlocked
	Str:Obj?		meta		:= Str:Obj?[:]
	@Transient
	Room?			exitTo

	|Exit, Player -> Describe?|?	onExit

	private new make(|This| f) { f(this) }
	
	new makeName(ExitType type, Uri exitToId, Str desc := "", |This|? f := null) {
		this.type		= type
		this.exitToId	= exitToId
		this.desc		= desc
		this.id			= `exit:$type.name.fromDisplayName`
		this.isVisible	= true
		this.isBlocked	= false

		f?.call(this)
	}

	override Str describe() {
		describe := desc.isEmpty
			? "You see the ${exitTo.name}."
			: desc
		
		if (isBlocked && descBlocked != null)
			describe += " " + descBlocked
		
		if (!describe.endsWith("\n")) describe = describe + "\n"
		return describe
	}
	
	internal Bool matches(Str str) {
		type == ExitType(str, false) || str == type.name[0].toChar
	}

	override Bool equals(Obj? that) { (that as Exit)?.id == id }
	override Int hash() { id.hash }
	override Str toStr() { id.toStr }
	override Int compare(Obj that) { type <=> ((Exit) that).type }

	Exit oneTimeMsg(Str msg) {
		onExit = oneTimeMsgFn(msg)
		return this
	}
	
	Exit block(Str onLookBlockMsg, Str onExitBlockMsg, Str? onExitOpenMsg := null, |Exit, Player->Bool|? isBlockedFn := null) {
		isBlocked	= true
		descBlocked	= onLookBlockMsg
		onExit  	= blockedMsgFn(onExitBlockMsg, onExitOpenMsg, isBlockedFn)
		return this
	}
	
	static |Exit, Player->Describe?| oneTimeMsgFn(Str msg) {
		|Exit exit, Player player-> Describe?| {
			exit.onExit = null
			return Describe(msg)
		}
	}
	
	static |Exit, Player->Describe?| blockedMsgFn(Str blockedMsg, Str? openMsg := null, |Exit, Player->Bool|? isBlockedFn := null) {
		|Exit exit, Player player-> Describe?| {
			if (isBlockedFn != null)
				exit.isBlocked = isBlockedFn(exit, player)
			return exit.isBlocked ? Describe(blockedMsg) : Describe(openMsg)
		}
	}
}

@Js enum class ExitType {
	north, south, east, west,
	up, down,
	in, out;
}
