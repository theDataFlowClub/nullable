
## nullable.nim
## 
## Nullable – Optimized nullable type for Nim
##
## Author: David Ochoa
## Optimizations by: Claude Sonet 4
##
## This module defines an efficient and expressive way to represent optional values
## (nullable types) in Nim using a tagged union. It offers functional utilities
## and avoids runtime overhead by minimizing field usage and maximizing inlining.
##
## Core design goals:
## - High performance
## - Semantic clarity
## - Functional-style operations
## - Compact memory layout
## - API consistency for DSLs and higher-level usage
##

import strutils

# ===== GENERIC DEFINITION: HIGHLY OPTIMIZED =====

type
  ## FastNullable[T] is a discriminated union that represents either:
  ## - a present value of type T (when `hasVal = true`)
  ## - a null state with no associated data (when `hasVal = false`)
  ##
  ## Optimization: the null state does not store anything.
  FastNullable*[T] = object
    case hasVal: bool
    of true:
      data: T         ## Stores the value when present
    of false:
      discard         ## Nothing is stored when null

# ===== CORE CONSTRUCTORS & ACCESSORS =====

proc some*[T](value: T): FastNullable[T] {.inline.} =
  ## Creates a FastNullable containing a valid value.
  ## Example: `some(42)`
  FastNullable[T](hasVal: true, data: value)

proc none*[T](): FastNullable[T] {.inline.} =
  ## Creates a null (empty) FastNullable.
  ## Example: `none[int]()`
  FastNullable[T](hasVal: false)

proc hasValue*[T](fn: FastNullable[T]): bool {.inline.} =
  ## Returns true if the FastNullable contains a value.
  ## Example: `myNullable.hasValue`
  fn.hasVal

proc isNull*[T](fn: FastNullable[T]): bool {.inline.} =
  ## Returns true if the FastNullable is null (contains no value).
  ## Optimization: no address checks needed.
  ## Example: `myNullable.isNull`
  not fn.hasVal

proc value*[T](fn: FastNullable[T]): T {.inline.} =
  ## Retrieves the contained value.
  ## IMPORTANT: Must check `hasValue` before calling in release mode.
  ## Throws ValueError in debug mode if null.
  when not defined(release):
    if not fn.hasVal:
      raise newException(ValueError, "FastNullable is null — check hasValue before accessing.")
  fn.data

proc `==`*[T](a, b: FastNullable[T]): bool {.inline.} =
  ## Compares two FastNullable instances for equality.
  ## Returns true if both contain equal values, or both are null.
  if a.hasVal and b.hasVal:
    a.data == b.data
  else:
    a.hasVal == b.hasVal

# ===== TYPE ALIASES FOR COMMON USAGE =====

type
  FastNullableInt* = FastNullable[int]
  FastNullableString* = FastNullable[string]
  FastNullableFloat* = FastNullable[float]
  FastNullableBool* = FastNullable[bool]

# ===== TYPE-SPECIFIC CONVENIENCE FUNCTIONS =====

proc createFastNullableInt*(value: int): FastNullableInt {.inline.} =
  ## Creates a FastNullableInt with a value.
  some(value)

proc createFastNullInt*(): FastNullableInt {.inline.} =
  ## Creates a null FastNullableInt.
  none[int]()

proc getFastIntValue*(ni: FastNullableInt): int {.inline.} =
  ## Gets the value of a FastNullableInt.
  ## IMPORTANT: must check hasValue before using.
  ni.value

proc createFastNullableString*(value: string): FastNullableString {.inline.} =
  ## Creates a FastNullableString with a value.
  some(value)

proc createFastNullString*(): FastNullableString {.inline.} =
  ## Creates a null FastNullableString.
  none[string]()

proc getFastStringValue*(ns: FastNullableString): string {.inline.} =
  ## Gets the value of a FastNullableString.
  ## IMPORTANT: must check hasValue before using.
  ns.value

# ===== FUNCTIONAL PROGRAMMING EXTENSIONS =====

proc map*[T, U](fn: FastNullable[T], f: proc(x: T): U): FastNullable[U] {.inline.} =
  ## Transforms the value using `f` if present, or returns none.
  ## Example: `nullable.map(proc(x: int): string = $x)`
  if fn.hasVal:
    some(f(fn.data))
  else:
    none[U]()

proc flatMap*[T, U](fn: FastNullable[T], f: proc(x: T): FastNullable[U]): FastNullable[U] {.inline.} =
  ## Applies a function that returns a FastNullable, flattening the result.
  ## Avoids nesting. Example: `nullable.flatMap(proc(x: int): FastNullable[string] = some($x))`
  if fn.hasVal:
    f(fn.data)
  else:
    none[U]()

proc getOrElse*[T](fn: FastNullable[T], defaultValue: T): T {.inline.} =
  ## Returns the value if present, or `defaultValue` if null.
  ## Example: `nullable.getOrElse(0)`
  if fn.hasVal:
    fn.data
  else:
    defaultValue

proc `$`*[T](fn: FastNullable[T]): string =
  ## Converts FastNullable to a human-readable string.
  ## Example: `Some(42)` or `None`
  if fn.hasVal:
    "Some(" & $fn.data & ")"
  else:
    "None"

# ===== USAGE EXAMPLES AND DEMO =====

when isMainModule:

  type
    Person* = object
      name*: string
      age*: int

    FastNullablePerson* = FastNullable[Person]
    FastNullableSeq* = FastNullable[seq[int]]
    FastNullableArray* = FastNullable[array[5, string]]

  proc createFastNullablePerson*(name: string, age: int): FastNullablePerson {.inline.} =
    ## Creates a FastNullablePerson from name and age.
    some(Person(name: name, age: age))

  proc createFastNullPerson*(): FastNullablePerson {.inline.} =
    ## Creates a null FastNullablePerson.
    none[Person]()

  proc getFastPersonValue*(np: FastNullablePerson): Person {.inline.} =
    ## Retrieves the value of a FastNullablePerson.
    np.value

  echo "=== FastNullable Ultra-Optimized ==="

  var nullableAge = createFastNullableInt(25)
  var nullableName = createFastNullString()

  echo "nullableAge has value: ", nullableAge.hasValue
  echo "nullableName is null: ", nullableName.isNull

  if nullableAge.hasValue:
    echo "Age: ", nullableAge.getFastIntValue

  var directInt = some(42)
  var directString = none[string]()

  echo "directInt has value: ", directInt.hasValue
  echo "directString is null: ", directString.isNull

  var person1 = createFastNullablePerson("Juan", 30)
  var person2 = createFastNullPerson()

  echo "person1 has value: ", person1.hasValue
  echo "person2 is null: ", person2.isNull

  if person1.hasValue:
    let p = person1.getFastPersonValue
    echo "Person: ", p.name, " (", p.age, " years)"

  var nullableList: FastNullableSeq = some(@[1, 2, 3, 4, 5])
  var emptyList: FastNullableSeq = none[seq[int]]()

  echo "nullableList has value: ", nullableList.hasValue
  echo "emptyList is null: ", emptyList.isNull

  if nullableList.hasValue:
    echo "List: ", nullableList.value

  echo "\n=== Optimized Comparisons ==="
  var int1 = some(42)
  var int2 = some(42)
  var int3 = none[int]()
  var int4 = none[int]()

  echo "some(42) == some(42): ", int1 == int2
  echo "none[int]() == none[int](): ", int3 == int4
  echo "some(42) == none[int](): ", int1 == int3

  echo "\n=== Functional Programming ==="
  let ageString = nullableAge.map(proc(x: int): string = $x & " years")
  echo "Age as string: ", ageString

  let defaultName = nullableName.getOrElse("Unknown")
  echo "Default name: ", defaultName

  echo "\n=== Debugging Output ==="
  echo "nullableAge: ", nullableAge
  echo "nullableName: ", nullableName
  