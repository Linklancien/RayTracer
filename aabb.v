struct Aabb {
	x Interval
	y Interval
	z Interval
}

fn points_aabb(a Point, b Point) Aabb {
	return Aabb{Interval{min(a.x, b.x), max(a.x, b.x)}, Interval{min(a.y, b.y), max(a.y,
		b.y)}, Interval{min(a.z, b.z), max(a.z, b.z)}}
}

fn aabb_aabb(a Aabb, b Aabb) Aabb {
	return Aabb{interval_from_interval(a.x, b.x), interval_from_interval(a.y, b.y), interval_from_interval(a.z,
		b.z)}
}

fn (a Aabb) axis(n int) Interval {
	if n == 1 {
		return a.y
	} else if n == 2 {
		return a.z
	}
	return a.x
}

fn (aabb Aabb) hit(r Ray, ray Interval) bool {
	mut ray_t := ray
	for a := 0; a < 3; a += 1 {
		inv_d := 1 / r.dir.axis(a)
		orig := r.origin.axis(a)

		mut t0 := (aabb.axis(a).min - orig) * inv_d
		mut t1 := (aabb.axis(a).max - orig) * inv_d
		if inv_d < 0 {
			t0, t1 = t1, t0
		}
		if t0 > ray_t.min {
			ray_t.min = t0
		}
		if t1 < ray_t.max {
			ray_t.max = t1
		}

		if ray_t.max <= ray_t.min {
			return false
		}
	}
	return true
}
