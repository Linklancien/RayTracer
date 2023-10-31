const (
	x1p64 = f64_from_bits(u64(0x43f0000000000000))
	x1p1023 = f64_from_bits(u64(0x7fe0000000000000))
	x1p53 = f64_from_bits(u64(0x4340000000000000))
	x1p_1022 = f64_from_bits(u64(0x0010000000000000))
)

[inline]
fn degrees_to_radians(degrees f64) f64{
	return degrees * pi / 180.0
}

[inline]
fn sqrt(a f64) f64 { // /!\ approximations and maybe doesn't work for some numbers
	mut x := a
	z, ex := frexp(x)
	w := x
	// approximate square root of number between 0.5 and 1
	// relative error of approximation = 7.47e-3
	x = 4.173075996388649989089e-1 + 5.9016206709064458299663e-1 * z // adjust for odd powers of 2
	if (ex & 1) != 0 {
		x *= 1.41421356237309504880168872420969807856967187537694807317667974
	}
	x = scalbn(x, ex >> 1)
	// newton iterations
	x = 0.5 * (x + w / x)
	x = 0.5 * (x + w / x)
	x = 0.5 * (x + w / x)
	return x
}

[inline]
fn frexp(x f64) (f64, int) {
	mut y := f64_bits(x)
	e_ := int((y >> 52) & 0x7ff) - 0x3fe
	y &= u64(0x800fffffffffffff)
	y |= u64(0x3fe0000000000000)
	return f64_from_bits(y), e_
}

[inline]
fn scalbn(x f64, n_ int) f64 {
	return x * f64_from_bits(u64((0x3ff + n_)) << 52)
}

[inline]
fn f64_bits(f f64) u64 {
	return *unsafe { &u64(&f) }
}

[inline]
fn f64_from_bits(b u64) f64 {
	return *unsafe { &f64(&b) }
}

fn fabs(a f64) f64 {
	if a >= 0 {
		return a
	} else {
		return -a
	}
}