import time
import math as m
import os

const(
	infinity = 1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000.0
	pi = m.pi
)

fn main() {
	start_time := time.now()
	material_ground := Lambertian{Vector{0.8, 0.8, 0.0}}
	material_center := Lambertian{Vector{0.7, 0.3, 0.3}}
	material_left := Metal{Vector{0.8, 0.8, 0.8}, 0.3}
	material_right := Metal{Vector{0.8, 0.6, 0.2}, 1.0}
	println('Started at ${start_time}')
	mut world := HittableList{}
	world.objects << Sphere{Point{0, 0, -1}, 0.5, material_center}
	world.objects << Sphere{Point{-1, 0, -1}, 0.5, material_left}
	world.objects << Sphere{Point{1, 0, -1}, 0.5, material_right}
	world.objects << Sphere{Point{0, -100.5, -1}, 100, material_ground}

	mut cam := Camera{}
	// Camera
	cam.aspect_ratio = 16.0 / 9.0
	cam.image_width = 400
	cam.samples_per_pixel = 100
	cam.max_depth         = 50

	cam.render(world)
	finish_time := time.now()
	println('Finished at ${finish_time}, took ${finish_time-start_time}')
	os.execute('start " " "render.png"')
}
