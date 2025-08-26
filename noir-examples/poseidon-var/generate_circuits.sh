#!/bin/bash

# Generate poseidon circuits with different input sizes
for log_size in 6 7 8 9; do
    # Structural-equivalence with p3: p3 takes 2^log_size states of WIDTH=16,
    # so Noir must take 16 * 2^log_size field elements and permute in 16-lane chunks.
    input_size=$((16 << log_size))
    echo "Generating poseidon-var (structure-equal) with input_size=$input_size (16 * 2^$log_size)"
    
    # Generate random input using Python script for this specific size
    python3 generate_input.py $input_size Prover_${log_size}.toml
    
    # Create a temporary copy of the source with the specific input size
    sed "s/fn main(plains: \[Field; 512\])/fn main(plains: [Field; $input_size])/" src/main.nr > src/main_${log_size}.nr
    
    # Temporarily replace the main source file
    cp src/main.nr src/main_backup.nr
    cp src/main_${log_size}.nr src/main.nr
    
    # Temporarily replace the Prover.toml file with the generated one
    if [ -f Prover.toml ]; then
        cp Prover.toml Prover_backup.toml
    fi
    cp Prover_${log_size}.toml Prover.toml
    
    # Compile the circuit
    nargo compile --silence-warnings
    
    # Restore the original files
    mv src/main_backup.nr src/main.nr
    if [ -f Prover_backup.toml ]; then
        mv Prover_backup.toml Prover.toml
    fi
    
    # Rename the output
    mv target/basic.json target/poseidon_${log_size}.json

    cargo run --release --bin noir-r1cs prepare ./target/poseidon_${log_size}.json -o ./noir-proof-scheme_${log_size}.nps
    
    # Clean up temporary source file (keep Prover files)
    rm src/main_${log_size}.nr
done

echo "Generated circuits:"
ls -la target/*.json
echo "Generated Prover files:"
ls -la Prover_*.toml
