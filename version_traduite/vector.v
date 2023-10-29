struct Vector {
	x f64
	y f64
	z f64
}

fn (vec Vector) divf(t f64) Vector {
	return Vector{vec.x / t, vec.y / t, vec.z / t}
}

fn (vec Vector) multf(t f64) Vector {
	return Vector{vec.x * t, vec.y * t, vec.z * t}
}

fn (vec Vector) lenght_squared() f64 {
	return dot(vec, vec)
}

fn (vec Vector) lenght() f64 {
	return sqrt(dot(vec, vec))
}

fn (vec Vector) normalize() Vector {
	return vec.divf(vec.lenght())
}

fn dot(v1 Vector, v2 Vector) f64 { // produit scalaire (dot product)
	return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
}

fn (v1 Vector) + (v2 Vector) Vector {
	return Vector{v1.x + v2.x, v1.y + v2.y, v1.z + v2.z}
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
