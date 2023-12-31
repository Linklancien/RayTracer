module main

// check si y'a de l'air dans les lignes proches pour voir si update requise ou pas
// implementer les nouveaux déplacements

// import sokol.sgl
import gg
import gx
import os
import math as m

const (
	aspect_ratio = 16 / 9
	win_width    = 400
	win_height   = 225 // int(m.max(win_width/aspect_ratio, 1))
	bg_color     = gx.black
)

struct App {
mut:
	gg            &gg.Context = unsafe { nil }
	istream_idx   int
	mouse_held    bool
	mouse_coords  [2]int
	log           os.File = os.open_append('log.log') or { panic(err) }
	screen_pixels [win_height][win_width]u32 = [win_height][win_width]u32{init: [
	win_width,
]u32{init: u32(0xFFFF_FFFF)}}
	cam Cam
}

// Viewport
struct Viewport {
mut:
	width       f64
	height      f64
	u           Vector
	v           Vector
	px_delta_u  Vector
	px_delta_v  Vector
	upper_left  Point
	pixel00_loc Point
}

// Vecteurs
struct Vector {
	x f64
	y f64
	z f64
}

// FONCTIONS POUR LES VECTEURS
fn (vec Vector) normalize() Vector {
	len := m.sqrt((vec.x * vec.x) + (vec.y * vec.y) + (vec.z * vec.z))
	return Vector{
		x: vec.x / len
		y: vec.y / len
		z: vec.z / len
	}
}

fn dot(v1 Vector, v2 Vector) f64 { // produit scalaire (dot product)
	return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
}

struct Point {
	x f64
	y f64
	z f64
}

// FONCTIONS POUR LES POINTS
fn (pt1 Point) - (pt2 Point) Vector {
	return Vector{pt1.x - pt2.x, pt1.y - pt2.y, pt1.z - pt2.z}
}

// Rays
struct Ray {
	origin    Point
	direction Vector
}

// FONCTIONS POUR LES Rays
fn (r Ray) l_inter(t f64) Point { // Linear interpolation
	return Point{
		x: r.origin.x + t * r.direction.x
		y: r.origin.y + t * r.direction.y
		z: r.origin.z + t * r.direction.z
	}
}

// Objts
struct Sphere {
	center Point
	r      f64
	color  u32
}

// Camera
struct Cam {
mut:
	focal f64
	pos   Point
	view  Viewport
}

// Fonction pour cam
fn (mut cam Cam) init() {
	cam.focal = 1.0
	cam.view = Viewport{
		height: 2.0
	}
	cam.view.width = cam.view.height * f64(win_width) / win_height
	cam.pos = Point{
		x: 0
		y: 0
		z: 0
	}
	cam.view.u = Vector{
		x: cam.view.width
		y: 0
		z: 0
	}
	cam.view.v = Vector{
		x: 0
		y: -cam.view.height
		z: 0
	}
	cam.view.px_delta_u = Vector{
		x: cam.view.u.x / f64(win_width)
		y: cam.view.u.y / f64(win_width)
		z: cam.view.u.z / f64(win_width)
	}
	cam.view.px_delta_v = Vector{
		x: cam.view.v.x / f64(win_height)
		y: cam.view.v.y / f64(win_height)
		z: cam.view.v.z / f64(win_height)
	}
	cam.view.upper_left = Point{
		x: cam.pos.x - (cam.view.u.x / 2) - (cam.view.v.x / 2)
		y: cam.pos.y - (cam.view.u.y / 2) - (cam.view.v.y / 2)
		z: cam.pos.z - (cam.view.u.z / 2) - (cam.view.v.z / 2) - cam.focal
	}
	dump(cam.view.upper_left)
	cam.view.pixel00_loc = Point{
		x: cam.view.upper_left.x + 0.5 * (cam.view.px_delta_u.x + cam.view.px_delta_v.x)
		y: cam.view.upper_left.y + 0.5 * (cam.view.px_delta_u.y + cam.view.px_delta_v.y)
		z: cam.view.upper_left.z + 0.5 * (cam.view.px_delta_u.z + cam.view.px_delta_v.z)
	}
	dump(cam.view.pixel00_loc)
}

fn main() {
	mut app := &App{
		gg: 0
	}
	app.gg = gg.new_context(
		width: win_width
		height: win_height
		create_window: true
		window_title: 'Rays simulation'
		user_data: app
		bg_color: bg_color
		init_fn: graphics_init
		frame_fn: on_frame
		event_fn: on_event
	)

	println('Start of the program!')
	app.cam.init()

	// lancement du programme/de la fenêtre
	app.calcul()

	app.gg.run()
}

fn on_frame(mut app App) {
	// Draw
	app.gg.begin()
	app.draw()
	app.gg.show_fps()
	app.gg.end()
}

fn (mut app App) calcul() {
	print('${win_height} lines remaining ')
	dump(app.cam.view.px_delta_u)
	dump(app.cam.view.px_delta_v)
	for y, mut ligne in app.screen_pixels {
		for x, mut valeur in ligne {
			pixel_center := Point{
				x: app.cam.view.pixel00_loc.x + x * app.cam.view.px_delta_u.x +
					y * app.cam.view.px_delta_v.x
				y: app.cam.view.pixel00_loc.y + x * app.cam.view.px_delta_u.y +
					y * app.cam.view.px_delta_v.y
				z: app.cam.view.pixel00_loc.z + x * app.cam.view.px_delta_u.z +
					y * app.cam.view.px_delta_v.z
			}
			ray_direc := (pixel_center - app.cam.pos) //.normalize() jsp si c bon
			ray := Ray{app.cam.pos, ray_direc}

			// app.log.write_string(ray_direc.str()) or {panic(err)}
			valeur = color_pixel(ray)
		}
		print('\r${win_height - y} ')
	}
	println('\rDone                ')
}

fn color_pixel(ray Ray) u32 {
	sphere_center := Point{0, 0, -1}
	t := hit_sphere(sphere_center, 0.5, ray)
	if t > 0.0 {
		n := (ray.l_inter(t) - sphere_center).normalize()
		return val_to_color(u8(127.5 * (n.x + 1)), u8(127.5 * (n.y + 1)), u8(127.5 * (n.z + 1)),
			255)
	}

	vect := ray.direction.normalize()
	a := 0.5 * (vect.y + 1)

	mut r := u8((1.0 - a) * 255 + a * 127.5)
	mut g := u8((1.0 - a) * 255 + a * 178.5)
	mut b := u8((1.0 - a) * 255 + a * 255)

	return val_to_color(r, g, b, 255)
}

fn hit_sphere(center Point, radius f64, ray Ray) f64 {
	oc := ray.origin - center
	a := dot(ray.direction, ray.direction)
	b := 2.0 * dot(oc, ray.direction)
	c := dot(oc, oc) - radius * radius
	discriminant := b * b - 4 * a * c
	if discriminant < 0 {
		return -1.0
	} else {
		return (-b - m.sqrt(discriminant)) / (2.0 * a)
	}
}

fn on_event(e &gg.Event, mut app App) {
}

fn val_to_color(r u8, g u8, b u8, a u8) u32 {
	mut color := u32(0)
	color = (color | a) << 8
	color = (color | b) << 8
	color = (color | g) << 8
	color = (color | r)
	return color
}

fn graphics_init(mut app App) {
	app.istream_idx = app.gg.new_streaming_image(win_width, win_height, 4, pixel_format: .rgba8)
}

fn (mut app App) draw() {
	mut istream_image := app.gg.get_cached_image_by_idx(app.istream_idx)
	istream_image.update_pixel_data(unsafe { &u8(&app.screen_pixels) })
	app.gg.draw_image(0, 0, win_width, win_height, istream_image)
}
