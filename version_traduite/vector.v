const (
	s = 1e-8
)

struct Vector {
	x f64
	y f64
	z f64
}

fn (v Vector) axis(n int) f64 {
	if n == 0 {
		return v.x
	}else if n == 1 {
		return v.y
	}else {
		return v.z
	}
}

fn (vec Vector) divf(t f64) Vector {
	return Vector{vec.x / t, vec.y / t, vec.z / t}
}

fn (vec Vector) multf(t f64) Vector {
	return Vector{vec.x * t, vec.y * t, vec.z * t}
}

fn (vec Vector) length_squared() f64 {
	return dot(vec, vec)
}

fn (vec Vector) length() f64 {
	return sqrt(vec.length_squared())
}

fn (vec Vector) normalize() Vector {
	return vec.divf(vec.length())
}

fn dot(v1 Vector, v2 Vector) f64 { // produit scalaire (dot product)
	return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
}

fn cross(u Vector, v Vector) Vector {
	return Vector{u.y * v.z - u.z * v.y, u.z * v.x - u.x * v.z, u.x * v.y - u.y * v.x}
}

fn (v1 Vector) + (v2 Vector) Vector {
	return Vector{v1.x + v2.x, v1.y + v2.y, v1.z + v2.z}
}

fn (v1 Vector) - (v2 Vector) Vector {
	return Vector{v1.x - v2.x, v1.y - v2.y, v1.z - v2.z}
}

fn (v1 Vector) * (v2 Vector) Vector {
	return Vector{v1.x * v2.x, v1.y * v2.y, v1.z * v2.z}
}

fn (vec Vector) invert() Vector {
	return Vector{-vec.x, -vec.y, -vec.z}
}

fn (v Vector) to_color() Vector {
	/*
	mut color := u32(0)
	color = (color|u8(255)) << 8
	color = (color|u8(v.z*255)) << 8
	color = (color|u8(v.y*255)) << 8
	color = (color|u8(v.x*255))*/
	return v
}

fn (v Vector) near_zero() bool {
	return fabs(v.x) < s && fabs(v.y) < s && fabs(v.z) < s
}

fn reflect(v Vector, n Vector) Vector {
	return v - n.multf(2 * dot(v, n))
}

fn refract(uv Vector, n Vector, etai_over_etat f64) Vector {
	cos_theta := dot(uv.invert(), n)
	r_out_perp := (uv + n.multf(cos_theta)).multf(etai_over_etat)
	r_out_parallel := n.multf(-sqrt(fabs(1.0 - r_out_perp.length_squared())))
	return r_out_parallel + r_out_perp
}
