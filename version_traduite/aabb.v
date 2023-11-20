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

fn (a Aabb) hit(r Ray, ray Interval) bool {
	mut ray_t := ray
	mut t0 := min((a.x.min - r.origin.x) / r.dir.x, (a.x.max - r.origin.x) / r.dir.x)
	mut t1 := max((a.x.min - r.origin.x) / r.dir.x, (a.x.max - r.origin.x) / r.dir.x)
	ray_t.min = max(t0, ray_t.min)
	ray_t.max = min(t1, ray_t.max)
	if ray_t.max <= ray_t.min {
		return false
	}

	t0 = min((a.y.min - r.origin.y) / r.dir.y, (a.y.max - r.origin.y) / r.dir.y)
	t1 = max((a.y.min - r.origin.y) / r.dir.y, (a.y.max - r.origin.y) / r.dir.y)
	ray_t.min = max(t0, ray_t.min)
	ray_t.max = min(t1, ray_t.max)
	if ray_t.max <= ray_t.min {
		return false
	}

	t0 = min((a.z.min - r.origin.z) / r.dir.z, (a.z.max - r.origin.z) / r.dir.z)
	t1 = max((a.z.min - r.origin.z) / r.dir.z, (a.z.max - r.origin.z) / r.dir.z)
	ray_t.min = max(t0, ray_t.min)
	ray_t.max = min(t1, ray_t.max)
	if ray_t.max <= ray_t.min {
		return false
	}

	return true
}

fn (a Aabb) hit2(r Ray, mut ray_t Interval) bool { // TODO
	/*
	for (int a = 0; a < 3; a++) {
		auto invD = 1 / r.direction()[a];
		auto orig = r.origin()[a];

		auto t0 = (axis(a).min - orig) * invD;
		auto t1 = (axis(a).max - orig) * invD;

		if (invD < 0)
			std::swap(t0, t1);

		if (t0 > ray_t.min) ray_t.min = t0;
		if (t1 < ray_t.max) ray_t.max = t1;

		if (ray_t.max <= ray_t.min)
			return false;
	}*/
	return true
}
