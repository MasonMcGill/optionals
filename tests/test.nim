import unittest
import optionals

test "Test 0":
  assert something(1).value == 1
  assert something(2.0) == something(2.0)
  assert something(2.0) != nothing(float)
  assert nothing(float) == nothing(float)
  assert something("3").map(len) == something(1)
  assert nothing(string).map(len) == nothing(int)
  assert ($something("3") == "something(3)")
  assert ($nothing(string) == "nothing(string)")

test "Test 1":
  let opt = something "my-value"
  assert opt.hasValue
  assert opt.value == "my-value"

test "Test 2":
  let opt = nothing string
  assert (not opt.hasValue)

test "Test 3":
  let a = something 'a'
  assert a == something 'a'
  assert a != something 'b'
  assert a != nothing char

test "Test 4":
  assert something(1.0).map(`-`) == something(-1.0)
  assert nothing(float).map(`-`) == nothing(float)
  assert something("hi").map(len) == something(2)
  assert nothing(string).map(len) == nothing(int)

test "Test 5":
  assert ($something(10) == "something(10)")
  assert ($nothing(string) == "nothing(string)")
