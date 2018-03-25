using afIoc::Contribute
using afIoc::Configuration
using afIoc::RegistryBuilder
using afIocConfig::ApplicationDefaults
using afBedSheet::BedSheetConfigIds
using afBedSheet::Route
using afBedSheet::Routes
using afGoogleAnalytics::GoogleAnalyticsConfigIds

const class WebModule {
	
	Void defineServices(RegistryBuilder bob) {
		bob.options["afIoc.bannerText"] = "Find Emma v${typeof.pod.version}"
	}

    @Contribute { serviceType=Routes# }
    Void contributeRoutes(Configuration config) {
        config.add(Route(`/favicon.ico`, 		typeof.pod.file(`/res/favicon.ico`)))
        config.add(Route(`/css/app.min.css`, 	typeof.pod.file(`/res/app.min.css`)))
        config.add(Route(`/images/ogimage.png`, typeof.pod.file(`/doc/ogimage.png`)))
        config.add(Route(`/images/tv.jpg`, 		typeof.pod.file(`/res/tv.jpg`)))
    }
	
	@Contribute { serviceType=ApplicationDefaults# }
	Void contributeAppDefaults(Configuration config) {
		config[BedSheetConfigIds.host]					= "http://findemma.fantomfactory.org/"
		config[GoogleAnalyticsConfigIds.accountNumber]	= "UA-33997125-13"
	}
}
