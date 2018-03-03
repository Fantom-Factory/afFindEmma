using afIoc::Inject
using afEfanXtra::BeforeRender
using afEfanXtra::InitRender
using afPillow::Page
using afDuvet::HtmlInjector
using afEfanXtra::EfanComponent

@Page { url=`/dog` }
const mixin WebDogPage : EfanComponent {

	@Inject abstract HtmlInjector		injector
	
	@BeforeRender
	Void beforeRender() {
		pageType := AppDogPage#
		
		// see https://getbootstrap.com/docs/4.0/getting-started/introduction/#starter-template
		injector.injectMeta.setAttr("charset", "utf-8")
		injector.injectMeta.setAttr("http-equiv", "Content-Type").withContent("text/html;charset=utf-8")
		injector.injectMeta.withName("viewport").withContent("width=device-width, initial-scale=1, shrink-to-fit=no")

		injector.injectStylesheet.fromLocalUrl(`/css/app.min.css`)

		injector.injectFantomMethod(AppDogPage#init)
	}
	
	override Str renderTemplate() {
		"<!DOCTYPE html>
		 <html>
		 <head>
		 	<title>Dog</title>
		 </head>
		 <body id=\"appDogPage\">
		 </body>
		 </html>"
	}
}
