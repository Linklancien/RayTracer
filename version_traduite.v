import math as m
import stbi
import os

struct Point {
	x f64
	y f64
	z f64
}

fn (p1 Point) - (p2 Point) Vector {
	return Vector{p1.x - p2.x, p1.y - p2.y, p1.z - p2.z}
}

fn (p Point) addv(v Vector) Point {
	return Point{p.x + v.x, p.y + v.y, p.z + v.z}
}

fn (p Point) subv(v Vector) Point {
	return Point{p.x - v.x, p.y - v.y, p.z - v.z}
}

fn (p1 Point) subp(p2 Point) Vector {
	return Vector{p1.x - p2.x, p1.y - p2.y, p1.z - p2.z}
}

struct Vector {
	x f64
	y f64
	z f64
}

fn (vec Vector) divf(t f64) Vector {
	return Vector{vec.x / t, vec.y / t, vec.z / t}
}

fn (vec Vector) multf(t f64) Vector {
	return Vector{vec.x * t, vec.y * t, vec.z * t}
}

fn (vec Vector) lenght() f64 {
	return m.sqrt(dot(vec, vec))
}

fn (vec Vector) normalize() Vector {
	return vec.divf(vec.lenght())
}

fn dot(v1 Vector, v2 Vector) f64 { // produit scalaire (dot product)
	return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
}

fn (v1 Vector) + (v2 Vector) Vector {
	return Vector{v1.x + v2.x, v1.y + v2.y, v1.z + v2.z}
}

struct Ray {
	origin Point
	dir    Vector
}

fn (r Ray) at(t f64) Point { // Linear interpolation (lerp)
	return r.origin.addv(r.dir.multf(t))
}

struct Hit_Record {
	mut:
		p Point
		normal Vector
		t f64
}

interface Hittable  {
	//const ray& r, double ray_tmin, double ray_tmax, hit_record& rec
	hit(r Ray, ray_tmin f64, ray_tmax f64, rec Hit_Record) bool
}

struct Sphere {
	center Point
	radius f64
}

fn (s Sphere) hit(r Ray, ray_tmin f64, ray_tmax f64, mut rec Hit_Record) bool {
	oc := r.origin - s.center
	a := dot(r.dir, r.dir)
	half_b := dot(oc, r.dir)
	c := dot(oc, oc) - s.radius * s.radius
	discriminant := half_b * half_b - a * c
	if discriminant < 0 { return false }
	sqrtd := m.sqrt(discriminant)
	
	// Find the nearest root that lies in the acceptable range.
	mut root := (-half_b - sqrtd) / a
	if root <= ray_tmin || ray_tmax <= root{
		root = (-half_b + sqrtd) / a
		if root <= ray_tmin || ray_tmax <= root{ return false }
	}

	rec.t = root
	rec.p = r.at(rec.t)
	rec.normal = (rec.p - s.center).divf(s.radius)

	return true
}

fn (v Vector) to_color() []u8 {
	/*
	mut color := u32(0)
	color = (color|u8(255)) << 8
	color = (color|u8(v.z*255)) << 8
	color = (color|u8(v.y*255)) << 8
	color = (color|u8(v.x*255))*/
	return [u8(v.x * 255), u8(v.y * 255), u8(v.z * 255), 255]
}

fn hit_sphere(center Point, radius f64, r Ray) f64 {
	oc := r.origin - center
	a := dot(r.dir, r.dir)
	half_b := dot(oc, r.dir)
	c := dot(oc, oc) - radius * radius
	discriminant := half_b * half_b - a * c
	if discriminant < 0 {
        return -1.0
    } else {
        return (-half_b - m.sqrt(discriminant) ) / a
    }
}

fn ray_color(r Ray) []u8 {
	t := hit_sphere(Point{0, 0, -1}, 0.5, r)
	if t > 0.0  {
        /*return 0.5*color(N.x()+1, N.y()+1, N.z()+1);*/
		computed_value := (r.at(t).subp(Point{0,0,-1})).normalize()
		return (computed_value+Vector{1, 1, 1}).multf(0.5).to_color()
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
			image << ray_color(ray)
		}
		print('\r${image_height - j} ')
	}
	stbi.stbi_write_jpg('render.png', image_width, image_height, 4, &(image[0]), image_width * 4) or {
		panic(err)
	}
	println('\rDone                ')
	os.execute('start " " "render.png"')
}
