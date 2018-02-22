using build

class Build : BuildPod {
	new make() {
		podName = "afQuest"
		summary = "Where's Princess?"
		version = Version("0.0.1")

		depends = [
			"sys          1.0.69 - 1.0",
			"gfx          1.0.69 - 1.0",
			"fwt          1.0.69 - 1.0",
			"afFish   2.0.7.0  - 2.0",
		]

		srcDirs = [`fan/`, `fan/entities/`, `test/`]
		resDirs = [,]
		
		docApi = true
		docSrc = true
	}
}
