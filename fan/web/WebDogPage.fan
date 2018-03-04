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

//    <script type="text/javascript" src="/pod/sys/sys.js"></script>
//    <script type="text/javascript" src="/pod/gfx/gfx.js"></script>
//    <script type="text/javascript" src="/pod/web/web.js"></script>
//    <script type="text/javascript" src="/pod/dom/dom.js"></script>

//require(["afQuest"], function (_afQuest) {
//// default the tz to a sensible default that doesn't cause errors
//if (fan.sys.TimeZone.m_cur == null)
//    fan.sys.TimeZone.m_cur = fan.sys.TimeZone.fromStr('UTC');
//
//// actually, lets just load the tz database
//require(['sysTz'], function(foo) {
//
//    // inject env vars
//    var env = fan.sys.Map.make(fan.sys.Str.$type, fan.sys.Str.$type);
//env.caseInsensitive$(true);
//fan.sys.UriPodBase = '/pod/';
//fan.sys.Env.cur().$setVars(env);
//
//    // construct method args
//    var args = fan.sys.List.make(fan.sys.Obj.$type);
//    
//
//    // find main
//    var qname = 'afQuest::AppDogPage.init';
//    var main = fan.sys.Slot.findMethod(qname);
//
//    // invoke main
//    if (main.isStatic()) main.callList(args);
//    else main.callOn(main.parent().make(), args);
//});
//
//});