import time
import math as m
import os
import toml

const (
	infinity = 1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000.0
	pi       = m.pi
)

fn main() {
	start_time := time.now()
	println('Started at ${start_time}')
	mut world := HittableList{}
	world.objects << Sphere{Point{0, 0, -1}, 0.5, Dielectric{1.5}}
	world.objects << Sphere{Point{0, 0, -1}, -0.4, Dielectric{1.5}}
	world.objects << Sphere{Point{-1, 0, -1}, 0.5, Lambertian{Vector{166 / 255.0, 227 / 255.0, 161 / 255.0}}}
	world.objects << Sphere{Point{0, 0, -2}, 0.5, Lambertian{Vector{250 / 255.0, 179 / 255.0, 135 / 255.0}}}
	world.objects << Sphere{Point{1, 0, -1}, 0.5, Metal{Vector{166 / 255.0, 227 / 255.0, 161 / 255.0}, 0.6}}
	world.objects << Sphere{Point{-1, 0, -2}, 0.5, Metal{Vector{116 / 255.0, 199 / 255.0, 236 / 255.0}, 0.1}}
	world.objects << Sphere{Point{0, -100.5, -1}, 100, Lambertian{Vector{0.960784314, 0.760784314, 0.905882353}}}

	

	// Camera
	config := toml.parse_file('config.toml') or { panic(err) }
	mut cam := Camera{}
	cam.aspect_ratio 			= config.value('aspect_ratio').f64()
	cam.image_width 			= config.value('image_width').int()
	cam.side_sample_per_pixel 	= config.value('side_sample_per_pixel').int()
	cam.max_depth 				= config.value('max_depth').int()
	cam.vfov 					= config.value('vfov').int()
	cam.lookfrom				= Point{-2, 2, 1}
	cam.lookat 					= Point{0, 0, -1}
	cam.vup						= Vector{0, 1, 0}
	cam.defocus_angle 			= config.value('defocus_angle').f64()
	cam.focus_dist 				= config.value('focus_dist').f64()

	cam.render(world)

	finish_time := time.now()
	println('Finished at ${finish_time}, took ${finish_time - start_time}')
	
	os.execute('start " " "render.png"')
}
