import math 

interface Texture {
	value(u f64, v f64, p Point) Vector
}

struct SolidColor {
	color_value Vector
}

fn (s SolidColor) value(u f64, v f64, p Point) Vector {
	return s.color_value
}

struct CheckerTexture {
	inv_scale f64
	even Texture
	odd Texture
}

fn CheckerTexture.new(scale f64, even Texture, odd Texture) CheckerTexture {
	return CheckerTexture{1.0/scale, even, odd}
}

fn (c CheckerTexture) value(u f64, v f64, p Point) Vector {
	return if (int(math.floor(c.inv_scale*p.x)) + int(math.floor(c.inv_scale*p.y)) + int(math.floor(c.inv_scale*p.z))) % 2 == 0 {c.even.value(u, v, p)} else {c.odd.value(u, v, p)}
}