using dom::Doc
using dom::Elem
using dom::Win
using domkit

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
	
	Link link(Str klass := "") {
		Link {
			_addAttrs(klass, "", it)
			it.uri = `#`
		}
	}
	
	Elem submit(Str klass, Str text) {
		// domkit buttons are DIVs not buttons
		// see http://fantom.org/forum/topic/2685
		elem("button") {
			butt := it
			_addAttrs(klass, text, it)
			it.style.addClass("domkit-control domkit-control-button domkit-Button")
			it.onEvent("mousedown", false) |e| { butt.style.addClass   ("down") }
			it.onEvent("mouseup", false  ) |e| { butt.style.removeClass("down") }
		}
	}
	
	Button button(Str klass, Str text := "") {
		Button() { _addAttrs(klass, text, it) }
	}
	
	FlowBox flowBox(Str klass, Str[] gaps := Str#.emptyList) {
		FlowBox {
			_addAttrs(klass, "", it)
			it.gaps = gaps
		}
	}
	
	SashBox sashBox(Str klass, Str[] sizes, Dir dir := Dir.right) {
		SashBox {
			_addAttrs(klass, "", it)
			it.sizes = sizes
			it.dir	 = dir
		}
	}
	
	Dialog dialog(Str klass, Str? title, |Elem| fn) {
		Dialog() {
			if (title != null && !title.isEmpty) it.title = title
			div(klass) { fn(it) },	// embed content in an extra div
		}
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
