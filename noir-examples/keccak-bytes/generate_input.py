#!/usr/bin/env python3
import sys
import random

def generate_prover_bytes(batch_size: int, output_file: str = "Prover.toml"):
    total = 25 * 8 * batch_size
    values = [random.randrange(0, 256) for _ in range(total)]
    with open(output_file, "w") as f:
        f.write("plains = [\n")
        for i in range(0, total, 16):
            line = values[i : i + 16]
            if i + 16 >= total:
                f.write("  " + ", ".join(str(v) for v in line) + "\n")
            else:
                f.write("  " + ", ".join(str(v) for v in line) + ",\n")
        f.write("]\n")
    print(f"Generated {output_file} with {total} bytes for batch_size={batch_size}")

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
        generate_prover_bytes(batch_size, output_file)
    except ValueError:
        print("Error: batch_size must be an integer")
        sys.exit(1)
