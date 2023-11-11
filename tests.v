const (
	x1p64    = f64_from_bits(u64(0x43f0000000000000))
	x1p1023  = f64_from_bits(u64(0x7fe0000000000000))
	x1p53    = f64_from_bits(u64(0x4340000000000000))
	x1p_1022 = f64_from_bits(u64(0x0010000000000000))
)

for i in 0 .. 20 {
	println(sqrt(i * 1000000))
}
