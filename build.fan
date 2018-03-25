using build

class Build : BuildPod {
	new make() {
		podName = "afFindEmma"
		summary = "A retro text adventure game created as a Birthday present for my wife Emma"
		version = Version("1.0.2")

		meta = [
			"pod.dis"		: "Find Emma!",
			"repo.public"	: "true",
			"afIoc.module"	: "afFindEmma::WebModule"
		]

		depends = [
			"sys          1.0.70 - 1.0",
			"util         1.0.70 - 1.0",

			// ---- Web -------------------------
			"graphics     1.0.70 - 1.0",
			"dom          1.0.70 - 1.0",

			"afIoc        3.0.6  - 3.0",
			"afIocConfig  1.1.0  - 1.1",
			"afBedSheet   1.5.10 - 1.5",
			"afPillow     1.1.4  - 1.1",
			"afEfanXtra   1.2.0  - 1.2",
			"afDuvet      1.1.8  - 1.1",
			"afColdFeet   1.4.0  - 1.4",
		]

		srcDirs = [`fan/`, `fan/engine/`, `fan/web/`, `test/`]
		resDirs = [`res/`, `res/css/`, `res/images/`]
		
        docApi = false
        docSrc = true
        meta["afBuild.docApi"]  = "false"
        meta["afBuild.docSrc"]  = "true"
	}
}
