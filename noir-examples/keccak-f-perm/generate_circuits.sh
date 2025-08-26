#!/bin/bash

# Generate keccak circuits with different batch sizes
for log_size in 5 6 7 8; do
    batch_size=$((1 << log_size))
    echo "Generating keccak circuit with batch_size=$batch_size (log_size=$log_size)"
    
    python3 generate_input.py $batch_size Prover_${log_size}.toml

    # Create a temporary copy of the source with the specific batch size
    sed "s/global BATCH_SIZE: u32 = 256;/global BATCH_SIZE: u32 = $batch_size;/" src/main.nr > src/main_${log_size}.nr
    
    # Temporarily replace the main source file
    cp src/main.nr src/main_backup.nr
    cp src/main_${log_size}.nr src/main.nr
    
    # Compile the circuit
    nargo compile --silence-warnings
    
    # Restore the original source file
    mv src/main_backup.nr src/main.nr
    
    # Rename the output
    mv target/keccak_f_perm.json target/keccak_f_perm_${log_size}.json

    cargo run --release --bin noir-r1cs prepare ./target/keccak_f_perm_${log_size}.json -o ./noir-proof-scheme_${log_size}.nps

    # Clean up temporary source file
    rm src/main_${log_size}.nr
done

echo "Generated circuits:"
ls -la target/*.json

echo "Generated Prover files:"
ls -la Prover_*.toml
