//! Divan benchmark for keccak-f-perm Noir circuit with variable batch sizes
use {
    anyhow::Context,
    core::hint::black_box,
    divan::Bencher,
    noir_r1cs::NoirProofScheme,
    std::{fs, path::Path},
};

const CIRCUIT_DIR: &str = "../noir-examples/keccak-f-perm";

fn create_prover_toml(temp_dir: &Path) -> std::io::Result<()> {
    // Keccak circuit doesn't need inputs, but we need an empty Prover.toml
    fs::write(temp_dir.join("Prover.toml"), "# No parameters needed\n")
}

#[divan::bench(sample_count = 10, sample_size = 1)]
fn prove_keccak_f_perm_5(bencher: Bencher) {
    prove_keccak_f_perm_with_size(bencher, 5);
}

#[divan::bench(sample_count = 10, sample_size = 1)]
fn prove_keccak_f_perm_6(bencher: Bencher) {
    prove_keccak_f_perm_with_size(bencher, 6);
}

#[divan::bench(sample_count = 10, sample_size = 1)]
fn prove_keccak_f_perm_7(bencher: Bencher) {
    prove_keccak_f_perm_with_size(bencher, 7);
}

#[divan::bench(sample_count = 10, sample_size = 1)]
fn prove_keccak_f_perm_8(bencher: Bencher) {
    prove_keccak_f_perm_with_size(bencher, 8);
}

fn prove_keccak_f_perm_with_size(bencher: Bencher, log_size: usize) {
    // Build the proof scheme from the compiled json. Assumes the circuit is
    // compiled beforehand.
    let crate_dir: &Path = CIRCUIT_DIR.as_ref();
    let program_path = crate_dir.join(format!("target/keccak_f_perm_{}.json", log_size));
    let scheme: NoirProofScheme = NoirProofScheme::from_file(&program_path)
        .with_context(|| format!("Reading compiled program {program_path:?}"))
        .expect("Reading compiled program");

    // Create temporary Prover.toml (keccak circuit doesn't need inputs)
    let temp_dir = std::env::temp_dir().join("noir_bench");
    fs::create_dir_all(&temp_dir).expect("Failed to create temp dir");
    create_prover_toml(&temp_dir).expect("Failed to create Prover.toml");

    // Load inputs and generate witness
    let inputs_path = temp_dir.join("Prover.toml");
    let input_map = scheme.read_witness(&inputs_path).expect("Reading witness");

    bencher.bench(|| black_box(&scheme).prove(black_box(&input_map)));
}

fn main() {
    divan::main();
}
