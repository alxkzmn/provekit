//! Divan benchmark for poseidon-var Noir circuit with variable input sizes
use {
    anyhow::Context,
    core::hint::black_box,
    divan::Bencher,
    noir_r1cs::NoirProofScheme,
    std::{fs, path::Path},
};

const CIRCUIT_DIR: &str = "../noir-examples/poseidon-var";

fn generate_inputs(size: usize) -> Vec<u64> {
    (1..=size as u64).collect()
}

fn create_prover_toml(inputs: &[u64], temp_dir: &Path) -> std::io::Result<()> {
    let content = format!(
        "plains = [\n{}]\n",
        inputs
            .chunks(8)
            .map(|chunk| chunk
                .iter()
                .map(|x| x.to_string())
                .collect::<Vec<_>>()
                .join(", "))
            .collect::<Vec<_>>()
            .join(",\n")
    );

    fs::write(temp_dir.join("Prover.toml"), content)
}

#[divan::bench(sample_count = 10, sample_size = 1)]
fn prove_poseidon_var_6(bencher: Bencher) {
    prove_poseidon_var_with_size(bencher, 6);
}

#[divan::bench(sample_count = 10, sample_size = 1)]
fn prove_poseidon_var_7(bencher: Bencher) {
    prove_poseidon_var_with_size(bencher, 7);
}

#[divan::bench(sample_count = 10, sample_size = 1)]
fn prove_poseidon_var_8(bencher: Bencher) {
    prove_poseidon_var_with_size(bencher, 8);
}

#[divan::bench(sample_count = 10, sample_size = 1)]
fn prove_poseidon_var_9(bencher: Bencher) {
    prove_poseidon_var_with_size(bencher, 9);
}

fn prove_poseidon_var_with_size(bencher: Bencher, log_size: usize) {
    let size = 1 << log_size;

    // Build the proof scheme from the compiled json. Assumes the circuit is
    // compiled beforehand.
    let crate_dir: &Path = CIRCUIT_DIR.as_ref();
    let program_path = crate_dir.join(format!("target/basic_{}.json", log_size));
    let scheme: NoirProofScheme = NoirProofScheme::from_file(&program_path)
        .with_context(|| format!("Reading compiled program {program_path:?}"))
        .expect("Reading compiled program");

    // Generate inputs for the specified size
    let inputs = generate_inputs(size);

    // Create temporary Prover.toml with the generated inputs
    let temp_dir = std::env::temp_dir().join("noir_bench");
    fs::create_dir_all(&temp_dir).expect("Failed to create temp dir");
    create_prover_toml(&inputs, &temp_dir).expect("Failed to create Prover.toml");

    // Load inputs and generate witness
    let inputs_path = temp_dir.join("Prover.toml");
    let input_map = scheme.read_witness(&inputs_path).expect("Reading witness");

    bencher.bench(|| black_box(&scheme).prove(black_box(&input_map)));
}

fn main() {
    divan::main();
}
