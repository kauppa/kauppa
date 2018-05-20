import Foundation

/// Implementation of Xoroshiro algorithm from http://xoshiro.di.unimi.it/xoroshiro64starstar.c
/// This is much faster than calling a platform-dependent PRNG.
public struct Xoroshiro {

    /// Default generator to be used by public dependencies.
    public static var defaultGenerator = Xoroshiro()

    /// Magic numbers used by the generator.
    let (m0, m1, m2, m3, m4): (UInt32, UInt32, UInt32, UInt32, UInt32) = (0x9E3779BB, 5, 26, 13, 32)

    var state: (UInt32, UInt32)

    /// Initialize this generator with the OS PRNG. This cannot be called every time,
    /// since it's a lot more expensive compared to the Xoroshiro algorithm.
    init() {
        #if os(Linux)
            srandom(UInt32(time(nil)))
            state = (UInt32(random()), UInt32(random()))
        #else
            state = (arc4random(), arc4random())
        #endif
    }

    /// Generate a random 32-bit unsigned integer.
    public mutating func randomUInt32() -> UInt32 {
        let (x, _) = (state.0).multipliedReportingOverflow(by: m0)
        let (result, _) = ((x << m1) | (x >> (m4 - m1))).multipliedReportingOverflow(by: m1)
        state.1 ^= state.0
        state.0 = ((state.0 << m2) | (state.0 >> (m4 - m2))) ^ state.1 ^ (state.1 << 9)
        state.1 = (state.1 << m3) | (state.1 >> (m4 - m3))
        return result
    }
}
