using afIoc
using afBedSheet

const class WebModule {
	
	Void defineServices(RegistryBuilder bob) {
		bob.options["afIoc.bannerText"] = "Quest v${typeof.pod.version}"
	}

	
	
	// ---- BedSheet Configuration ----------------------------------------------------------------
	
	@Contribute { serviceType=FileHandler# }
	Void contributeFileHandler(Configuration config) {
		config[`/`]		= `etc/web-static/`.toFile
	}
}
