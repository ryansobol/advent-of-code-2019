// https://adventofcode.com/2019/day/6

import Foundation

typealias Body = String
typealias Orbits = Set<Body>

func calcOrbits(
  satellite: Body,
  satelliteToBody: [Body: Body],
  satelliteToOrbits: inout [Body: Orbits]
) -> Orbits {
  if let orbits = satelliteToOrbits[satellite] {
    // Cache hit
    return orbits
  }

  // Cache miss
  let orbits: Orbits

  if satellite == "COM" {
    orbits = ["COM"]
  }
  else {
    let nextSatellite = satelliteToBody[satellite]!
    let nextOrbits = calcOrbits(
      satellite: nextSatellite,
      satelliteToBody: satelliteToBody,
      satelliteToOrbits: &satelliteToOrbits
    )
    let currentOrbits: Orbits = [nextSatellite]

    orbits = currentOrbits.union(nextOrbits)
  }

  // Cache update
  satelliteToOrbits[satellite] = orbits

  return orbits
}

let url = Bundle.main.url(forResource: "input", withExtension: "txt")
let input = try! String(contentsOf: url!)
let satelliteToBody = input
  .trimmingCharacters(in: .newlines)
  .split(separator: "\n")
  .reduce(into: [Body: Body]()) { accum, bodyToSatellite in
    let bodies = bodyToSatellite.split(separator: ")")
    accum[Body(bodies[1])] = Body(bodies[0])
  }

// Used as a cache for answer1, and as a core data structure for answer2
var satelliteToOrbits: [Body: Orbits] = [:]

let answer1 = satelliteToBody
  .keys
  .reduce(0) { accum, satellite in
    accum + calcOrbits(
      satellite: satellite,
      satelliteToBody: satelliteToBody,
      satelliteToOrbits: &satelliteToOrbits
    ).count
  }

print(answer1)

let answer2 = satelliteToOrbits["YOU"]!
  .symmetricDifference(satelliteToOrbits["SAN"]!)
  .count

print(answer2)

