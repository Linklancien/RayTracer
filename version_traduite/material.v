interface Material{
	scatter(r_in Ray, rec HitRecord, attenuation Vector, mut scattered Ray) bool
}