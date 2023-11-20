struct Point {
	x f64
	y f64
	z f64
}

fn (p Point) axis(n int) f64 {
	if n == 0 {
		return p.x
	}else if n == 1 {
		return p.y
	}else {
		return p.z
	}
}

fn (p1 Point) - (p2 Point) Vector {
	return Vector{p1.x - p2.x, p1.y - p2.y, p1.z - p2.z}
}

fn (p Point) addv(v Vector) Point {
	return Point{p.x + v.x, p.y + v.y, p.z + v.z}
}

fn (p Point) subv(v Vector) Point {
	return Point{p.x - v.x, p.y - v.y, p.z - v.z}
}
