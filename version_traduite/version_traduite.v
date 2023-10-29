import math as m
import os

const(
	infinity = 1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000.0
	pi = m.pi
)

fn main() {
	mut world := HittableList{}
	world.objects << Sphere{Point{0, 0, -1}, 0.5}
	world.objects << Sphere{Point{0, -100.5, -1}, 100}

	mut cam := Camera{}
	// Camera
	cam.aspect_ratio = 16.0 / 9.0
	cam.image_width = 400
	cam.samples_per_pixel = 100
	cam.max_depth         = 50

	cam.render(world)
	os.execute('start " " "render.png"')
}
