#!/bin/bash

# Generate poseidon bytes-permutation circuits for different batch sizes
for log_b in 6 7 8 9; do
    batch_size=$((1 << log_b))
    echo "Generating poseidon-perm-bytes with batch_size=$batch_size (log_b=$log_b)"

    python3 generate_input.py $batch_size Prover_${log_b}.toml

    # Create a temporary copy of the source with the specific batch size
    sed "s/global BATCH_SIZE: u32 = .*/global BATCH_SIZE: u32 = $batch_size;/" src/main.nr > src/main_${log_b}.nr

    # Temporarily replace the main source file
    cp src/main.nr src/main_backup.nr
    cp src/main_${log_b}.nr src/main.nr

    # Temporarily replace Prover.toml
    if [ -f Prover.toml ]; then
        cp Prover.toml Prover_backup.toml
    fi
    cp Prover_${log_b}.toml Prover.toml

    # Compile the circuit
    nargo compile --silence-warnings

    # Restore originals
    mv src/main_backup.nr src/main.nr
    if [ -f Prover_backup.toml ]; then
        mv Prover_backup.toml Prover.toml
    fi

    # Rename artifacts
    mkdir -p target
    mv target/poseidon_perm_bytes.json target/poseidon_perm_bytes_${log_b}.json

    # Prepare proof scheme
    cargo run --release --bin noir-r1cs prepare ./target/poseidon_perm_bytes_${log_b}.json -o ./noir-proof-scheme-bytes_${log_b}.nps

    rm src/main_${log_b}.nr

done
