"""Analyze a flat file to get the max length of each column"""
import pandas as pd

df = pd.read_csv(r'C:\Files\SomeTestFile.txt'
  ,index_col=0
  ,na_values='(missing)')

for column in df:
    print(column,"->", df[column].astype(str).str.len().max())

# ==EXAMPLE OF OUTPUT==
# Source_Data_Type -> 9
# Member_ID -> 14
# Member_First_Name -> 13
# Member_Last_Name -> 19

