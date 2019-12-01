import Foundation

let url = Bundle.main.url(forResource: "input", withExtension: "txt")
let input = try! String(contentsOf: url!)
let masses = input
  .split(separator: "\n")
  .map { Int($0)! }

// Recursive, FP solution
// https://www.reddit.com/r/adventofcode/comments/e4axxe/2019_day_1_solutions/f9ct724
func calcFuel(_ mass: Int) -> Int {
  return mass / 3 - 2
}

func calcActualFuel(_ mass: Int) -> Int {
  let fuel = calcFuel(mass)

  return fuel > 0 ? fuel + calcActualFuel(fuel) : 0
}

let answer1 = masses
  .map(calcFuel)
  .reduce(0, +)

print(answer1)

let answer2 = masses
  .map(calcActualFuel)
  .reduce(0, +)

print(answer2)

// Iterative, OOP + FP solution for the 2nd problem
struct Data {
  let fuel: Int
  let masses: [Int]

  func next() -> Data {
    let nextMasses = self.masses
      .map { $0 / 3 - 2 }
      .filter { $0 > 0 }

    let nextFuel = nextMasses.reduce(self.fuel, +)

    return Data(fuel: nextFuel, masses: nextMasses)
  }
}

var current = Data(fuel: 0, masses: masses)

while !current.masses.isEmpty {
  current = current.next()
}

print(current.fuel)
