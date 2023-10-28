import stbi

struct Camera {
mut:
	aspect_ratio f64 = 1.0
	image_width int = 100
	image_height int
	center Point
	pixel00_loc Point
	pixel_delta_u Vector
	pixel_delta_v Vector
	focal_length f64
	viewport_height f64
	viewport_width f64
	viewport_u Vector
	viewport_v Vector
	viewport_upper_left Point
	samples_per_pixel int = 10
	rd Rand
}

fn (mut c Camera) initialize() {
	c.image_height = int(c.image_width/c.aspect_ratio)
	if c.image_height < 1 {
		c.image_height = 1
	}

	c.focal_length = 1.0
	c.viewport_height = 2.0
	c.viewport_width = c.viewport_height * (f64(c.image_width) / f64(c.image_height))
	c.center = Point{0, 0, 0}

	c.viewport_u = Vector{c.viewport_width, 0, 0}
	c.viewport_v = Vector{0, -c.viewport_height, 0}

	c.pixel_delta_u = c.viewport_u.divf(f64(c.image_width))
	c.pixel_delta_v = c.viewport_v.divf(f64(c.image_height))

	c.viewport_upper_left = c.center.subv(Vector{0, 0, c.focal_length}).subv(c.viewport_u.divf(2)).subv(c.viewport_v.divf(2))
	c.pixel00_loc = c.viewport_upper_left.addv(c.pixel_delta_u.divf(2)).addv(c.pixel_delta_v.divf(2))

}

[direct_array_access]
fn (mut c Camera) render(world Hittable) {
	c.initialize()

	mut image := []u8{cap: c.image_height * 4 * c.image_width}
	print('\n${c.image_height} lines remaining ')
	color_scale := 1.0/f64(c.samples_per_pixel)
	for j := 0; j < c.image_height; j++ {
		for i := 0; i < c.image_width; i++ {
			mut color := [f64(0), 0, 0]
			for _ in 0..c.samples_per_pixel {
				ray := c.get_ray(i, j)
				sample_color := ray_color(ray, world)
				color[0] += sample_color[0]
				color[1] += sample_color[1]
				color[2] += sample_color[2]
			}
			color[0] *= color_scale
			color[1] *= color_scale
			color[2] *= color_scale
			image << [u8(color[0]), u8(color[1]), u8(color[2]), 255]
		}
		print('\r${c.image_height - j} ')
	}
	stbi.stbi_write_jpg('render.png', c.image_width, c.image_height, 4, &(image[0]), c.image_width * 4) or {
		panic(err)
	}
	println('\rDone                ')
}

[inline]
fn (mut c Camera) get_ray(i int, j int) Ray {
	pixel_center := c.pixel00_loc.addv(c.pixel_delta_u.multf(i)).addv(c.pixel_delta_v.multf(j))
	pixel_sample := pixel_center.addv(c.pixel_sample_square())
	ray_origin := c.center
	ray_direction := pixel_sample.subp(c.center)
	return Ray{ray_origin, ray_direction}
}

[inline]
fn (mut c Camera) pixel_sample_square() Vector {
	px := -0.5 + c.rd.rd_f64()
	py := -0.5 + c.rd.rd_f64()
	return c.pixel_delta_u.multf(px) + c.pixel_delta_v.multf(py)
}

[inline]
fn ray_color(r Ray, world Hittable) []u8 {
	mut rec := HitRecord{}
	if world.hit(r, Interval{0, infinity}, mut rec) {
		return (rec.normal + Vector{1, 1, 1}).multf(0.5).to_color()
	}
	unit_direction := r.dir.normalize()
	a := 0.5 * (unit_direction.y + 1.0)
	return (Vector{1.0, 1.0, 1.0}.multf(1.0 - a) + Vector{0.5, 0.7, 1.0}.multf(a)).to_color()
}
