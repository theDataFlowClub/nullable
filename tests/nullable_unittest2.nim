# nullable_unittest.nim
import unittest
import strutils  # Necesario para repeat()
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

suite "FastNullable Edge Cases and Robustness":
  test "Zero and negative values":
    let zero = some(0)
    let negative = some(-42)
    let zeroFloat = some(0.0)
    let negativeFloat = some(-3.14)
    
    check zero.hasValue
    check negative.hasValue
    check zeroFloat.hasValue
    check negativeFloat.hasValue
    
    check zero.value == 0
    check negative.value == -42
    check zeroFloat.value == 0.0
    check negativeFloat.value == -3.14
  
  test "Empty strings and collections":
    let emptyStr = some("")
    let emptySeq = some(newSeq[int]())
    let emptyArray = some([0, 0, 0, 0, 0])  # Array inicializado
    
    check emptyStr.hasValue
    check emptySeq.hasValue
    check emptyArray.hasValue
    
    check emptyStr.value == ""
    check emptySeq.value.len == 0
    check emptyArray.value.len == 5
  
  test "Boolean values (true and false)":
    let trueVal = some(true)
    let falseVal = some(false)
    let nullBool = none[bool]()
    
    check trueVal.hasValue
    check falseVal.hasValue
    check not nullBool.hasValue
    
    check trueVal.value == true
    check falseVal.value == false
    check trueVal.getOrElse(false) == true
    check falseVal.getOrElse(true) == false
    check nullBool.getOrElse(true) == true
  
  test "Complex nested structures":
    type
      NestedData = object
        values: seq[int]
        metadata: string
    
    let complexData = some(NestedData(
      values: @[1, 2, 3, 4, 5],
      metadata: "test data"
    ))
    
    check complexData.hasValue
    check complexData.value.values.len == 5
    check complexData.value.metadata == "test data"
    
    # Test mapping over complex data
    let mapped = complexData.map(proc(x: NestedData): int = x.values.len)
    check mapped.hasValue
    check mapped.value == 5
  
  test "Multiple map operations on null":
    let nullVal = none[int]()
    let result = nullVal
      .map(proc(x: int): int = x * 2)
      .map(proc(x: int): int = x + 10)
      .map(proc(x: int): string = $x)
    
    check not result.hasValue
    check result.getOrElse("default") == "default"
  
  test "FlatMap chain with mixed results":
    let val = some(10)
    
    # Cadena donde el primer flatMap devuelve some, el segundo none
    let result1 = val
      .flatMap(proc(x: int): FastNullable[int] = some(x * 2))
      .flatMap(proc(x: int): FastNullable[int] = none[int]())
      .flatMap(proc(x: int): FastNullable[string] = some($x))
    
    check not result1.hasValue
    
    # Cadena donde todos devuelven some
    let result2 = val
      .flatMap(proc(x: int): FastNullable[int] = some(x * 2))
      .flatMap(proc(x: int): FastNullable[int] = some(x + 5))
      .flatMap(proc(x: int): FastNullable[string] = some($x))
    
    check result2.hasValue
    check result2.value == "25"  # (10 * 2) + 5 = 25
  
  test "Large values and memory efficiency":
    # Test con valores grandes para verificar eficiencia
    let largeInt = some(999999999)
    let largeString = some("x".repeat(1000))
    
    check largeInt.hasValue
    check largeString.hasValue
    check largeInt.value == 999999999
    check largeString.value.len == 1000
    
    # Verificar que las comparaciones funcionen con valores grandes
    let largeInt2 = some(999999999)
    let largeString2 = some("x".repeat(1000))
    
    check largeInt == largeInt2
    check largeString == largeString2

suite "FastNullable Error Handling and Debug":
  test "Error handling in debug mode":
    when not defined(release):
      let nullVal = none[int]()
      
      # Verificar que se lance error al acceder a valor null
      var errorCaught = false
      var errorMessage = ""
      try:
        discard nullVal.value
      except ValueError as e:
        errorCaught = true
        errorMessage = e.msg
      
      check errorCaught
      check "FastNullable is null" in errorMessage
  
  test "String representation edge cases":
    let longValue = some("This is a very long string that should be properly displayed")
    let specialChars = some("Special: !@#$%^&*()_+-=[]{}|;':\",./<>?")
    let multiline = some("Line 1\nLine 2\nLine 3")
    
    check $longValue == "Some(This is a very long string that should be properly displayed)"
    check $specialChars == "Some(Special: !@#$%^&*()_+-=[]{}|;':\",./<>?)"
    check $multiline == "Some(Line 1\nLine 2\nLine 3)"

suite "FastNullable Performance and Type Safety":
  test "Type consistency across operations":
    let intVal = some(42)
    let stringVal = some("hello")
    let floatVal = some(3.14)
    
    # Verificar que los tipos se mantengan consistentes
    let intMapped = intVal.map(proc(x: int): int = x * 2)
    let stringMapped = stringVal.map(proc(x: string): string = x & " world")
    let floatMapped = floatVal.map(proc(x: float): float = x * 2.0)
    
    check intMapped.value == 84
    check stringMapped.value == "hello world"
    check floatMapped.value == 6.28
  
  test "Equality with different types (should not compile, but test similar types)":
    let intVal1 = some(42)
    let intVal2 = some(42)
    let intVal3 = some(24)
    
    check intVal1 == intVal2
    check intVal1 != intVal3
    
    # Test con floats que tienen el mismo valor numérico
    let floatVal1 = some(42.0)
    let floatVal2 = some(42.0)
    
    check floatVal1 == floatVal2
  
  test "Complex functional pipeline":
    # Pipeline complejo que combina map, flatMap y getOrElse
    let input = some(5)
    
    let pipeline = input
      .map(proc(x: int): int = x * 2)  # 10
      .flatMap(proc(x: int): FastNullable[int] = 
        if x > 5: some(x + 10) else: none[int]())  # 20
      .map(proc(x: int): string = "Result: " & $x)  # "Result: 20"
    
    check pipeline.hasValue
    check pipeline.value == "Result: 20"
    
    # Pipeline que falla en el medio
    let failingPipeline = some(2)
      .map(proc(x: int): int = x * 2)  # 4
      .flatMap(proc(x: int): FastNullable[int] = 
        if x > 5: some(x + 10) else: none[int]())  # none (porque 4 <= 5)
      .map(proc(x: int): string = "Result: " & $x)  # none
    
    check not failingPipeline.hasValue
    check failingPipeline.getOrElse("Failed") == "Failed"
    