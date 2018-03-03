using dom
using domkit

@Js class AppDogPage : DomBob {
	
	Void init() {
		doc.body.add(
			div("box") {
				div("terminal") {
					div("tvBg") {
						elem("img") {
							it.setAttr("src", "/images/tv.jpg")
						},
					},
					sashBox("screen", "100% 3rem".split, Dir.down) {
						div("output") {
							div("text", "adad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\nadad\n"),
						},
						div("input") {
							TextField {
								it.id = "prompt"
								it.setAttr("autofocus", "")
							},
						},
					},
				},
			}
		)
	
		doc.elemById("prompt").focus
	}
}