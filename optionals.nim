## The ``optionals`` module provides `option types
## <http://en.wikipedia.org/wiki/Option_type>`_ for representing entities whose
## value may be unknown or nonexistent.

import typetraits

#==============================================================================
# Definitions

type Optional*[Value] = object
  ## An object representing either a value of type ``Value`` of the absence of
  ## a value.
  case hasValue*: bool
  of true: value*: Value
  of false: discard

proc something*[Value](val: Value): Optional[Value] {.noInit.} =
  ## Construct an ``Optional[Value]`` initialized with ``val``.
  ##
  ## Example:
  ##
  ## .. code:: nim
  ##
  ##   let opt = something "my-value"
  ##   assert opt.hasValue
  ##   assert opt.value == "my-value"
  ##
  Optional[Value](hasValue: true, value: val)

proc nothing*(Value: typedesc): auto {.noInit.} =
  ## Construct an ``Optional[Value]`` without a value.
  ##
  ## Example:
  ##
  ## .. code:: nim
  ##
  ##   let opt = nothing string
  ##   assert (not opt.hasValue)
  ##
  Optional[Value](hasValue: false)

converter toOptional*[Value](val: Value): Optional[Value] {.noInit.} =
  ## (Implicitly) convert ``val`` to ``something(val)``.
  ##
  ## Example:
  ##
  ## .. code:: nim
  ##
  ##   let val = 5
  ##   let opt: Optional[int] = val
  ##   assert opt.hasValue
  ##   assert opt.value == 5
  ##
  something(val)

proc `==`*[Value](opt0, opt1: Optional[Value]): bool {.noInit.} =
  ## Test whether two optional values either (1) both have no value or (2) both
  ## have equal values.
  ##
  ## Example:
  ##
  ## .. code:: nim
  ##
  ##   let a = something 'a'
  ##   assert a == something 'a'
  ##   assert a != something 'b'
  ##   assert a != nothing char
  ##
  (opt0.hasValue and opt1.hasValue and opt0.value == opt1.value or
   not opt0.hasValue and not opt1.hasValue)

template map*[Value](opt: Optional[Value], op: expr): expr =
  ## If ``opt.hasValue``, return ``something`` initialized with the result of
  ## the operation ``op`` applied to ``opt.value``; otherwise, return
  ## ``nothing``, of the appropriate type.
  ##
  ## Example:
  ##
  ## .. code:: nim
  ##
  ##   assert something(1.0).map(`-`) == something(-1.0)
  ##   assert nothing(float).map(`-`) == nothing(float)
  ##   assert something("hi").map(len) == something(2)
  ##   assert nothing(string).map(len) == nothing(int)
  ##
  if opt.hasValue: something(op(opt.value))
  else: nothing(type(op(opt.value)))

proc `$`*[Value](opt: Optional[Value]): string {.noInit.} =
  ## Return a string in the form ``"something(...)"`` or ``"nothing(...)"``.
  ##
  ## Example:
  ##
  ## .. code:: nim
  ##
  ##   assert ($something(10) == "something(10)")
  ##   assert ($nothing(string) == "nothing(string)")
  ##
  if opt.hasValue: "something(" & $opt.value & ")"
  else: "nothing(" & Value.name & ")"

#==============================================================================
# Tests

when isMainModule:
  block:
    assert something(1).value == 1
    assert something(1).Value is int
    assert nothing(int).Value is int
    assert type(nothing(int)).Value is int
    assert something(2.0) == something(2.0)
    assert something(2.0) != nothing(float)
    assert nothing(float) == nothing(float)
    assert something("3").map(len) == something(1)
    assert nothing(string).map(len) == nothing(int)
    assert ($something("3") == "something(3)")
    assert ($nothing(string) == "nothing(string)")
  block:
    let opt = something "my-value"
    assert opt.hasValue
    assert opt.value == "my-value"
  block:
    let opt = nothing string
    assert (not opt.hasValue)
  block:
    let a = something 'a'
    assert a == something 'a'
    assert a != something 'b'
    assert a != nothing char
  block:
    assert something(1.0).map(`-`) == something(-1.0)
    assert nothing(float).map(`-`) == nothing(float)
    assert something("hi").map(len) == something(2)
    assert nothing(string).map(len) == nothing(int)
  block:
    assert ($something(10) == "something(10)")
    assert ($nothing(string) == "nothing(string)")
