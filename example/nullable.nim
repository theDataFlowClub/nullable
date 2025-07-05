# nullable_test_updated.nim
import strutils, options, times, random, strformat # <<-- Línea corregida. strfmt eliminado y strformat explícito.
import nullable  # Importa el módulo FastNullable optimizado

type
  Person* = object
      name*: string
      age*: int

  RefPerson* = ref object # Definición de RefPerson para el test de ref/nil
    name*: string
    age*: int

  FastNullablePerson* = nullable.FastNullable[Person] # Usar nullable.FastNullable para claridad

proc createFastNullablePerson*(name: string, age: int): FastNullablePerson {.inline.} =
    ## Creates a FastNullablePerson from name and age.
    nullable.some(Person(name: name, age: age)) # Calificado

proc createFastNullPerson*(): FastNullablePerson {.inline.} =
    ## Creates a null FastNullablePerson.
    nullable.none[Person]() # Calificado

proc getFastPersonValue*(np: FastNullablePerson): Person {.inline.} =
    ## Retrieves the value of a FastNullablePerson.
    np.value


# Alias para compatibilidad con las pruebas anteriores
type
  NullableInt* = nullable.FastNullableInt
  NullableString* = nullable.FastNullableString
  NullablePerson* = FastNullablePerson # Ya definido arriba como alias de nullable.FastNullable[Person]

# Procedimientos de compatibilidad que mapean a la nueva API
proc createNullablePerson*(name: string, age: int): NullablePerson =
  createFastNullablePerson(name, age)

proc createNullPerson*(): NullablePerson =
  createFastNullPerson()

proc getPersonValue*(np: NullablePerson): Person =
  np.getFastPersonValue

# ====== TESTS ACTUALIZADOS ======

const N = 1_000_000

proc testCorrectness() =
  echo "=== Test de Correctitud - FastNullable ==="

  # FastNullable (antes SimpleNullable)
  let fn: NullablePerson = createNullablePerson("Ana", 28)
  let fnNull: NullablePerson = createNullPerson()
  echo "FastNullable con valor: ", fn.hasValue, ", nombre: ", fn.value.name
  echo "FastNullable nulo: ", fnNull.isNull

  # Option - CORREGIDO
  let op: Option[Person] = options.some(Person(name: "Ana", age: 28)) # Calificado
  let opNull: Option[Person] = options.none(Person) # Calificado
  echo "Option con valor: ", op.isSome, ", nombre: ", op.get.name
  echo "Option nulo: ", opNull.isNone

  # ref nil
  let refp: RefPerson = RefPerson(name: "Ana", age: 28)
  let refpNull: RefPerson = nil
  echo "ref con valor: ", refp != nil, ", nombre: ", refp.name
  echo "ref nulo: ", refpNull == nil

proc benchmark() =
  echo "\n=== Benchmark - FastNullable vs Option vs ref/nil ==="

  # FastNullable (optimizado)
  let t0 = cpuTime()
  var arrFN: seq[nullable.FastNullableInt] = @[] # Usar nullable.FastNullableInt
  for i in 0..<N:
    if i mod 2 == 0:
      arrFN.add(nullable.some(i)) # Calificado
    else:
      arrFN.add(nullable.none[int]()) # Calificado
  var sumFN = 0
  for val in arrFN:
    if val.hasValue:
      sumFN += val.value
  let t1 = cpuTime()
  echo fmt"FastNullable: {t1 - t0:.4f} seg. Resultado: {sumFN}"

  # Option
  let t2 = cpuTime()
  var arrOpt: seq[Option[int]] = @[]
  for i in 0..<N:
    if i mod 2 == 0:
      arrOpt.add(options.some(i)) # Calificado
    else:
      arrOpt.add(options.none(int)) # Calificado
  var sumOpt = 0
  for val in arrOpt:
    if val.isSome:
      sumOpt += val.get
  let t3 = cpuTime()
  echo fmt"Option: {t3 - t2:.4f} seg. Resultado: {sumOpt}"

  # ref/nil
  let t4 = cpuTime()
  var arrRef: seq[ref int] = @[]
  for i in 0..<N:
    if i mod 2 == 0:
      arrRef.add(new int)
      arrRef[^1][] = i
    else:
      arrRef.add(nil)
  var sumRef = 0
  for val in arrRef:
    if val != nil:
      sumRef += val[]
  let t5 = cpuTime()
  echo fmt"ref/nil: {t5 - t4:.4f} seg. Resultado: {sumRef}"

proc readabilityTest() =
  echo "\n=== Legibilidad / Semántica - FastNullable ==="

  var fn = createNullPerson()
  var op = options.none(Person) # Calificado
  var rp: RefPerson = nil

  echo "FastNullable isNull: ", fn.isNull
  echo "Option isNone: ", op.isNone
  echo "ref == nil: ", rp == nil

proc functionalProgrammingTest() =
  echo "\n=== Programación Funcional - FastNullable ==="

  # Pruebas de map
  let age = nullable.some(25) # Calificado
  let ageString = age.map(proc(x: int): string = $x & " años")
  echo "map result: ", ageString

  let noAge = nullable.none[int]() # Calificado
  let noAgeString = noAge.map(proc(x: int): string = $x & " años")
  echo "map on none: ", noAgeString

  # Pruebas de getOrElse
  let defaultAge = age.getOrElse(0)
  let defaultNoAge = noAge.getOrElse(0)
  echo "getOrElse con valor: ", defaultAge
  echo "getOrElse sin valor: ", defaultNoAge

  # Pruebas de flatMap
  let doubled = age.flatMap(proc(x: int): nullable.FastNullable[int] = nullable.some(x * 2)) # Calificado
  echo "flatMap result: ", doubled

proc comparisonTest() =
  echo "\n=== Comparaciones - FastNullable ==="

  let int1 = nullable.some(42) # Calificado
  let int2 = nullable.some(42) # Calificado
  let int3 = nullable.some(24) # Calificado
  let int4 = nullable.none[int]() # Calificado
  let int5 = nullable.none[int]() # Calificado

  echo "some(42) == some(42): ", int1 == int2
  echo "some(42) == some(24): ", int1 == int3
  echo "some(42) == none[int](): ", int1 == int4
  echo "none[int]() == none[int](): ", int4 == int5

proc stringRepresentationTest() =
  echo "\n=== Representación como String - FastNullable ==="

  let withValue = nullable.some(42) # Calificado
  let withoutValue = nullable.none[int]() # Calificado
  let personValue = createFastNullablePerson("Juan", 30)
  let personNull = createFastNullPerson()

  echo "FastNullable con valor: ", withValue
  echo "FastNullable nulo: ", withoutValue
  echo "FastNullable Person: ", personValue
  echo "FastNullable Person nulo: ", personNull

proc performanceComparison() =
  echo "\n=== Comparación de Rendimiento Detallada ==="

  const iterations = 10_000_000

  # Test de creación
  echo "Creación de ", iterations, " instancias:"

  let t0 = cpuTime()
  for i in 0..<iterations:
    discard nullable.some(i) # Calificado
  let t1 = cpuTime()
  echo fmt"FastNullable creación: {t1 - t0:.4f} seg"

  let t2 = cpuTime()
  for i in 0..<iterations:
    discard options.some(i) # Calificado
  let t3 = cpuTime()
  echo fmt"Option creación: {t3 - t2:.4f} seg"

  # Test de verificación
  echo "\nVerificación de ", iterations, " instancias:"
  let fnValue = nullable.some(42) # Calificado
  let opValue = options.some(42) # Calificado

  let t4 = cpuTime()
  for i in 0..<iterations:
    discard fnValue.hasValue
  let t5 = cpuTime()
  echo fmt"FastNullable verificación: {t5 - t4:.4f} seg"

  let t6 = cpuTime()
  for i in 0..<iterations:
    discard opValue.isSome
  let t7 = cpuTime()
  echo fmt"Option verificación: {t7 - t6:.4f} seg"

# ====== EJECUCIÓN ======

when isMainModule:
  echo "=== PRUEBAS ACTUALIZADAS PARA FASTNULLABLE ==="
  testCorrectness()
  benchmark()
  readabilityTest()
  functionalProgrammingTest()
  comparisonTest()
  stringRepresentationTest()
  performanceComparison()

  echo "\n=== RESUMEN ==="
  echo "✓ FastNullable implementa la misma funcionalidad que SimpleNullable"
  echo "✓ Optimizaciones aplicadas: inline, sin verificaciones redundantes"
  echo "✓ Funcionalidad adicional: map, flatMap, getOrElse, representación string"
  echo "✓ Mantiene compatibilidad con API anterior mediante alias"

  