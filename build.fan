using build

class Build : BuildPod {
	new make() {
		podName = "afQuest"
		summary = "Where's Princess?"
		version = Version("0.0.1")

		meta = [
			"pod.dis"		: "Quest",
			"repo.public"	: "true",
			"afIoc.module"	: "afQuest::WebModule"
		]

		depends = [
			"sys          1.0.70 - 1.0",
			"util         1.0.70 - 1.0",

			// ---- Web -------------------------
			"dom          1.0.70 - 1.0",
			"domkit       1.0.70 - 1.0",
			"afIoc        3.0.6  - 3.0",
			"afBedSheet   1.5.10 - 1.5",
			"afPillow     1.1.4  - 1.1",
			"afEfanXtra   1.2.0  - 1.2",
			"afDuvet      1.1.8  - 1.1",
		]

		srcDirs = [`fan/`, `fan/entities/`, `fan/syntax/`, `fan/util/`, `fan/web/`, `test/`]
		resDirs = [,]
		
		docApi = true
		docSrc = true
	}
}
