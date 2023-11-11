interface Hittable {
	// const ray& r, double ray_tmin, double ray_tmax, HitRecord& rec
	hit(r Ray, ray_t Interval, mut rec HitRecord) bool
}

struct HittableList {
mut:
	objects []Hittable
}

fn (list HittableList) hit(r Ray, ray_t Interval, mut rec HitRecord) bool {
	mut temp_rec := HitRecord{}
	mut hit_anything := false
	mut closest_so_far := ray_t.max

	for object in list.objects {
		if object.hit(r, Interval{ray_t.min, closest_so_far}, mut temp_rec) {
			hit_anything = true
			closest_so_far = temp_rec.t
			rec = temp_rec
		}
	}

	return hit_anything
}

struct Sphere {
	center Point
	radius f64
	mat    Material
}

fn (s Sphere) hit(r Ray, ray_t Interval, mut rec HitRecord) bool {
	oc := r.origin - s.center
	a := dot(r.dir, r.dir)
	half_b := dot(oc, r.dir)
	c := dot(oc, oc) - s.radius * s.radius
	discriminant := half_b * half_b - a * c
	if discriminant < 0 {
		return false
	}
	sqrtd := sqrt(discriminant)

	// Find the nearest root that lies in the acceptable range.
	mut root := (-half_b - sqrtd) / a
	if !ray_t.surrounds(root) {
		root = (-half_b + sqrtd) / a
		if !ray_t.surrounds(root) {
			return false
		}
	}

	rec.t = root
	rec.p = r.at(rec.t)
	outward_normal := (rec.p - s.center).divf(s.radius)
	rec.set_face_normal(r, outward_normal)
	rec.mat = s.mat

	return true
}
