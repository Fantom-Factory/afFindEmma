using util::Arg
using util::Opt
using util::AbstractMain
using afBedSheet::BedSheetBuilder

class Main : AbstractMain {

	@Arg { help="The HTTP port to run the app on" }
	private Int port

	@Opt { help="Starts a dev proxy on <port> and launches the real web app on (<port> + 1)" }
	private Bool proxy

	@Opt { help="The environment to start BedSheet in -> dev|test|prod" }
	private Str? env

	override Int run() {
		BedSheetBuilder(this.typeof.pod.name).silence.startWisp(port, proxy, env)
	}
}
