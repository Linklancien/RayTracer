import math as m
import stbi
import os

const(
	infinity = 1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000.0
	pi = m.pi
)

[inline]
fn degrees_to_radians(degrees f64) f64{
	return degrees * pi / 180.0
}

fn ray_color(r Ray, world Hittable) []u8 {
	mut rec := HitRecord{}
	if world.hit(r, Interval{0, infinity}, mut rec) {
		return (rec.normal + Vector{1, 1, 1}).multf(0.5).to_color()
	}
	unit_direction := r.dir.normalize()
	a := 0.5 * (unit_direction.y + 1.0)
	start_value := Vector{1.0, 1.0, 1.0}
	end_value := Vector{0.5, 0.7, 1.0}
	computed_value := start_value.multf(1.0 - a) + end_value.multf(a)
	return computed_value.to_color()
}

fn main() {
	// Image
	aspect_ratio := 16.0 / 9.0
	image_width := 400
	image_height := int(m.max(f64(image_width) / aspect_ratio, 1.0))

	mut world := HittableList{}
	world.objects << Sphere{Point{0, 0, -1}, 0.5}
	world.objects << Sphere{Point{0, -100.5, -1}, 100}

	// Camera
	focal_length := 1.0
	viewport_height := 2.0
	viewport_width := viewport_height * (f64(image_width) / f64(image_height))
	camera_center := Point{0, 0, 0}

	viewport_u := Vector{viewport_width, 0, 0}
	viewport_v := Vector{0, -viewport_height, 0}

	pixel_delta_u := viewport_u.divf(f64(image_width))
	pixel_delta_v := viewport_v.divf(f64(image_height))

	viewport_upper_left := camera_center.subv(Vector{0, 0, focal_length}).subv(viewport_u.divf(2)).subv(viewport_v.divf(2))
	pixel00_loc := viewport_upper_left.addv(pixel_delta_u.divf(2)).addv(pixel_delta_v.divf(2))

	println(image_width)
	println(image_height)
	mut image := []u8{cap: image_height * 4 * image_width}
	print('\n${image_height} lines remaining ')
	for j := 0; j < image_height; j++ {
		for i := 0; i < image_width; i++ {
			pixel_center := pixel00_loc.addv(pixel_delta_u.multf(f64(i))).addv(pixel_delta_v.multf(f64(j)))
			ray_direction := pixel_center.subp(camera_center)
			ray := Ray{camera_center, ray_direction}
			image << ray_color(ray, world)
		}
		print('\r${image_height - j} ')
	}
	stbi.stbi_write_jpg('render.png', image_width, image_height, 4, &(image[0]), image_width * 4) or {
		panic(err)
	}
	println('\rDone                ')
	os.execute('start " " "render.png"')
}
