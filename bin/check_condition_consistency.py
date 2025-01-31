#!/usr/bin/env python
# Author: Felix Haidle + ChatGPT

import csv
import sys
from pathlib import Path

def read_conditions_from_samplesheet(file_path):
    """Read unique conditions from the sample sheet."""
    conditions = set()
    with file_path.open(newline="") as file:
        reader = csv.DictReader(file)
        if "condition" not in reader.fieldnames:
            print("ERROR: The sample sheet must contain a 'condition' column.", file=sys.stderr)
            sys.exit(1)
        for row in reader:
            conditions.add(row["condition"].strip())
    return conditions

def read_conditions_from_contrastsheet(file_path):
    """Read unique treatment and control conditions from the contrast sheet."""
    conditions = set()
    with file_path.open(newline="") as file:
        reader = csv.DictReader(file)
        if "treatment" not in reader.fieldnames or "control" not in reader.fieldnames:
            print("ERROR: The contrast sheet must contain 'treatment' and 'control' columns.", file=sys.stderr)
            sys.exit(1)
        for row in reader:
            conditions.add(row["treatment"].strip())
            conditions.add(row["control"].strip())
    return conditions

def validate_conditions(samplesheet_path, contrastsheet_path):
    """Check if all conditions in the contrast sheet exist in the sample sheet and vice versa."""
    sample_conditions = read_conditions_from_samplesheet(samplesheet_path)
    contrast_conditions = read_conditions_from_contrastsheet(contrastsheet_path)

    missing_in_samplesheet = contrast_conditions - sample_conditions
    missing_in_contrastsheet = sample_conditions - contrast_conditions

    if missing_in_samplesheet:
        print(f"❌ ERROR: The following conditions are used in the contrast sheet but are missing in the sample sheet: {', '.join(missing_in_samplesheet)}", file=sys.stderr)

    if missing_in_contrastsheet:
        print(f"⚠️ WARNING: The following conditions exist in the sample sheet but are never used in the contrast sheet: {', '.join(missing_in_contrastsheet)}", file=sys.stderr)

    if missing_in_samplesheet:
        sys.exit(1)  # Stop the pipeline if required conditions are missing

    print("✅ All conditions in the contrast sheet exist in the sample sheet.")
    if not missing_in_contrastsheet:
        print("✅ All conditions in the sample sheet are used in the contrast sheet.")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python validate_conditions.py samplesheet.csv contrastsheet.csv", file=sys.stderr)
        sys.exit(1)

    samplesheet_path = Path(sys.argv[1])
    contrastsheet_path = Path(sys.argv[2])

    if not samplesheet_path.is_file():
        print(f"ERROR: Sample sheet file '{samplesheet_path}' not found.", file=sys.stderr)
        sys.exit(1)
    if not contrastsheet_path.is_file():
        print(f"ERROR: Contrast sheet file '{contrastsheet_path}' not found.", file=sys.stderr)
        sys.exit(1)

    validate_conditions(samplesheet_path, contrastsheet_path)
