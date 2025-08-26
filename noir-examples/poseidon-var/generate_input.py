#!/usr/bin/env python3
import sys
import random


def generate_prover_toml(input_size, output_file="Prover.toml"):
    """Generate a Prover.toml file with random input data."""

    # Generate random values for the actual input (no padding)
    actual_values = [random.randint(1, 1000) for _ in range(input_size)]

    with open(output_file, "w") as f:
        f.write("plains = [\n")

        # Write values in groups of 8 per line
        for i in range(0, input_size, 8):
            line_values = actual_values[i : i + 8]
            if i + 8 >= input_size:  # Last line
                f.write("  " + ", ".join(map(str, line_values)) + "\n")
            else:
                f.write("  " + ", ".join(map(str, line_values)) + ",\n")

        f.write("]\n")

    print(f"Generated {output_file} with {input_size} random values")


if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python3 generate_input.py <input_size> [output_file]")
        sys.exit(1)

    try:
        input_size = int(sys.argv[1])
        if input_size <= 0:
            print("Error: input_size must be positive")
            sys.exit(1)

        output_file = sys.argv[2] if len(sys.argv) == 3 else "Prover.toml"
        generate_prover_toml(input_size, output_file)
    except ValueError:
        print("Error: input_size must be an integer")
        sys.exit(1)
