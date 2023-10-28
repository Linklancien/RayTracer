struct Interval {
	min f64
	max f64
}

fn (i Interval) contains(x f64) bool {
	return i.min <= x && x <= i.max
}

fn (i Interval) surrounds(x f64) bool {
	return i.min < x && x < i.max
}