#!/usr/bin/env python3
import sys
import random


def generate_prover_toml(batch_size: int, output_file: str = "Prover.toml"):
    total = 25 * batch_size
    # Use 63-bit values (<= 2^63-1) to satisfy TOML's signed 64-bit integer limit
    values = [random.randrange(0, 1 << 63) for _ in range(total)]
    with open(output_file, "w") as f:
        f.write("plains = [\n")
        for i in range(0, total, 8):
            line = values[i : i + 8]
            if i + 8 >= total:
                f.write("  " + ", ".join(str(v) for v in line) + "\n")
            else:
                f.write("  " + ", ".join(str(v) for v in line) + ",\n")
        f.write("]\n")
    print(
        f"Generated {output_file} with {total} u64 values for batch_size={batch_size}"
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
        generate_prover_toml(batch_size, output_file)
    except ValueError:
        print("Error: batch_size must be an integer")
        sys.exit(1)
