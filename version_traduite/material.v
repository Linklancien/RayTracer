import math

interface Material {
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
	fuzz   f64
}

fn (m Metal) scatter(r_in Ray, rec HitRecord, mut attenuation Vector, mut scattered Ray) bool {
	reflected := reflect(r_in.dir.normalize(), rec.normal)
	fuzz := random_unit_vector().multf(m.fuzz)
	dir := reflected + fuzz
	if dot(dir, rec.normal) > 0 {
		scattered = Ray{rec.p, dir}
	} else {
		scattered = Ray{rec.p, reflected + fuzz.invert()}
	}

	// scattered = Ray{rec.p, dir}
	attenuation = m.albedo
	return dot(scattered.dir, rec.normal) > 0
}

struct Dielectric {
	ir f64
}

fn (d Dielectric) scatter(r_in Ray, rec HitRecord, mut attenuation Vector, mut scattered Ray) bool {
	attenuation = Vector{1, 1, 1}
	refraction_ratio := if rec.front_face { 1.0 / d.ir } else { d.ir }

	unit_direction := r_in.dir.normalize()
	cos_theta := dot(unit_direction.invert(), rec.normal) // for the cos_thetas I removes fmin(dot(_), 1)
	sin_theta := sqrt(1.0 - cos_theta * cos_theta)

	cannot_refract := refraction_ratio * sin_theta > 1.0

	mut dir := Vector{}
	if cannot_refract || reflectance(cos_theta, refraction_ratio) > rd_f64() {
		dir = reflect(unit_direction, rec.normal)
	} else {
		dir = refract(unit_direction, rec.normal, refraction_ratio)
	}

	scattered = Ray{rec.p, dir}
	return true
}

fn reflectance(cosine f64, ref_idx f64) f64 {
	mut r0 := (1 - ref_idx) / (1 + ref_idx)
	r0 = r0 * r0
	return r0 + (1 - r0) * math.pow((1 - cosine), 5)
}
