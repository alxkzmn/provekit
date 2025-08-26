use dep::poseidon2;

fn permute_chunks_x5_16(plains: [Field]) -> Field {
    let input_size = plains.len();
    // Expect input_size to be a multiple of 16 (64, 128, 256, 512 satisfy this).
    let num_states = input_size / 16;

    let mut last_out0 = 0;
    for i in 0..num_states {
        let base = 16 * i;
        let mut state = [
            plains[base + 0],
            plains[base + 1],
            plains[base + 2],
            plains[base + 3],
            plains[base + 4],
            plains[base + 5],
            plains[base + 6],
            plains[base + 7],
            plains[base + 8],
            plains[base + 9],
            plains[base + 10],
            plains[base + 11],
            plains[base + 12],
            plains[base + 13],
            plains[base + 14],
            plains[base + 15],
        ];

        state = poseidon2::bn254::perm::x5_16(state);
        last_out0 = state[0];
    }

    last_out0
}

fn main(plains: [Field; 512]) {
    let out = permute_chunks_x5_16(plains);
    println(out);
}
