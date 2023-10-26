package main
//"C:\Users\PACHECON\Downloads\go1.21.3.windows-amd64\go\bin\go.exe" run main.go > out.ppm
import (
	"fmt"
	"log"
	"math"
	"strconv"
)

const (
	COLOR_MAX = 255.999
)
type Vec3 struct {
	X, Y, Z float64
}

type Color struct {
	ColorX, ColorY, ColorZ int
}

type Point3 = Vec3

type Ray struct {
	Origin    Point3
	Direction Vec3
}

// Ray functions

func (r Ray) GetOrigin() Point3 {
	return r.Origin
}

func (r Ray) GetDirection() Vec3 {
	return r.Direction
}

func (r Ray) At(t float64) Vec3 {

	return r.GetOrigin().Add(*r.GetDirection().MultiplyFloat(t))
}

// Color functions
func (v Vec3) ConvertToRGB() *Color {
	r := int(COLOR_MAX * v.GetX())
	g := int(COLOR_MAX * v.GetY())
	b := int(COLOR_MAX * v.GetZ())
	return &Color{r, g, b}
}

func (c Color) String() string {
	return fmt.Sprintf("%d %d %d", c.ColorX, c.ColorY, c.ColorZ)
}

// Defining "class" methods for Vec3
func (v Vec3) GetX() float64 {
	return v.X
}
func (v Vec3) GetY() float64 {
	return v.Y
}
func (v Vec3) GetZ() float64 {
	return v.Z
}
// Go doesn't have operator overloading, so we have to define these methods
func (v Vec3) Negate() Vec3 {
	// Simulate the - operator overload (negation)
	return Vec3{-(v.X), -(v.Y), -(v.Z)}
}
func (v Vec3) IndeXAt(i int) float64 {
	// Simulate the [] operator overload
	if i == 0 {
		return v.X
	} else if i == 1 {
		return v.Y
	} else if i == 2 {
		return v.Z
	} else {
		return 0
	}
}

func (v *Vec3) PlusEqual(v2 Vec3) *Vec3 {
	v.Z += v2.Z
	v.Y += v2.Y
	v.Z += v2.Z
	return v
}

func (v *Vec3) TimesEqual(t float64) *Vec3 {
	v.X *= t
	v.Y *= t
	v.Z *= t
	return v
}

func (v Vec3) DivideEqual(t float64) *Vec3 {
	return v.TimesEqual(1 / t)
}

func (v Vec3) Length() float64 {
	return math.Sqrt(v.LengthSquared())
}
func (v Vec3) LengthSquared() float64 {
	return v.X*v.X + v.Y*v.Y + v.Z*v.Z
}
// Simulating the << overload, but writing our own String() method
func (v Vec3) String() string {
	return fmt.Sprintf("%f %f %f", v.X, v.Y, v.Z)
}
func (v Vec3) Add(v2 Vec3) Vec3 {
	return Vec3{v.X + v2.X, v.Y + v2.Y, v.Z + v2.Z}
}

func (v Vec3) Subtract(v2 Vec3) *Vec3 {
	return &Vec3{v.X - v2.X, v.Y - v2.Y, v.Z - v2.Z}
}

func (v Vec3) MultiplyVec(v2 Vec3) *Vec3 {
	return &Vec3{v.X * v2.X, v.Y * v2.Y, v.Z * v2.Z}
}

func (v Vec3) MultiplyFloat(t float64) *Vec3 {
	return &Vec3{v.X * t, v.Y * t, v.Z * t}
}

func (v Vec3) DivideFloat(t float64) *Vec3 {
	return v.MultiplyFloat(1 / t)
}

func (v Vec3) Dot(v2 Vec3) float64 {
	return v.X*v2.X + v.Y*v2.Y + v.Z*v2.Z
}

func (v Vec3) Cross(v2 Vec3) *Vec3 {
	return &Vec3{v.Y*v2.Z - v.Z*v2.Y, v.Z*v2.X - v.X*v2.Z, v.X*v2.Y - v.Y*v2.X}
}

func (v Vec3) UnitVector() *Vec3 {
	return v.DivideFloat(v.Length())
}

func HitSphere(center *Point3, radius float64, r *Ray) bool {
	oc := r.GetOrigin().Subtract(*center)
	a := r.GetDirection().Dot(r.GetDirection())
	b := 2.0 * oc.Dot(r.GetDirection())
	c := oc.Dot(*oc) - radius*radius
	discriminant := b*b - 4*a*c

	return (discriminant >= 0)
}

func RayColor(r *Ray) Color {
	if HitSphere(&Point3{X: 0, Y: 0, Z: -1}, 0.5, r) {
		computedValue := Vec3{X: 1.0, Y: 0.0, Z: 0.0}
		return *computedValue.ConvertToRGB()
	}
	unit_direction := r.GetDirection().UnitVector()
	a := 0.5 * (unit_direction.GetY() + 1.0)
	startValue := Vec3{X: 1.0, Y: 1.0, Z: 1.0}
	endValue := Vec3{X: 0.5, Y: 0.7, Z: 1.0}
	computedValue := startValue.MultiplyFloat(1.0 - a).Add(*endValue.MultiplyFloat(a))
	return *computedValue.ConvertToRGB()
}

func main() {
	// Image
	aspect_ratio := 16.0 / 9.0
	var image_width int = 400
	var image_height int = int(math.Max(float64(image_width)/aspect_ratio, 1.0))

	// Camera
	focal_length := 1.0
	viewport_height := 2.0
	viewport_width := viewport_height * (float64(image_width) / float64(image_height))
	camera_center := Point3{X: 0, Y: 0, Z: 0}

	viewport_u := Vec3{X: viewport_width, Y: 0, Z: 0}
	viewport_v := Vec3{X: 0, Y: -viewport_height, Z: 0}

	pixel_delta_u := viewport_u.DivideFloat(float64(image_width))
	pixel_delta_v := viewport_v.DivideFloat(float64(image_height))

	viewport_upper_left := camera_center.Subtract(Vec3{X: 0, Y: 0, Z: focal_length}).Subtract(*viewport_u.DivideFloat(2)).Subtract(*viewport_v.DivideFloat(2))
	pixel00_loc := viewport_upper_left.Add(*pixel_delta_u.DivideFloat(2)).Add(*pixel_delta_v.DivideFloat(2))

	// Render
	fmt.Println("P3")
	fmt.Println(strconv.Itoa(image_width) + " " + strconv.Itoa(image_height))
	fmt.Println("255")
	for j := 0; j < image_height; j++ {
		log.Println("Scanlines remaining: " + strconv.Itoa(image_height-j))
		for i := 0; i < image_width; i++ {
			pixel_center := pixel00_loc.Add(*pixel_delta_u.MultiplyFloat(float64(i))).Add(*pixel_delta_v.MultiplyFloat(float64(j)))
			ray_direction := pixel_center.Subtract(camera_center)
			ray := Ray{Origin: camera_center, Direction: *ray_direction}
			pixel_color := RayColor(&ray)

			fmt.Println(pixel_color.String())
		}
	}
	log.Println("Done!")
}