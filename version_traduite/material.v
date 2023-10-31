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
}

fn (m Metal) scatter(r_in Ray, rec HitRecord, mut attenuation Vector, mut scattered Ray) bool {
	reflected := reflect(r_in.dir.normalize(), rec.normal)
	scattered = Ray{rec.p, reflected}
	attenuation = m.albedo
	return true
}