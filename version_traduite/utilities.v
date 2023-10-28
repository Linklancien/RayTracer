import rand as rd

[inline]
fn degrees_to_radians(degrees f64) f64{
	return degrees * pi / 180.0
}

[inline]
fn random_f64() f64 {
	return rd.f64()
}

[inline]
fn random_f64_between(min f64, max f64) f64 {
	return min + (max-min)*random_f64()
}