"""Given a flat file, report the max length of each of the columns in that file"""

import pandas as pd

# Assuming a local file with a pipe-dleimiter
df = pd.read_csv(r'C:\PATH\TO\FILE.txt'
  ,index_col=0
  ,delimiter='|'
  ,na_values='(missing)')

# # Print first x rows
# print(df.head(10))

# Display the max length of each column in the file
max_lengths = df.astype(str).apply(lambda x: x.str.len()).max()
pd.set_option('display.max_rows', None)
print(max_lengths)
