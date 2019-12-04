import Foundation

enum Direction: Character {
  case down = "D"
  case left = "L"
  case right = "R"
  case up = "U"
}

struct Vector {
  let direction: Direction
  let magnitude: Int
}

struct Point: CustomStringConvertible, Hashable {
  let x: Int
  let y: Int

  init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  init(point: Point, direction: Direction) {
    switch direction {
    case .down:
      self.init(x: point.x, y: point.y - 1)
    case .left:
      self.init(x: point.x - 1, y: point.y)
    case .right:
      self.init(x: point.x + 1, y: point.y)
    case .up:
      self.init(x: point.x, y: point.y + 1)
    }
  }

  var distance: Int {
    return abs(self.x) + abs(self.y)
  }

  // Was helpful for debugging
  var description: String {
    return "(\(self.x), \(self.y))"
  }
}

func transformVectorsToPointsAndSteps(_ vectors: [Vector]) -> [Point: Int] {
  var pointsAndSteps: [Point: Int] = [:]
  var currentPoint = Point(x: 0, y: 0)
  var currentStep = 0

  for vector in vectors {
    for _ in (1...vector.magnitude) {
      currentPoint = Point(point: currentPoint, direction: vector.direction)
      currentStep += 1

      pointsAndSteps[currentPoint] = currentStep
    }
  }

  return pointsAndSteps
}

let url = Bundle.main.url(forResource: "input", withExtension: "txt")
let input = try! String(contentsOf: url!)
let pointsAndSteps = input
  .split(separator: "\n")
  .map { $0
    .split(separator: ",")
    .map { Vector(
      direction: Direction(rawValue: $0.prefix(1).first!)!,
      magnitude: Int($0.suffix(from: $0.index(after: $0.startIndex)))!
    ) }
  }
  .map(transformVectorsToPointsAndSteps)

let intersectionPoints = Set(pointsAndSteps[0].keys).intersection(Set(pointsAndSteps[1].keys))

let answer1 = intersectionPoints
  .min(by: { $0.distance < $1.distance })!
  .distance

print(answer1)

let answer2 = intersectionPoints
  .map { pointsAndSteps[0][$0]! + pointsAndSteps[1][$0]! }
  .min()!

print(answer2)
