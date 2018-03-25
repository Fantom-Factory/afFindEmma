using afIoc::Inject
using afBedSheet::BedSheetServer
using afBedSheet::ClientAssetCache
using afBedSheet::FileHandler
using afBedSheet::HttpRequest
using afBedSheet::HttpResponse
using afBedSheet::Text
using afEfanXtra::BeforeRender
using afEfanXtra::InitRender
using afPillow::Page
using afPillow::PageEvent
using afDuvet::HtmlInjector
using afEfanXtra::EfanComponent
using graphics::Image

@Page { url=`/` }
const mixin WebQuestPage : EfanComponent {

	@Inject abstract HtmlInjector	injector
	@Inject abstract HttpRequest	httpReq
	@Inject abstract HttpResponse	httpRes
	@Inject abstract BedSheetServer	bedServer
	
	static const Image ogImage		:= Image.decode(`fan://afFindEmma/res/images/ogimage.png`.toFile.readAllBuf)
	static const Str windowTitle	:= "Find Emma! - by Alien-Factory"
	static const Str windowDesc		:= "A retro text adventure game created as a Birthday present for my wife Emma; written in Fantom by Alien-Factory"
	
	@BeforeRender
	Void beforeRender() {
		// see https://getbootstrap.com/docs/4.0/getting-started/introduction/#starter-template
		injector.injectMeta.setAttr("charset", "utf-8")
		injector.injectMeta.setAttr("http-equiv", "Content-Type").withContent("text/html;charset=utf-8")
		injector.injectMeta.withName("viewport").withContent("width=device-width, initial-scale=1, shrink-to-fit=no")

		injector.injectMeta.withName	("description"		).withContent(windowDesc)
		injector.injectMeta.withProperty("og:type"			).withContent("website")
		injector.injectMeta.withProperty("og:title"			).withContent(windowTitle)
		injector.injectMeta.withProperty("og:url"			).withContent(bedServer.host.encode)
		injector.injectMeta.withProperty("og:image"			).withContent(bedServer.toAbsoluteUrl(bedServer.toClientUrl(`/images/ogimage.png`)).encode)
		injector.injectMeta.withProperty("og:image:width"	).withContent(ogImage.size.w.toInt.toStr)
		injector.injectMeta.withProperty("og:image:height"	).withContent(ogImage.size.h.toInt.toStr)
		injector.injectMeta.withProperty("og:description"	).withContent(windowDesc)
		injector.injectLink.withRel		("canonical"		).setAttr	 ("href", bedServer.host.encode)

		injector.injectStylesheet.fromLocalUrl(`/css/app.min.css`)

		// manually inject pods so the likes of afIoc aren't injected
		"sys concurrent graphics web dom afFindEmma".split.each |pod| {
			injector.injectScript.fromLocalUrl(`/pod/${pod}/${pod}.js`)
		}
		injector.injectScript.withScript(
			"if (fan.sys.TimeZone.m_cur == null)
			     fan.sys.TimeZone.m_cur = fan.sys.TimeZone.fromStr('UTC');
			
			 var args  = fan.sys.List.make(fan.sys.Obj.\$type);
			 var qname = '${AppQuestPage#init.qname}';
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
		   <html lang='en' prefix='og: http://ogp.me/ns#'>
		   <head>
		   	<title>${windowTitle}</title>
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
