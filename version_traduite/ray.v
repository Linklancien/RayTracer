struct Ray {
	origin Point
	dir    Vector
}

fn (r Ray) at(t f64) Point { // Linear interpolation (lerp)
	return r.origin.addv(r.dir.multf(t))
}
