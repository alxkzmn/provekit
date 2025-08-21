#!/bin/bash

# Generate poseidon circuits with different input sizes
for log_size in 6 7 8 9; do
    input_size=$((1 << log_size))
    echo "Generating poseidon circuit with input_size=$input_size (log_size=$log_size)"
    
    # Create a temporary copy of the source with the specific input size
    sed "s/fn main(plains: \[Field; 1024\])/fn main(plains: [Field; $input_size])/" src/main.nr > src/main_${log_size}.nr
    
    # Temporarily replace the main source file
    cp src/main.nr src/main_backup.nr
    cp src/main_${log_size}.nr src/main.nr
    
    # Compile the circuit
    nargo compile --silence-warnings
    
    # Restore the original source file
    mv src/main_backup.nr src/main.nr
    
    # Rename the output
    mv target/basic.json target/basic_${log_size}.json
done

echo "Generated circuits:"
ls -la target/*.json
