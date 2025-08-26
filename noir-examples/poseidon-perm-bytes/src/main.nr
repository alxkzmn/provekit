use dep::poseidon2;

// Accept fields equal to 2 * BATCH_SIZE so bytes ingested match p3
// (p3 KoalaBear: 4 bytes per lane; Noir BN254: 32 bytes per field).

global BATCH_SIZE: u32 = 256;

fn main(plains: [Field; 2 * BATCH_SIZE]) {
    let n = plains.len();
    let num_states = (n + 15) / 16; // ceil(n / 16)

    let mut last_out0: Field = 0;
    for i in 0..num_states {
        let mut state: [Field; 16] = [0; 16];
        let base = 16 * i;
        for lane in 0..16 {
            let idx = base + lane;
            state[lane] = if idx < n { plains[idx] } else { 0 };
        }
        state = poseidon2::bn254::perm::x5_16(state);
        last_out0 = state[0];
    }
    println(last_out0);
}
