const (
	reciprocal_2_52nd = 1.0 / f64(u64(1) << 52)
)

struct Rand {
	mut: seed u64
}

[inline]
fn (mut rd Rand) rd_u64() u64{
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
}

[inline]
fn (mut rd Rand) rd_f64() f64 {
	return f64((rd.rd_u64() >> 12) * reciprocal_2_52nd)
}

[inline]
fn (mut rd Rand) rd_f64_between(min f64, max f64) f64 {
	return min + (max-min)*rd.rd_f64()
}