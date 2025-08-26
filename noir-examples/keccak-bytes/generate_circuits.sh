#!/bin/bash

# Generate keccak bytes-permutation circuits with different batch sizes
for log_size in 5 6 7 8; do
    batch_size=$((1 << log_size))
    echo "Generating keccak-bytes with batch_size=$batch_size (log_size=$log_size)"

    python3 generate_input.py $batch_size Prover_${log_size}.toml

    # Create a temporary copy of the source with the specific batch size
    sed "s/global BATCH_SIZE: u32 = 256;/global BATCH_SIZE: u32 = $batch_size;/" src/main.nr > src/main_${log_size}.nr

    # Temporarily replace the main source file
    cp src/main.nr src/main_backup.nr
    cp src/main_${log_size}.nr src/main.nr

    # Temporarily replace Prover.toml
    if [ -f Prover.toml ]; then
        cp Prover.toml Prover_backup.toml
    fi
    cp Prover_${log_size}.toml Prover.toml

    # Compile the circuit
    nargo compile --silence-warnings

    # Restore originals
    mv src/main_backup.nr src/main.nr
    if [ -f Prover_backup.toml ]; then
        mv Prover_backup.toml Prover.toml
    fi

    # Rename artifacts
    mkdir -p target
    mv target/keccak_bytes.json target/keccak_bytes_${log_size}.json 2>/dev/null || mv target/basic.json target/keccak_bytes_${log_size}.json

    # Prepare proof scheme
    cargo run --release --bin noir-r1cs prepare ./target/keccak_bytes_${log_size}.json -o ./noir-proof-scheme_${log_size}.nps

    rm src/main_${log_size}.nr

done

ls -la target/*.json
ls -la noir-proof-scheme_*.nps
