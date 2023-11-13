struct Interval {
mut:
	min f64
	max f64
}

fn interval_from_interval(a Interval, b Interval) Interval {
	return Interval{min(a.min, b.min), max(a.max, b.max)}
}

fn (i Interval) contains(x f64) bool {
	return i.min <= x && x <= i.max
}

fn (i Interval) surrounds(x f64) bool {
	return i.min < x && x < i.max
}

fn (i Interval) size() f64 {
	return i.max - i.min
}

fn (i Interval) expand(delta f64) Interval {
	padding := delta/2
	return Interval{i.min - padding, i.max + padding}
}