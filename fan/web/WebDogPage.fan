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

		// manually inject pods so the likes of afIoc aren't injected
		injector.injectScript.fromLocalUrl(`/pod/sys/sys.js`)
		injector.injectScript.fromLocalUrl(`/pod/graphics/graphics.js`)
		injector.injectScript.fromLocalUrl(`/pod/dom/dom.js`)
		injector.injectScript.fromLocalUrl(`/pod/afQuest/afQuest.js`)
		injector.injectScript.withScript(
			"if (fan.sys.TimeZone.m_cur == null)
			     fan.sys.TimeZone.m_cur = fan.sys.TimeZone.fromStr('UTC');
			
			 var args  = fan.sys.List.make(fan.sys.Obj.\$type);
			 var qname = 'afQuest::AppDogPage.init';
			 var main  = fan.sys.Slot.findMethod(qname);
			
			 if (main.isStatic()) main.callList(args);
			 else main.callOn(main.parent().make(), args);"
		)
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
