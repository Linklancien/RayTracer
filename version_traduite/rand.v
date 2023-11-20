import rand as r

const (
	reciprocal_2_52nd = 1.0 / f64(u64(1) << 52)
)

struct Rand {
mut:
	seed u64
}

@[inline]
fn rd_u64() u64 {
	return r.u64()
}

/*
[inline]
fn rd_u64() u64{
	rd.seed += 1
	b := rd.seed + u64(0xa0761d6478bd642f)
	a := b ^ u64(0xe7037ed1a0b428db)
	mask32 := u32(4294967295)
	x0 := a & mask32
	x1 := a >> 32
	y0 := b & mask32
	y1 := b >> 32
	w0 := x0 * y0
	t := x1 * y0 + (w0 >> 32)
	mut w1 := t & mask32
	w2 := t >> 32
	w1 += x0 * y1
	hi := x1 * y1 + w2 + (w1 >> 32)
	lo := a * b
	return hi ^ lo
}*/

@[inline]
fn rd_f64() f64 {
	return f64((rd_u64() >> 12) * reciprocal_2_52nd)
}

@[inline]
fn rd_f64_between(min f64, max f64) f64 {
	return min + (max - min) * rd_f64()
}

@[inline]
fn random_vector() Vector {
	return Vector{rd_f64(), rd_f64(), rd_f64()}
}

@[inline]
fn random_vector_between(min f64, max f64) Vector {
	return Vector{rd_f64_between(min, max), rd_f64_between(min, max), rd_f64_between(min,
		max)}
}

@[inline]
fn random_vector_unit_sphere() Vector {
	mut p := random_vector_between(-1, 1)
	for p.length_squared() >= 1 {
		p = random_vector_between(-1, 1)
	}
	return p
}

@[inline]
fn random_in_unit_disk() Vector {
	mut p := Vector{rd_f64_between(-1, 1), rd_f64_between(-1, 1), 0}
	for p.length_squared() >= 1 {
		p = Vector{rd_f64_between(-1, 1), rd_f64_between(-1, 1), 0}
	}
	return p
}

@[inline]
fn random_unit_vector() Vector {
	return random_vector_unit_sphere().normalize()
}

@[inline]
fn random_on_hemisphere(normal Vector) Vector {
	on_unit_sphere := random_unit_vector()
	if dot(on_unit_sphere, normal) >= 0.0 {
		return on_unit_sphere
	} else {
		return on_unit_sphere.invert()
	}
}
