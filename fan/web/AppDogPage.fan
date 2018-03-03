using dom
using domkit

@Js class AppDogPage : DomBob {
	
	Str logo := "
	                  _____^__
	                  |    |    \\
	                   \\   /  ^ |           ________)              _____)
	                  / \\_/   0  \\         (, /     ,       /)   /
	                 /            \\          /___,   __   _(/    )__   ___  ___   _  
	                /    ____      0      ) /     _(_/ (_(_(_  /       // (_// (_(_(_
	               /      /  \\___ _/     (_/                  (_____)
	             \n"
	
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
							div("text", "") {
								div("logo", logo),
								div("#screen", "adsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa\nadsfa sdf sdf l jkl iu h iuh ih k nk h  hk k hk h u uiuihiu hi h uhi h ihiuuh i hi hi h\nadsfa\nadsfa\nadsfa\n"),
							},
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
	
		prompt := doc.elemById("prompt")
		screen := doc.elemById("screen")
		
		prompt.focus
	}
}
