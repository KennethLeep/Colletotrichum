import pandas as pd

# Load the gene count matrix
df = pd.read_csv("/project/colletotrichum_ga_625/COLLETOTRICHUM/Pangenome/Orthofinder/OrthoFinder/Results_Apr22/Orthogroups/Orthogroups.GeneCount.tsv", sep='\t')

# Define your groups based on your column indices (0-indexed)
# C. siamense US: 1,2,3,6,7,8,11 | Ref: 5
siam_us = [1, 2, 3, 6, 7, 8, 11]
siam_ref = 5

# C. camelliae US: 9,10,14,15,16 | Refs: 4, 12, 13
cam_us = [9, 10, 14, 15, 16]
cam_refs = [4, 12, 13]

# Logic: US group must have genes in > 80% of isolates, Refs must have 0
siam_logic = (df.iloc[:, siam_us] > 0).sum(axis=1) >= 6  # 6 out of 7
siam_ref_logic = (df.iloc[:, siam_ref] == 0)

cam_logic = (df.iloc[:, cam_us] > 0).sum(axis=1) >= 4   # 4 out of 5
cam_ref_logic = (df.iloc[:, cam_refs] == 0).all(axis=1)

# Filter
siam_unique = df[siam_logic & siam_ref_logic]
cam_unique = df[cam_logic & cam_ref_logic]

print(f"Unique to US C. siamense: {len(siam_unique)}")
print(f"Unique to US C. camelliae: {len(cam_unique)}")

# Save them to check later
siam_unique.to_csv("/project/colletotrichum_ga_625/COLLETOTRICHUM/Pangenome/OrthofinderUS_Siamense_Unique.tsv", sep='\t', index=False)
cam_unique.to_csv("/project/colletotrichum_ga_625/COLLETOTRICHUM/Pangenome/OrthofinderUS_Camelliae_Unique.tsv", sep='\t', index=False)