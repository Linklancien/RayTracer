interface Truc {
	fonc(a int) bool
}
struct Bidule{
	x int
}
fn (b Bidule) fonc(a int) bool {
	return true
}
struct Chose {
	y f64
}
fn (b Chose) fonc(a int) bool {
	return false
}

fn main() {
	mut a := []Truc{}
	a << Bidule{2}
	a << Chose{-5.0}
	for elem in a {
		println('${elem} ${elem.fonc(2)}')
	}
}