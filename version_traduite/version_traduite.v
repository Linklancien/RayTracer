import time
import math as m
import os

const(
	infinity = 1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000.0
	pi = m.pi
)

fn main() {
	start_time := time.now()
	material_ground := Lambertian{Vector{0.960784314, 0.760784314, 0.905882353}}
	material_left := Lambertian{Vector{0.7, 0.3, 0.3}}
	// material_center := Dielectric{1.5}
	// material_left := Metal{Vector{0.8, 0.8, 0.8}, 0.2}
	material_center := Dielectric{1.5}
	material_right := Metal{Vector{0.8, 0.6, 0.2}, 0.1}
	println('Started at ${start_time}')
	mut world := HittableList{}
	world.objects << Sphere{Point{0, 0.01, -1}, 0.5, material_center}
	world.objects << Sphere{Point{0, 0.01, -1}, -0.4, material_center}
	world.objects << Sphere{Point{-1.1, 0, -1}, 0.5, material_left}
	world.objects << Sphere{Point{1.1, 0, -1}, 0.5, material_right}
	world.objects << Sphere{Point{0, -100.5, -1}, 100, material_ground}

	mut cam := Camera{}
	// Camera
	cam.aspect_ratio = 16.0 / 9.0
	cam.image_width = 400
	cam.samples_per_pixel = 100
	cam.max_depth         = 50
	cam.vfov = 90

	cam.render(world)
	finish_time := time.now()
	println('Finished at ${finish_time}, took ${finish_time-start_time}')
	os.execute('start " " "render.png"')
}
