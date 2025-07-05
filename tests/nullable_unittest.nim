# nullable_unittest.nim
import unittest
import nullable # Tu módulo FastNullable optimizado

type
  Person* = object
    name*: string
    age*: int

suite "FastNullable Basic Tests":
  test "Creation and value access":
    let val = some(42)
    let noVal = none[int]()
    
    check val.hasValue
    check not noVal.hasValue
    check val.value == 42
    
    # Test para verificar que se lance ValueError al acceder a valor null
    var errorCaught = false
    try:
      discard noVal.value
    except ValueError:
      errorCaught = true
    check errorCaught
  
  test "Null checks":
    let val = some("hello")
    let noVal = none[string]()
    
    check not val.isNull
    check noVal.isNull
  
  test "Equality operator":
    let a = some(100)
    let b = some(100)
    let c = some(200)
    let n1 = none[int]()
    let n2 = none[int]()
    
    check a == b
    check a != c
    check n1 == n2
    check a != n1
  
  test "Functional programming helpers":
    let val = some(10)
    let noVal = none[int]()
    
    # Map: int -> string
    let mapped = val.map(proc(x: int): string = $x & "!")
    let mappedNone = noVal.map(proc(x: int): string = $x & "!")
    
    # FlatMap: int -> FastNullable[string]
    let flatMapped = val.flatMap(proc(x: int): FastNullable[string] = some($x & "?"))
    
    # GetOrElse: el tipo debe coincidir con el tipo del FastNullable
    let defaultVal = val.getOrElse(0)  # int -> int
    let defaultNone = noVal.getOrElse(-1)  # int -> int
    
    check mapped.hasValue and mapped.value == "10!"
    check not mappedNone.hasValue
    check flatMapped.hasValue and flatMapped.value == "10?"
    check defaultVal == 10  # El valor original
    check defaultNone == -1  # El valor por defecto
  
  test "String representation":
    let val = some(7)
    let noVal = none[int]()
    
    check $val == "Some(7)"
    check $noVal == "None"

suite "FastNullable with Person type":
  test "Person creation and access":
    let p = some(Person(name: "Alice", age: 30))
    let pNull = none[Person]()
    
    check p.hasValue
    check not pNull.hasValue
    check p.value.name == "Alice"
    check pNull.isNull
  
  test "Person equality":
    let p1 = some(Person(name: "Bob", age: 25))
    let p2 = some(Person(name: "Bob", age: 25))
    let p3 = some(Person(name: "Charlie", age: 40))
    let pNull1 = none[Person]()
    let pNull2 = none[Person]()
    
    check p1 == p2
    check p1 != p3
    check pNull1 == pNull2
    check p1 != pNull1

suite "FastNullable Advanced Tests":
  test "Type aliases work correctly":
    let fastInt = createFastNullableInt(100)
    let fastString = createFastNullableString("test")
    let nullInt = createFastNullInt()
    let nullString = createFastNullString()
    
    check fastInt.hasValue
    check fastString.hasValue
    check not nullInt.hasValue
    check not nullString.hasValue
    
    check getFastIntValue(fastInt) == 100
    check getFastStringValue(fastString) == "test"
  
  test "Chaining operations":
    let val = some(5)
    let result = val
      .map(proc(x: int): int = x * 2)
      .map(proc(x: int): string = $x & " doubled")
    
    check result.hasValue
    check result.value == "10 doubled"
  
  test "FlatMap with null results":
    let val = some(10)
    let result = val.flatMap(proc(x: int): FastNullable[string] = 
      if x > 5: some($x) else: none[string]())
    
    check result.hasValue
    check result.value == "10"
    
    let val2 = some(3)
    let result2 = val2.flatMap(proc(x: int): FastNullable[string] = 
      if x > 5: some($x) else: none[string]())
    
    check not result2.hasValue
    