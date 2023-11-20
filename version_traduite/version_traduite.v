import time
import math as m
import os
import toml

const (
	infinity = 10e100
	pi       = m.pi
)

fn main() {
	start_time := time.now()
	println('Started at ${start_time}')
	mut world := HittableList{}
	/*
	world.objects << Sphere{Point{0, 0, -1}, 0.5, Dielectric{1.5}}
	world.objects << Sphere{Point{0, 0, -1}, -0.4, Dielectric{1.5}}
	world.objects << Sphere{Point{-1, 0, -1}, 0.5, Lambertian{Vector{166 / 255.0, 227 / 255.0, 161 / 255.0}}}
	world.objects << Sphere{Point{0, 0, -2}, 0.5, Lambertian{Vector{250 / 255.0, 179 / 255.0, 135 / 255.0}}}
	world.objects << Sphere{Point{1, 0, -1}, 0.5, Metal{Vector{166 / 255.0, 227 / 255.0, 161 / 255.0}, 0.6}}
	world.objects << Sphere{Point{-1, 0, -2}, 0.5, Metal{Vector{116 / 255.0, 199 / 255.0, 236 / 255.0}, 0.1}}
	world.objects << Sphere{Point{0, -100.5, -1}, 100, Lambertian{Vector{0.960784314, 0.760784314, 0.905882353}}}
	*/
	world.objects << new_sphere(Point{0, -1000, 0}, 1000, Lambertian{Vector{0.5, 0.5, 0.5}})
	for a := -11; a < 11; a++ {
		for b := -11; b < 11; b++ {
			choose_mat := rd_f64()
			center := Point{a + 0.9 * rd_f64(), 0.2, b + 0.9 * rd_f64()}
			if (center - Point{4, 0.2, 0}).length() > 0.9 {
				if choose_mat < 0.2 {
					// diffuse
					albedo := random_vector() * random_vector()
					world.objects << new_sphere(center, 0.2, Lambertian{albedo})
				} else if choose_mat < 0.45 {
					// metal
					albedo := random_vector_between(0.2, 1)
					fuzz := rd_f64()
					world.objects << new_sphere(center, 0.2, Metal{albedo, fuzz})
				} else {
					// glass
					world.objects << new_sphere(center, 0.2, Dielectric{1.5})
					world.objects << new_sphere(center, -0.15, Dielectric{1.5})
				}
			}
		}
	}

	world.objects << new_sphere(Point{0, 1, 0}, 1.0, Dielectric{1.5})
	world.objects << new_sphere(Point{0, 1, 0}, -0.9, Dielectric{1.5})

	world.objects << new_sphere(Point{-4, 1, 0}, 1.0, Lambertian{Vector{0.4, 0.2, 0.1}})

	world.objects << new_sphere(Point{4, 1, 0}, 1.0, Metal{Vector{0.7, 0.6, 0.5}, 0.01})

	world_bvh := new_bvh_node(world.objects)

	world = HittableList{[world_bvh], world_bvh.bbox}

	// Camera
	config := toml.parse_file('config.toml') or { panic(err) }
	mut cam := Camera{}
	cam.aspect_ratio = config.value('aspect_ratio').f64()
	cam.image_width = config.value('image_width').int()
	cam.side_sample_per_pixel = config.value('side_sample_per_pixel').int()
	cam.max_depth = config.value('max_depth').int()
	cam.vfov = config.value('vfov').int()
	cam.lookfrom = Point{13, 2, 3}
	cam.lookat = Point{0, 0, 0}
	cam.vup = Vector{0, 1, 0}
	cam.defocus_angle = config.value('defocus_angle').f64()
	cam.focus_dist = config.value('focus_dist').f64()

	cam.render(world)

	finish_time := time.now()
	println('Finished at ${finish_time}, took ${finish_time - start_time}')

	os.execute('start " " "render.png"')
}
