package tests

import (
	"std"

	"gno.land/p/demo/nestedpkg"
	rsubtests "gno.land/r/demo/tests/subtests"
)

var counter int

func IncCounter(cur realm) {
	counter++
}

func Counter(cur realm) int {
	return counter
}

func CurrentRealmPath(cur realm) string {
	return std.CurrentRealm().PkgPath()
}

var initOriginCaller = std.OriginCaller()

func InitOriginCaller(cur realm) std.Address {
	return initOriginCaller
}

func CallAssertOriginCall(cur realm) {
	std.AssertOriginCall()
}

func CallIsOriginCall(cur realm) bool {
	// XXX: consider return !std.PreviousRealm().IsCode()
	return std.PreviousRealm().IsUser()
}

func CallSubtestsAssertOriginCall(cur realm) {
	rsubtests.CallAssertOriginCall(cross)
}

func CallSubtestsIsOriginCall(cur realm) bool {
	return rsubtests.CallIsOriginCall(cross)
}

//----------------------------------------
// Test structure to ensure cross-realm modification is prevented.

type TestRealmObject struct {
	Field string
}

var TestRealmObjectValue TestRealmObject

func ModifyTestRealmObject(cur realm, t *TestRealmObject) {
	t.Field += "_modified"
}

func (t *TestRealmObject) Modify() {
	t.Field += "_modified"
}

//----------------------------------------
// Test helpers to test a particular realm bug.

type TestNode struct {
	Name  string
	Child *TestNode
}

var (
	gTestNode1 *TestNode
	gTestNode2 *TestNode
	gTestNode3 *TestNode
)

func InitTestNodes(cur realm) {
	gTestNode1 = &TestNode{Name: "first"}
	gTestNode2 = &TestNode{Name: "second", Child: &TestNode{Name: "second's child"}}
}

func ModTestNodes(cur realm) {
	tmp := &TestNode{}
	tmp.Child = gTestNode2.Child
	gTestNode3 = tmp // set to new-real
	// gTestNode1 = tmp.Child // set back to original is-real
	gTestNode3 = nil // delete.
}

func PrintTestNodes() {
	println(gTestNode2.Child.Name)
}

func GetPreviousRealm(cur realm) std.Realm {
	return std.PreviousRealm()
}

func GetRSubtestsPreviousRealm(cur realm) std.Realm {
	return rsubtests.GetPreviousRealm(cross)
}

func Exec(fn func()) {
	// no realm switching.
	fn()
}

func ExecSwitch(cur realm, fn func()) {
	fn()
}

func IsCallerSubPath(cur realm) bool {
	return nestedpkg.IsCallerSubPath()
}

func IsCallerParentPath(cur realm) bool {
	return nestedpkg.IsCallerParentPath()
}

func HasCallerSameNamespace(cur realm) bool {
	return nestedpkg.IsSameNamespace()
}
