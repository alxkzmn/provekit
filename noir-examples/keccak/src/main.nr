// Keccak-256 example
//
// The implementation follows these steps (Keccak-256 parameters r = 1088, c =
// 512):
//   1. Pad the one-byte message with the Keccak "01 ... 80" padding rule used by
//      the pre-SHA-3 Keccak hash (same padding as Ethereum).  Because our
//      message length is < r/8 (136) we need only one block.
//   2. Absorb the 136-byte block into the 25-lane state (little-endian lane
//      packing).
//   3. Apply the Keccak-F[1600] permutation once.
//   4. Squeeze the first 32 bytes (256 bits) of the state as the digest.

/// Rotate-left by `n` bits (0 <= n < 64).
fn rotl64(x: u64, n: u8) -> u64 {
    (x << n) | (x >> (64 - n))
}

/// Native implementation of Keccak-f[1600] permutation (24 rounds).
fn keccakf1600_native(mut a: [u64; 25]) -> [u64; 25] {
    // Round constants
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
        // --- theta --------------------------------------------------------
        // Compute the parity of each column exactly as reference implementation
        let c0: u64 = a[0] ^ a[5] ^ a[10] ^ a[15] ^ a[20];
        let c1: u64 = a[1] ^ a[6] ^ a[11] ^ a[16] ^ a[21];
        let c2: u64 = a[2] ^ a[7] ^ a[12] ^ a[17] ^ a[22];
        let c3: u64 = a[3] ^ a[8] ^ a[13] ^ a[18] ^ a[23];
        let c4: u64 = a[4] ^ a[9] ^ a[14] ^ a[19] ^ a[24];

        // D[x, z] = C[(x - 1) mod 5, z] ^ C[(x + 1) mod 5, (z - 1) mod LANE_LENGTH]
        // Inline rotl64 for 1-bit rotations
        let d0: u64 = c4 ^ ((c1 << 1) | (c1 >> 63));
        let d1: u64 = c0 ^ ((c2 << 1) | (c2 >> 63));
        let d2: u64 = c1 ^ ((c3 << 1) | (c3 >> 63));
        let d3: u64 = c2 ^ ((c4 << 1) | (c4 >> 63));
        let d4: u64 = c3 ^ ((c0 << 1) | (c0 >> 63));

        // Apply the theta step - unrolled
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

        // --- rho and pi - fully unrolled ---
        let mut b: [u64; 25] = [0; 25];
        b[0] = a[0]; // center lane unchanged

        // Unrolled rho-pi transformations
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

        // --- chi - fully unrolled ---
        let state_copy = a;
        // Row 0
        a[0] = state_copy[0] ^ ((!state_copy[1]) & state_copy[2]);
        a[1] = state_copy[1] ^ ((!state_copy[2]) & state_copy[3]);
        a[2] = state_copy[2] ^ ((!state_copy[3]) & state_copy[4]);
        a[3] = state_copy[3] ^ ((!state_copy[4]) & state_copy[0]);
        a[4] = state_copy[4] ^ ((!state_copy[0]) & state_copy[1]);
        // Row 1
        a[5] = state_copy[5] ^ ((!state_copy[6]) & state_copy[7]);
        a[6] = state_copy[6] ^ ((!state_copy[7]) & state_copy[8]);
        a[7] = state_copy[7] ^ ((!state_copy[8]) & state_copy[9]);
        a[8] = state_copy[8] ^ ((!state_copy[9]) & state_copy[5]);
        a[9] = state_copy[9] ^ ((!state_copy[5]) & state_copy[6]);
        // Row 2
        a[10] = state_copy[10] ^ ((!state_copy[11]) & state_copy[12]);
        a[11] = state_copy[11] ^ ((!state_copy[12]) & state_copy[13]);
        a[12] = state_copy[12] ^ ((!state_copy[13]) & state_copy[14]);
        a[13] = state_copy[13] ^ ((!state_copy[14]) & state_copy[10]);
        a[14] = state_copy[14] ^ ((!state_copy[10]) & state_copy[11]);
        // Row 3
        a[15] = state_copy[15] ^ ((!state_copy[16]) & state_copy[17]);
        a[16] = state_copy[16] ^ ((!state_copy[17]) & state_copy[18]);
        a[17] = state_copy[17] ^ ((!state_copy[18]) & state_copy[19]);
        a[18] = state_copy[18] ^ ((!state_copy[19]) & state_copy[15]);
        a[19] = state_copy[19] ^ ((!state_copy[15]) & state_copy[16]);
        // Row 4
        a[20] = state_copy[20] ^ ((!state_copy[21]) & state_copy[22]);
        a[21] = state_copy[21] ^ ((!state_copy[22]) & state_copy[23]);
        a[22] = state_copy[22] ^ ((!state_copy[23]) & state_copy[24]);
        a[23] = state_copy[23] ^ ((!state_copy[24]) & state_copy[20]);
        a[24] = state_copy[24] ^ ((!state_copy[20]) & state_copy[21]);

        // --- iota ---------------------------------------------------------
        a[0] = a[0] ^ rc[round];
    }

    a
}

// -------- Small helpers ----------------------------------------------------

/// Converts 8 little-endian bytes beginning at `start` in `data` into a `u64`.
fn le_bytes_to_u64(data: [u8; 136], start: u32) -> u64 {
    (data[start] as u64)
        | ((data[start + 1] as u64) << 8)
        | ((data[start + 2] as u64) << 16)
        | ((data[start + 3] as u64) << 24)
        | ((data[start + 4] as u64) << 32)
        | ((data[start + 5] as u64) << 40)
        | ((data[start + 6] as u64) << 48)
        | ((data[start + 7] as u64) << 56)
}

/// Serialises the first 32 bytes of the state (little-endian) into an array.
fn state_to_32_bytes(state: [u64; 25]) -> [u8; 32] {
    [
        // Lane 0
        (state[0] & 0xFF) as u8,
        ((state[0] >> 8) & 0xFF) as u8,
        ((state[0] >> 16) & 0xFF) as u8,
        ((state[0] >> 24) & 0xFF) as u8,
        ((state[0] >> 32) & 0xFF) as u8,
        ((state[0] >> 40) & 0xFF) as u8,
        ((state[0] >> 48) & 0xFF) as u8,
        ((state[0] >> 56) & 0xFF) as u8,
        // Lane 1
        (state[1] & 0xFF) as u8,
        ((state[1] >> 8) & 0xFF) as u8,
        ((state[1] >> 16) & 0xFF) as u8,
        ((state[1] >> 24) & 0xFF) as u8,
        ((state[1] >> 32) & 0xFF) as u8,
        ((state[1] >> 40) & 0xFF) as u8,
        ((state[1] >> 48) & 0xFF) as u8,
        ((state[1] >> 56) & 0xFF) as u8,
        // Lane 2
        (state[2] & 0xFF) as u8,
        ((state[2] >> 8) & 0xFF) as u8,
        ((state[2] >> 16) & 0xFF) as u8,
        ((state[2] >> 24) & 0xFF) as u8,
        ((state[2] >> 32) & 0xFF) as u8,
        ((state[2] >> 40) & 0xFF) as u8,
        ((state[2] >> 48) & 0xFF) as u8,
        ((state[2] >> 56) & 0xFF) as u8,
        // Lane 3
        (state[3] & 0xFF) as u8,
        ((state[3] >> 8) & 0xFF) as u8,
        ((state[3] >> 16) & 0xFF) as u8,
        ((state[3] >> 24) & 0xFF) as u8,
        ((state[3] >> 32) & 0xFF) as u8,
        ((state[3] >> 40) & 0xFF) as u8,
        ((state[3] >> 48) & 0xFF) as u8,
        ((state[3] >> 56) & 0xFF) as u8,
    ]
}

// -------- Keccak-256 over arbitrary-length input ---------------------------

/// Absorbs a *single* 136-byte rate block into the state and applies Keccak-F.
fn absorb_block(state: [u64; 25], block: [u8; 136]) -> [u64; 25] {
    let mut st = state;
    // XOR the block into the first 17 lanes (rate / 8) - using function calls
    for lane in 0..17 {
        let lane_val = le_bytes_to_u64(block, lane * 8);
        st[lane] = st[lane] ^ lane_val;
    }
    keccakf1600_native(st)
}

/// Keccak-256 for variable-length input.
/// Processes the message in 136-byte blocks with proper padding.
/// Supports arbitrary message sizes up to 256 bytes (2 blocks max).
fn keccak256(msg: [u8; 256], message_size: u32) -> [u8; 32] {
    let mut state: [u64; 25] = [0; 25];

    // Process first block (if any)
    if message_size > 0 {
        let mut block1: [u8; 136] = [0; 136];
        let block1_size = if message_size > 136 {
            136
        } else {
            message_size
        };

        for i in 0..136 {
            if i < block1_size {
                block1[i] = msg[i];
            }
        }

        if message_size <= 136 {
            // Single block with padding - cleaner approach
            block1[block1_size] ^= 0x01; // Always safe since block1_size <= 135
            block1[135] ^= 0x80;
            state = absorb_block(state, block1);
        } else {
            // First full block (no padding)
            state = absorb_block(state, block1);

            // Second block with padding
            let mut block2: [u8; 136] = [0; 136];
            let remaining = message_size - 136;

            for i in 0..136 {
                if i < remaining {
                    block2[i] = msg[136 + i];
                }
            }

            block2[remaining] ^= 0x01; // Always safe since remaining <= 135
            block2[135] ^= 0x80;
            state = absorb_block(state, block2);
        }
    } else {
        // Empty message - just padding
        let mut padding_block: [u8; 136] = [0; 136];
        padding_block[0] ^= 0x01;
        padding_block[135] ^= 0x80;
        state = absorb_block(state, padding_block);
    }

    state_to_32_bytes(state)
}

// -------- Entry point ------------------------------------------------------

/// General Keccak-256 example mirroring `sha256_var`.
///
/// Proves that the Keccak-256 digest of the first `message_size` bytes of
/// `msg` equals the public `result`.
fn main(msg: [u8; 256], message_size: u64, result: [u8; 32]) {
    let digest = keccak256(msg, message_size as u32);
    assert(digest == result);
}
