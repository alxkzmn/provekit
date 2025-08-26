#!/usr/bin/env python3
import sys
import os
import random

"""
Generate 2 * BATCH_SIZE BN254 field elements for Noir input, matching bytes of
KoalaBear p3 workload: 16 lanes × 4 bytes per state → 64 bytes per state,
32 bytes per BN254 field → 2 fields per state.
"""


def generate_prover_fields(batch_size: int, output_file: str = "Prover.toml"):
    total_fields = 2 * batch_size
    values = [random.randrange(0, 1 << 16) for _ in range(total_fields)]
    with open(output_file, "w") as f:
        f.write("plains = [\n")
        for i in range(0, total_fields, 8):
            line = values[i : i + 8]
            if i + 8 >= total_fields:
                f.write("  " + ", ".join(str(v) for v in line) + "\n")
            else:
                f.write("  " + ", ".join(str(v) for v in line) + ",\n")
        f.write("]\n")
    print(
        f"Generated {output_file} with {total_fields} field elements for batch_size={batch_size}"
    )


if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python3 generate_input.py <batch_size> [output_file]")
        sys.exit(1)
    try:
        batch_size = int(sys.argv[1])
        output_file = sys.argv[2] if len(sys.argv) == 3 else "Prover.toml"
        if batch_size <= 0:
            print("Error: batch_size must be positive")
            sys.exit(1)
        generate_prover_fields(batch_size, output_file)
    except ValueError:
        print("Error: batch_size must be an integer")
        sys.exit(1)
