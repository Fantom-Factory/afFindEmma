
@Js mixin DurationLocale {
	
	static Str approx(Duration duration, Bool full := false, Str justNow := "Just now") {
		// I must be able to come up with a decent DurationBuilder rather than this rubbish...!

		secs := duration.toSec
		if (secs == 0)
			return justNow
		if (secs == 1)
			return "${secs} sec" + (full ? "ond":"")
		if (secs <= 60)
			return "${secs} sec" + (full ? "ond":"") + "s"

		mins := duration.toMin
		if (mins == 1)
			return "${mins} min" + (full ? "ute":"")
		if (mins <= 60)
			return "${mins} min" + (full ? "ute":"") + "s"

		hours := duration.toHour
		if (hours == 1)
			return "${hours} hour"
		if (hours <= 24)
			return "${hours} hours"
		
		days := duration.toDay
		if (days == 1)
			return "${days} day"
		if (days <= 7)
			return "${days} days"

		weeks := days / 7
		if (weeks == 1)
			return "${weeks} week"
		if (weeks <= 5)
			return "${weeks} weeks"

		months := days / 30
		if (months == 1)
			return "${months} month"
		if (months <= 11)
			return "${months} months"

		years := days / 365
		if (years == 1)
			return "${years} year"

		return "${years} years"
	}
}
