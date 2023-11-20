import rand

interface Hittable {
	// const ray& r, double ray_tmin, double ray_tmax, HitRecord& rec
	bbox Aabb
	hit(r Ray, ray_t Interval, mut rec HitRecord) bool
}

struct HittableList {
mut:
	objects []Hittable
	bbox    Aabb
}

fn (mut list HittableList) add(obj Hittable) {
	list.objects << obj
	list.bbox = aabb_aabb(list.bbox, obj.bbox)
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

struct BvhNode {
mut:
	left  Hittable
	right Hittable
	bbox  Aabb
}

fn new_bvh_node(src_objects []Hittable) BvhNode {
	mut bvh := BvhNode{}
	axis := rand.int_in_range(0, 3) or { panic(err) }
	comparator := if axis == 0 {
		box_x_compare
	} else {
		if axis == 1 { box_y_compare } else { box_z_compare }
	}
	object_span := src_objects.len
	if object_span == 1 {
		bvh.left = src_objects[0]
		bvh.right = src_objects[0]
	} else if object_span == 2 {
		if comparator(src_objects[0], src_objects[1]) == -1 {
			bvh.left = src_objects[0]
			bvh.right = src_objects[1]
		} else {
			bvh.left = src_objects[1]
			bvh.right = src_objects[0]
		}
	} else {
		mut obj := src_objects.clone()
		obj.sort_with_compare(comparator)
		mid := object_span / 2
		bvh.left = new_bvh_node(obj[..mid])
		bvh.right = new_bvh_node(obj[mid..])
	}
	bvh.bbox = aabb_aabb(bvh.left.bbox, bvh.right.bbox)
	return bvh
}

fn box_compare(a &Hittable, b &Hittable, axis_index int) int {
	if a.bbox.axis(axis_index).min <= b.bbox.axis(axis_index).min {
		return -1
	}
	return 1
}

fn box_x_compare(a &Hittable, b &Hittable) int {
	return box_compare(a, b, 0)
}

fn box_y_compare(a &Hittable, b &Hittable) int {
	return box_compare(a, b, 1)
}

fn box_z_compare(a &Hittable, b &Hittable) int {
	return box_compare(a, b, 2)
}

fn (bvh BvhNode) hit(r Ray, ray_t Interval, mut rec HitRecord) bool {
	if !bvh.bbox.hit(r, ray_t) {
		return false
	}
	hit_left := bvh.left.hit(r, ray_t, mut rec)
	hit_right := bvh.right.hit(r, Interval{ray_t.min, if hit_left { rec.t } else { ray_t.max }}, mut
		rec)
	return hit_left || hit_right
}

struct Sphere {
	center     Point
	radius     f64
	mat        Material
	bbox       Aabb
	is_moving  bool
	center_vec Vector
}

fn new_sphere(center Point, radius f64, mat Material) Sphere {
	rvec := Vector{radius, radius, radius}
	return Sphere{center, radius, mat, points_aabb(center.subv(rvec), center.addv(rvec)), false, Vector{0, 0, 0}}
}

fn new_moving_sphere(center Point, radius f64, mat Material, center2 Point) Sphere {
	rvec := Vector{radius, radius, radius}
	box1 := points_aabb(center.subv(rvec), center.addv(rvec))
	box2 := points_aabb(center2.subv(rvec), center2.addv(rvec))
	return Sphere{center, radius, mat, aabb_aabb(box1, box2), true, center2 - center}
}

fn (s Sphere) center(time f64) Point {
	return s.center.addv(s.center_vec.multf(time))
}

fn (s Sphere) hit(r Ray, ray_t Interval, mut rec HitRecord) bool {
	center := if s.is_moving { s.center(r.tm) } else { s.center }
	oc := r.origin - center
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
	outward_normal := (rec.p - center).divf(s.radius)
	rec.set_face_normal(r, outward_normal)
	rec.mat = s.mat

	return true
}
