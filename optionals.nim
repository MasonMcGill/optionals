import typetraits

#==============================================================================
# Optionals

type Optional*[Value] = object
  ## [doc]
  case hasValue*: bool
  of true: value*: Value
  of false: discard

proc something*[Value](val: Value): Optional[Value] {.noInit.} =
  ## [doc]
  Optional[Value](hasValue: true, value: val)

proc nothing*(Value: typedesc): auto {.noInit.} =
  ## [doc]
  Optional[Value](hasValue: false)

converter toValue*[Value](opt: Optional[Value]): Value {.noInit.} =
  ## [doc]
  opt.value

converter toOptional*[Value](val: Value): Optional[Value] {.noInit.} =
  ## [doc]
  something(val)

proc `==`*[Value](opt0, opt1: Optional[Value]): bool {.noInit.} =
  ## [doc]
  (opt0.hasValue and opt1.hasValue and opt0.value == opt1.value or
   not opt0.hasValue and not opt1.hasValue)

template map*[Value](opt: Optional[Value], pred: expr): expr =
  ## [doc]
  if opt.hasValue: something(pred(opt))
  else: nothing(type(pred(opt)))

proc `$`*[Value](opt: Optional[Value]): string {.noInit.} =
  ## [doc]
  if opt.hasValue: "something(" & $opt.value & ")"
  else: "nothing(" & Value.name & ")"

#==============================================================================
# Tests

when isMainModule:
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
