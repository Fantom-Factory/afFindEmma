using dom::Doc
using dom::Elem
using dom::Win

** Handy builder methods for domkit objects. 
@Js mixin DomBob {

	Win win() { Win.cur	}
	Doc doc() { win.doc	}
	
	Elem elem(Str tag, Str klass := "", Str text := "") {
		Elem(tag) { _addAttrs(klass, text, it) }		
	}

	Elem div(Str klass := "", Str text := "") {
		elem("div", klass, text)
	}

	Elem span(Str klass := "", Str text := "") {
		elem("span", klass, text)
	}
	
	** _addAttrs("#id css class", "text", elem)
	private Void _addAttrs(Str klass, Str text, Elem elem) {
		if (!klass.isEmpty) {
			if (klass.startsWith("#")) {
				klass.split.each {
					if (it.startsWith("#"))
						elem.id = it[1..-1]
					else
						elem.style.addClass(it)
				}
			} else
				elem.style.addClass(klass)
		}
		if (!text.isEmpty) elem.text = text
	}
}
