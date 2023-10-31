interface Material{
	scatter(r_in Ray, rec HitRecord, mut attenuation Vector, mut scattered Ray) bool
}

struct Lambertian {
	albedo Vector
}

fn (l Lambertian) scatter(r_in Ray, rec HitRecord, mut attenuation Vector, mut scattered Ray) bool {
	mut scatter_direction := rec.normal + random_unit_vector()
	if scatter_direction.near_zero() {
		scatter_direction = rec.normal
	}
	scattered = Ray{rec.p, scatter_direction}
	attenuation = l.albedo
	return true
}

struct Metal {
	albedo Vector
	fuzz f64
}

fn (m Metal) scatter(r_in Ray, rec HitRecord, mut attenuation Vector, mut scattered Ray) bool {
	reflected := reflect(r_in.dir.normalize(), rec.normal)
	fuzz := random_unit_vector().multf(m.fuzz)
	dir := reflected + fuzz
	if dot(dir, rec.normal) > 0 {
		scattered = Ray{rec.p, dir}
	}else {
		scattered = Ray{rec.p, reflected + fuzz.invert()}
	}
	// scattered = Ray{rec.p, dir}
	attenuation = m.albedo
	return dot(scattered.dir, rec.normal) > 0
}