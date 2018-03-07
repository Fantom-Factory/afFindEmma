using afIoc::Inject
using afBedSheet::HttpRequest
using afBedSheet::HttpResponse
using afBedSheet::Text
using afEfanXtra::BeforeRender
using afEfanXtra::InitRender
using afPillow::Page
using afPillow::PageEvent
using afDuvet::HtmlInjector
using afEfanXtra::EfanComponent

@Page { url=`/dog` }
const mixin WebDogPage : EfanComponent {

	@Inject abstract HtmlInjector	injector
	@Inject abstract HttpRequest	httpReq
	@Inject abstract HttpResponse	httpRes
	
	@BeforeRender
	Void beforeRender() {
		pageType := AppDogPage#
		
		// see https://getbootstrap.com/docs/4.0/getting-started/introduction/#starter-template
		injector.injectMeta.setAttr("charset", "utf-8")
		injector.injectMeta.setAttr("http-equiv", "Content-Type").withContent("text/html;charset=utf-8")
		injector.injectMeta.withName("viewport").withContent("width=device-width, initial-scale=1, shrink-to-fit=no")

		injector.injectStylesheet.fromLocalUrl(`/css/app.min.css`)

		// manually inject pods so the likes of afIoc aren't injected
		"sys concurrent graphics web dom afQuest".split.each |pod| {
			injector.injectScript.fromLocalUrl(`/pod/${pod}/${pod}.js`)
		}
		injector.injectScript.withScript(
			"if (fan.sys.TimeZone.m_cur == null)
			     fan.sys.TimeZone.m_cur = fan.sys.TimeZone.fromStr('UTC');
			
			 var args  = fan.sys.List.make(fan.sys.Obj.\$type);
			 var qname = '${AppDogPage#init.qname}';
			 var main  = fan.sys.Slot.findMethod(qname);
			
			 if (main.isStatic()) main.callList(args);
			 else main.callOn(main.parent().make(), args);"
		)
	}
	
	@PageEvent { httpMethod="POST" }
	Obj onDownload() {
		cmdHis := httpReq.body.form["cmdHis"]
		httpRes.saveAsAttachment("saveEmmaCmds.txt")
		return Text.fromPlain(cmdHis)
	}
	
	override Str renderTemplate() {
		"""<!DOCTYPE html>
		   <html>
		   <head>
		   	<title>Dog</title>
		   </head>
		   <body id=\"appDogPage\">
		   <footer>
		   	<a href="http://fantom-lang.org/" class="fantomLink">Written in Fantom</a>
		   	<a href="http://www.alienfactory.co.uk/" class="alienLink">by Alien-Factory</a>
		   </footer>
		   </body>
		   </html>"""
	}
}
