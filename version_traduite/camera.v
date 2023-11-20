import stbi
import math

struct Camera {
mut:
	aspect_ratio          f64 = 1.0
	image_width           int = 100
	image_height          int
	center                Point
	pixel00_loc           Point
	pixel_delta_u         Vector
	pixel_delta_v         Vector
	viewport_height       f64
	viewport_width        f64
	viewport_u            Vector
	viewport_v            Vector
	viewport_upper_left   Point
	side_sample_per_pixel int = 3
	samples_per_pixel     int = 3
	sample_u              f64
	sample_v              f64
	sample_corner         Vector
	rd                    Rand
	max_depth             int

	vfov     f64    = 90
	lookfrom Point  = Point{0, 0, -1}
	lookat   Point  = Point{0, 0, 0}
	vup      Vector = Vector{0, 1, 0}
	u        Vector
	v        Vector
	w        Vector

	defocus_angle  f64
	focus_dist     f64 = 10
	defocus_disk_u Vector
	defocus_disk_v Vector
}

fn (mut c Camera) initialize() {
	c.image_height = int(c.image_width / c.aspect_ratio)
	if c.image_height < 1 {
		c.image_height = 1
	}

	c.samples_per_pixel = c.side_sample_per_pixel * c.side_sample_per_pixel
	c.sample_u = 1.0 / f64(c.side_sample_per_pixel)
	c.sample_v = 1.0 / f64(c.side_sample_per_pixel)
	c.sample_corner = Vector{c.sample_u * 0.5, c.sample_v * 0.5, 0}

	c.center = c.lookfrom

	theta := degrees_to_radians(c.vfov)
	h := math.tan(theta / 2)
	c.viewport_height = 2.0 * h * c.focus_dist
	c.viewport_width = c.viewport_height * (f64(c.image_width) / f64(c.image_height))

	c.w = (c.lookfrom - c.lookat).normalize()
	c.u = (cross(c.vup, c.w)).normalize()
	c.v = cross(c.w, c.u)

	c.viewport_u = c.u.multf(c.viewport_width)
	c.viewport_v = c.v.multf(-c.viewport_height)

	c.pixel_delta_u = c.viewport_u.divf(f64(c.image_width))
	c.pixel_delta_v = c.viewport_v.divf(f64(c.image_height))

	c.viewport_upper_left = c.center.subv(c.w.multf(c.focus_dist)).subv(c.viewport_u.divf(2)).subv(c.viewport_v.divf(2))
	c.pixel00_loc = c.viewport_upper_left.addv(c.pixel_delta_u.divf(2)).addv(c.pixel_delta_v.divf(2))

	defocus_radius := c.focus_dist * math.tan(degrees_to_radians(c.defocus_angle / 2.0))
	c.defocus_disk_u = c.u.multf(defocus_radius)
	c.defocus_disk_v = c.v.multf(defocus_radius)
}

@[direct_array_access]
fn (mut c Camera) render(world Hittable) {
	c.initialize()

	mut image := []u8{cap: c.image_height * 4 * c.image_width}
	print('${c.image_height} lines remaining ')
	color_scale := 1.0 / f64(c.samples_per_pixel)
	mut color := [f64(0), 0, 0]
	for j := 0; j < c.image_height; j++ {
		for i := 0; i < c.image_width; i++ {
			color = [f64(0), 0, 0]
			for nb in 0 .. c.samples_per_pixel {
				ray := c.get_ray(i, j, nb)
				sample_color := ray_color(ray, c.max_depth, world)
				color[0] += sample_color.x
				color[1] += sample_color.y
				color[2] += sample_color.z
			}
			color[0] *= color_scale
			color[1] *= color_scale
			color[2] *= color_scale

			color[0] = linear_to_gamma(color[0])
			color[1] = linear_to_gamma(color[1])
			color[2] = linear_to_gamma(color[2])
			image << [u8(color[0] * 255), u8(color[1] * 255), u8(color[2] * 255), 255]
		}
		print('\r${c.image_height - j} ')
	}
	stbi.stbi_write_jpg('render.png', c.image_width, c.image_height, 4, &(image[0]), c.image_width * 4) or {
		panic(err)
	}
	println('\rDone                ')
}

fn linear_to_gamma(linear_component f64) f64 {
	return sqrt(linear_component)
}

@[inline]
fn (mut c Camera) get_ray(i int, j int, nb int) Ray {
	pixel_center := c.pixel00_loc.addv(c.pixel_delta_u.multf(i)).addv(c.pixel_delta_v.multf(j))
	pixel_sample := pixel_center.addv(c.pixel_sample_square_grid(nb)) //(c.pixel_sample_square_grid(nb))
	ray_origin := if c.defocus_angle <= 0 { c.center } else { c.defocus_disk_sample() }
	ray_direction := pixel_sample - ray_origin
	return Ray{ray_origin, ray_direction, rd_f64()}
}

fn (c Camera) defocus_disk_sample() Point {
	p := random_in_unit_disk()
	return c.center.addv(c.defocus_disk_u.multf(p.x)).addv(c.defocus_disk_v.multf(p.y))
}

@[inline]
fn (mut c Camera) pixel_sample_square_grid(nb int) Vector { // maybe replace later by a circle ?
	i := nb / c.side_sample_per_pixel
	j := nb % c.side_sample_per_pixel
	px := -0.5 + i * c.sample_u + c.sample_corner.x
	py := -0.5 + j * c.sample_v + c.sample_corner.y
	return c.pixel_delta_u.multf(px) + c.pixel_delta_v.multf(py)
}

@[inline]
fn (mut c Camera) pixel_sample_square() Vector { // maybe replace later by a smooth distribution? in a circle ?
	px := -0.5 + rd_f64()
	py := -0.5 + rd_f64()
	return c.pixel_delta_u.multf(px) + c.pixel_delta_v.multf(py)
}

@[inline]
fn ray_color(r Ray, depth int, world Hittable) Vector {
	mut rec := HitRecord{}

	// If we've exceeded the ray bounce limit, no more light is gathered.
	if depth <= 0 {
		return Vector{0, 0, 0}
	}

	if world.hit(r, Interval{0.001, infinity}, mut rec) {
		mut scattered := Ray{}
		mut attenuation := Vector{}
		if rec.mat.scatter(r, rec, mut attenuation, mut scattered) {
			return attenuation * ray_color(scattered, depth - 1, world)
		}
		return Vector{0, 0, 0}
	}
	unit_direction := r.dir.normalize()
	a := 0.5 * (unit_direction.y + 1.0)
	return (Vector{1.0, 1.0, 1.0}.multf(1.0 - a) + Vector{0.5, 0.7, 1.0}.multf(a)).to_color()
}
