interface material{
	scatter(r_in Ray, rec HitRecord, attenuation Vector, scattered Ray) bool
}