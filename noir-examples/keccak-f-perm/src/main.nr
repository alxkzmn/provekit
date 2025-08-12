// Keccak-f[1600] permutation-only benchmark
// Matches the HyperPlonk keccak bench shape: takes N independent 25-lane states
// (generated deterministically from a seed) and applies one Keccak-f permutation
// per state. No padding, no sponge absorb/squeeze, no public IO.

global BATCH_SIZE: u32 = 256; // Match HyperPlonk LOG_B=8 (2^8=256 permutations)

fn rotl64(x: u64, n: u8) -> u64 {
    (x << n) | (x >> (64 - n))
}

fn keccakf1600_native(mut a: [u64; 25]) -> [u64; 25] {
    let rc: [u64; 24] = [
        0x0000000000000001,
        0x0000000000008082,
        0x800000000000808A,
        0x8000000080008000,
        0x000000000000808B,
        0x0000000080000001,
        0x8000000080008081,
        0x8000000000008009,
        0x000000000000008A,
        0x0000000000000088,
        0x0000000080008009,
        0x000000008000000A,
        0x000000008000808B,
        0x800000000000008B,
        0x8000000000008089,
        0x8000000000008003,
        0x8000000000008002,
        0x8000000000000080,
        0x000000000000800A,
        0x800000008000000A,
        0x8000000080008081,
        0x8000000000008080,
        0x0000000080000001,
        0x8000000080008008,
    ];

    for round in 0..24 {
        // theta
        let c0: u64 = a[0] ^ a[5] ^ a[10] ^ a[15] ^ a[20];
        let c1: u64 = a[1] ^ a[6] ^ a[11] ^ a[16] ^ a[21];
        let c2: u64 = a[2] ^ a[7] ^ a[12] ^ a[17] ^ a[22];
        let c3: u64 = a[3] ^ a[8] ^ a[13] ^ a[18] ^ a[23];
        let c4: u64 = a[4] ^ a[9] ^ a[14] ^ a[19] ^ a[24];

        let d0: u64 = c4 ^ ((c1 << 1) | (c1 >> 63));
        let d1: u64 = c0 ^ ((c2 << 1) | (c2 >> 63));
        let d2: u64 = c1 ^ ((c3 << 1) | (c3 >> 63));
        let d3: u64 = c2 ^ ((c4 << 1) | (c4 >> 63));
        let d4: u64 = c3 ^ ((c0 << 1) | (c0 >> 63));

        a[0] = a[0] ^ d0;
        a[1] = a[1] ^ d1;
        a[2] = a[2] ^ d2;
        a[3] = a[3] ^ d3;
        a[4] = a[4] ^ d4;
        a[5] = a[5] ^ d0;
        a[6] = a[6] ^ d1;
        a[7] = a[7] ^ d2;
        a[8] = a[8] ^ d3;
        a[9] = a[9] ^ d4;
        a[10] = a[10] ^ d0;
        a[11] = a[11] ^ d1;
        a[12] = a[12] ^ d2;
        a[13] = a[13] ^ d3;
        a[14] = a[14] ^ d4;
        a[15] = a[15] ^ d0;
        a[16] = a[16] ^ d1;
        a[17] = a[17] ^ d2;
        a[18] = a[18] ^ d3;
        a[19] = a[19] ^ d4;
        a[20] = a[20] ^ d0;
        a[21] = a[21] ^ d1;
        a[22] = a[22] ^ d2;
        a[23] = a[23] ^ d3;
        a[24] = a[24] ^ d4;

        // rho+pi
        let mut b: [u64; 25] = [0; 25];
        b[0] = a[0];
        b[10] = rotl64(a[1], 1);
        b[7] = rotl64(a[10], 3);
        b[11] = rotl64(a[7], 6);
        b[17] = rotl64(a[11], 10);
        b[18] = rotl64(a[17], 15);
        b[3] = rotl64(a[18], 21);
        b[5] = rotl64(a[3], 28);
        b[16] = rotl64(a[5], 36);
        b[8] = rotl64(a[16], 45);
        b[21] = rotl64(a[8], 55);
        b[24] = rotl64(a[21], 2);
        b[4] = rotl64(a[24], 14);
        b[15] = rotl64(a[4], 27);
        b[23] = rotl64(a[15], 41);
        b[19] = rotl64(a[23], 56);
        b[13] = rotl64(a[19], 8);
        b[12] = rotl64(a[13], 25);
        b[2] = rotl64(a[12], 43);
        b[20] = rotl64(a[2], 62);
        b[14] = rotl64(a[20], 18);
        b[22] = rotl64(a[14], 39);
        b[9] = rotl64(a[22], 61);
        b[6] = rotl64(a[9], 20);
        b[1] = rotl64(a[6], 44);
        a = b;

        // chi
        let t = a;
        a[0] = t[0] ^ ((!t[1]) & t[2]);
        a[1] = t[1] ^ ((!t[2]) & t[3]);
        a[2] = t[2] ^ ((!t[3]) & t[4]);
        a[3] = t[3] ^ ((!t[4]) & t[0]);
        a[4] = t[4] ^ ((!t[0]) & t[1]);
        a[5] = t[5] ^ ((!t[6]) & t[7]);
        a[6] = t[6] ^ ((!t[7]) & t[8]);
        a[7] = t[7] ^ ((!t[8]) & t[9]);
        a[8] = t[8] ^ ((!t[9]) & t[5]);
        a[9] = t[9] ^ ((!t[5]) & t[6]);
        a[10] = t[10] ^ ((!t[11]) & t[12]);
        a[11] = t[11] ^ ((!t[12]) & t[13]);
        a[12] = t[12] ^ ((!t[13]) & t[14]);
        a[13] = t[13] ^ ((!t[14]) & t[10]);
        a[14] = t[14] ^ ((!t[10]) & t[11]);
        a[15] = t[15] ^ ((!t[16]) & t[17]);
        a[16] = t[16] ^ ((!t[17]) & t[18]);
        a[17] = t[17] ^ ((!t[18]) & t[19]);
        a[18] = t[18] ^ ((!t[19]) & t[15]);
        a[19] = t[19] ^ ((!t[15]) & t[16]);
        a[20] = t[20] ^ ((!t[21]) & t[22]);
        a[21] = t[21] ^ ((!t[22]) & t[23]);
        a[22] = t[22] ^ ((!t[23]) & t[24]);
        a[23] = t[23] ^ ((!t[24]) & t[20]);
        a[24] = t[24] ^ ((!t[20]) & t[21]);

        // iota
        a[0] = a[0] ^ rc[round];
    }
    a
}

// Entry point: perform BATCH_SIZE independent Keccak-f permutations over simple generated states.
fn main() {
    let mut seed: u64 = 1;
    for _ in 0..BATCH_SIZE {
        let mut st: [u64; 25] = [0; 25];
        for j in 0..25 {
            seed = seed + 1;
            st[j] = seed;
        }
        let _out = keccakf1600_native(st);
    }
}
