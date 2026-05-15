import sys
from collections import defaultdict

# Tracks sequential counts for children of the current locus
counters = defaultdict(int)
current_locus = None

for line in sys.stdin:
    if line.startswith("#") or not line.strip():
        print(line, end="")
        continue
    
    cols = line.strip().split("\t")
    ft_type = cols[2].lower()
    
    # Parse attributes into a dict
    attr_parts = cols[8].split(";")
    attrs = {}
    for item in attr_parts:
        if "=" in item:
            k, v = item.split("=", 1)
            attrs[k] = v

    # 1. Capture the locus tag from Gene or mRNA Name
    if "Name" in attrs:
        current_locus = attrs["Name"]
        # Reset counters when we hit a new gene/mRNA block
        if ft_type in ["gene", "mrna"]:
            counters.clear()

    # 2. Process features based on the remembered current_locus
    if current_locus:
        if ft_type == "gene":
            attrs["ID"] = current_locus
            # Genes have no Parent
            attrs.pop("Parent", None)
            
        elif ft_type == "mrna":
            attrs["ID"] = current_locus
            attrs["Parent"] = current_locus # Funannotate often expects mRNA Parent = Gene ID
            
        elif ft_type in ["exon", "cds", "intron"]:
            # Increment counter for this specific type (e.g., exon1, exon2)
            counters[ft_type] += 1
            idx = counters[ft_type]
            
            # Update ID: e.g., FUN2_000001_exon1
            attrs["ID"] = f"{current_locus}_{ft_type}{idx}"
            # Update Parent: Must point to the mRNA's ID (the locus tag)
            attrs["Parent"] = current_locus

    # 3. Rebuild the attribute string
    # We maintain the original Name if it existed
    new_attr_str = ";".join([f"{k}={v}" for k, v in attrs.items()])
    cols[8] = new_attr_str
    print("\t".join(cols))