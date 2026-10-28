#!/usr/bin/env python3
"""
Zero-Width Steganographic Provenance Watermark Decoder.
Extracts and validates invisible Unicode zero-width payload embedded in README.md.

Encoding:
  - \\u200B (Zero-Width Space)       -> 0
  - \\u200C (Zero-Width Non-Joiner)  -> 1
  - \\u200D (Zero-Width Joiner)      -> Byte delimiter (8 bits per byte)

Payload:
  ORIGINAL AUTHOR: Victor "Hugh" Ramos (github.com/VictorRamosHC)
"""

import sys
from pathlib import Path

ZWSP = "\u200b"  # 0
ZWNJ = "\u200c"  # 1
ZWJ = "\u200d"   # Byte separator

EXPECTED_PAYLOAD = 'ORIGINAL AUTHOR: Victor "Hugh" Ramos (github.com/VictorRamosHC)'


def decode_watermark(content: str) -> str:
    """Extract and decode zero-width watermark from raw text."""
    zw_chars = [c for c in content if c in (ZWSP, ZWNJ, ZWJ)]
    zw_str = "".join(zw_chars)
    chunks = zw_str.split(ZWJ)

    decoded_chars = []
    for chunk in chunks:
        if len(chunk) == 8:
            byte_val = int("".join("0" if c == ZWSP else "1" for c in chunk), 2)
            decoded_chars.append(chr(byte_val))

    return "".join(decoded_chars)


def main():
    # Resolve target file path
    if len(sys.argv) > 1:
        target_path = Path(sys.argv[1])
    else:
        # Default to README.md in current directory or project root
        cwd_readme = Path("README.md")
        script_root_readme = Path(__file__).resolve().parent.parent / "README.md"
        if cwd_readme.exists():
            target_path = cwd_readme
        elif script_root_readme.exists():
            target_path = script_root_readme
        else:
            target_path = cwd_readme

    if not target_path.exists():
        sys.stderr.write(f"Error: Target file not found: {target_path}\n")
        sys.exit(1)

    try:
        content = target_path.read_text(encoding="utf-8")
    except Exception as e:
        sys.stderr.write(f"Error reading file {target_path}: {e}\n")
        sys.exit(1)

    decoded_text = decode_watermark(content)
    print(decoded_text)

    if decoded_text == EXPECTED_PAYLOAD:
        sys.exit(0)
    else:
        sys.stderr.write(
            f"Verification Failure: Watermark payload mismatch!\n"
            f"Expected: {EXPECTED_PAYLOAD}\n"
            f"Decoded:  {decoded_text}\n"
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
