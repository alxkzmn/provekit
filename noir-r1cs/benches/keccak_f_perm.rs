//! Divan benchmark for keccak-f-perm Noir circuit (256 permutations to match
//! HyperPlonk)
use {
    anyhow::Context, core::hint::black_box, divan::Bencher, noir_r1cs::NoirProofScheme,
    std::path::Path,
};

const CIRCUIT_DIR: &str = "../noir-examples/keccak-f-perm";
const INPUTS_FILE: &str = "Prover.toml";
const PROGRAM_JSON: &str = "target/keccak_f_perm.json";

#[divan::bench(sample_count = 10, sample_size = 1)]
fn prove_keccak_f_perm(bencher: Bencher) {
    // Build the proof scheme from the compiled json. Assumes the circuit is
    // compiled beforehand.
    let crate_dir: &Path = CIRCUIT_DIR.as_ref();
    let program_path = crate_dir.join(PROGRAM_JSON);
    let scheme: NoirProofScheme = NoirProofScheme::from_file(&program_path)
        .with_context(|| format!("Reading compiled program {program_path:?}"))
        .expect("Reading compiled program");

    // Load inputs (batch_size parameter) and generate witness
    let inputs_path = crate_dir.join(INPUTS_FILE);
    let input_map = scheme.read_witness(&inputs_path).expect("Reading witness");

    bencher.bench(|| black_box(&scheme).prove(black_box(&input_map)));
}

fn main() {
    divan::main();
}
