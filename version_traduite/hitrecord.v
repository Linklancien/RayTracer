struct HitRecord {
mut:
	p          Point
	normal     Vector
	t          f64
	front_face bool
}

fn (mut rec HitRecord) set_face_normal(r Ray, outward_normal Vector) {
	rec.front_face = dot(r.dir, outward_normal) < 0
	rec.normal = if rec.front_face { outward_normal } else { outward_normal.invert() }
}