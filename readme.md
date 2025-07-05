# Nullable for Nim

A high-performance nullable type implementation for Nim, designed for explicit null handling without relying on `Option[T]` or reference types. Optimized for functional programming patterns with minimal runtime overhead.

## Features

- **Zero-cost abstractions**: Inlined operations with discriminated unions
- **Functional programming**: Built-in `map`, `flatMap`, and `getOrElse` operations
- **Type safety**: Compile-time null checking with runtime safety in debug mode
- **Memory efficient**: Minimal footprint using tagged unions
- **Comprehensive**: Works with primitives, objects, collections, and custom types
- **Well-tested**: Extensive test suite covering edge cases and performance scenarios

## Installation

Simply copy `nullable.nim` to your project or add it to your Nim package.

## Quick Start

```nim
import nullable

# Creating nullable values
let age = some(25)
let name = none[string]()

# Checking for values
if age.hasValue:
  echo "Age: ", age.value  # Age: 25

if name.isNull:
  echo "Name not provided"

# Using defaults
let displayName = name.getOrElse("Anonymous")
echo displayName  # Anonymous
```

## Functional Programming

```nim
import nullable

let number = some(10)

# Transform values
let doubled = number.map(proc(x: int): int = x * 2)
echo doubled  # Some(20)

# Chain operations
let result = number
  .map(proc(x: int): int = x * 3)
  .map(proc(x: int): string = "Result: " & $x)
echo result  # Some(Result: 30)

# Flat mapping
let validated = number.flatMap(proc(x: int): FastNullable[string] = 
  if x > 0: some($x) else: none[string]())
echo validated  # Some(10)
```

## Working with Custom Types

```nim
import nullable

type
  Person = object
    name: string
    age: int

let person = some(Person(name: "Alice", age: 30))
let noPerson = none[Person]()

# Type-safe access
if person.hasValue:
  echo person.value.name  # Alice

# Functional operations
let personInfo = person.map(proc(p: Person): string = 
  p.name & " is " & $p.age & " years old")
echo personInfo  # Some(Alice is 30 years old)
```

## Type Aliases

For better readability, the module provides common type aliases:

```nim
import nullable

let count: FastNullableInt = createFastNullableInt(42)
let message: FastNullableString = createFastNullableString("Hello")
let flag: FastNullableBool = some(true)

# Access with convenience functions
if count.hasValue:
  echo getFastIntValue(count)  # 42
```

## API Reference

### Core Types

- `FastNullable[T]` - Generic nullable type
- `FastNullableInt`, `FastNullableString`, `FastNullableFloat`, `FastNullableBool` - Common type aliases

### Constructors

- `some[T](value: T)` - Create a nullable with a value
- `none[T]()` - Create an empty nullable

### Checking Values

- `hasValue(): bool` - Returns true if contains a value
- `isNull(): bool` - Returns true if empty
- `value(): T` - Gets the value (unsafe - check hasValue first)

### Functional Operations

- `map[U](f: T -> U): FastNullable[U]` - Transform the value if present
- `flatMap[U](f: T -> FastNullable[U]): FastNullable[U]` - Transform and flatten
- `getOrElse(default: T): T` - Get value or return default

### Utility

- `$nullable` - String representation (`Some(value)` or `None`)
- `==` - Equality comparison

## Performance

Nullable is designed for performance:

- Uses discriminated unions for minimal memory overhead
- All operations are inlined for zero-cost abstractions
- No heap allocations for the nullable wrapper itself
- Efficient branching with simple boolean checks

```bash

=== Benchmark - FastNullable vs Option vs ref/nil ===
FastNullable: 0.0832 seg. Resultado: 249999500000
Option: 0.0596 seg. Resultado: 249999500000
ref/nil: 0.1063 seg. Resultado: 249999500000

```

## Testing

Run the comprehensive test suite:

```bash
nim c -r nullable_unittest.nim
```

The test suite includes:

- Basic functionality tests
- Edge case handling
- Complex type operations
- Functional programming patterns
- Performance verification
- Error handling in debug mode

## Why FastNullable?

While Nim's `Option[T]` is excellent for many use cases, FastNullable offers:

- **Explicit null semantics** without reference types
- **Extended functional API** with `flatMap` and chaining
- **Performance optimization** for critical paths
- **Custom domain modeling** with type aliases
- **Clear intent** for nullable vs optional semantics

## Contributing

Contributions are welcome! Please ensure:

- All tests pass
- New features include corresponding tests
- Code follows the existing style
- Performance implications are considered

## License

MIT License - see LICENSE file for details.

## Credits

Developed by David Ochoa with assistance from AI tools during development and optimization.
