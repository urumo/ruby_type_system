# RubyTypeSystem
### A Work in progress type system for Ruby

## Current state
* Ruby is a mature language with a lot of libraries and a lot of code written in it.
* Ruby is a dynamically typed language, which means that the type of a variable is not known until runtime or is known only in the mind of the developer.
* What ruby lacks is a type system, which is a set of rules that define what types are allowed in a program.
* Solutions like `Sorbet` and `RBS` exist, but they are not part of the language itself and are not widely used. They have their pros and cons.
* The problem with `RBS` is that you have to write a lot of boilerplate code to define types that are only a hint for you favorite IDE.
* The problem with `Sorbet` is that it's not very intuitive and you have to take time to learn and get used to the way it works.

## General idea
The RubyTypeSystem project aims to create an intuitive and easy-to-use type system for Ruby. The main ideas behind this project are:

1. **Intuitive Types**: The types used in this system come from the Ruby standard library. This makes the system intuitive for developers who are already familiar with Ruby.

2. **Type Inference**: The system will take care of most of the typing through type inference. This reduces the amount of type annotations that developers need to write, making the code cleaner and easier to read.

3. **Method Typing**: Despite the type inference, methods will still require typing. This ensures that the behavior of methods is clear and predictable.

4. **New Keywords**: The system introduces new keywords to describe interfaces, abstract classes, union types, and types in general. These keywords extend the Ruby language with powerful features for static typing.

## Some examples
### Type inference
```ruby
some_int: Integer = 1
some_float = some_method_that_returns_float # The compiler assumes a Float type
some_int + some_float # CompileTimeError
```
### Method typing
```ruby
def some_method(a: Integer, b: Integer): Integer
  a + b
end
```
A more experienced developer would argue "But how are we going to introduce default values for parameters" and that is a great question.
Let's take the following ruby code as an example:
```ruby
def a(some_val = 1)
  some_val + 1
end

def b(key: 'key', value: 'value')
  "#{key}: #{value}"
end
```
In this example we have two methods, both have parameters with default values, but the first method has a positional parameter and the second method has keyword parameters.
In case of positional parameters the following code is equivalent:
```ruby
def a(some_val: Integer = 1): Integer
  some_val + 1
end
```
In case of keyword parameters the following code is equivalent:
```ruby
def b([key: String]: 'key', [value: String]: 'value'): String # this approach is up for debate, you can propose a better way in the issues section
  "#{key}: #{value}"
end
```
## How it works
The RubyTypeSystem is a work in progress. More details will be added as the project evolves.
= 

## Milestones
- [x] Create a compressor, that compresses the source codes down to a single file
- [x] Create a lexer
- [ ] Create a parser that produces an AST
- [ ] Create a type checker
- [ ] Create a type inference engine
- [ ] Create a compiler
- [ ] Create an Optimizer to optimize the compiled code down to a single expression
