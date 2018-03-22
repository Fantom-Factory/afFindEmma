using afIoc::Contribute
using afIoc::Configuration
using afIoc::RegistryBuilder
using afIocConfig::ApplicationDefaults
using afBedSheet::FileHandler
using afBedSheet::BedSheetConfigIds

const class WebModule {
	
	Void defineServices(RegistryBuilder bob) {
		bob.options["afIoc.bannerText"] = "Find Emma v${typeof.pod.version}"
	}

	
	
	// ---- BedSheet Configuration ----------------------------------------------------------------
	
	@Contribute { serviceType=FileHandler# }
	Void contributeFileHandler(Configuration config) {
		config[`/`]		= `etc/web-static/`.toFile
	}
	
	@Contribute { serviceType=ApplicationDefaults# }
	Void contributeAppDefaults(Configuration config) {
		config[BedSheetConfigIds.host]	= "http://findemma.fantomfactory.org/"
	}
}
