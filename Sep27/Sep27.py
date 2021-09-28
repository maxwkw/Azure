import pandas as pd
import json
import math

# Q1
df_list = []
for filename in ['people_1.txt', 'people_2.txt']:
    df = pd.read_csv(filename, sep='\t')
    df['FirstName'] = df['FirstName'].apply(lambda x:x.strip().capitalize())
    df['LastName'] = df['LastName'].apply(lambda x:x.strip().capitalize())
    df['Email'] = df['Email'].apply(lambda x:x.strip().lower())
    df['Phone'] = df['Phone'].apply(lambda x:x.strip().replace('-', ''))
    df['Address'] = df['Address'].apply(lambda x:x.strip().replace('No.', '').replace('#', ''))
    df = df.drop_duplicates()
    df_list.append(df)
final_df = pd.concat(df_list)
final_df.to_csv('results.csv', sep='\t', index=False)

# Q2
with open('movie (1).json', encoding='utf8') as json_file:
    data = json.load(json_file)
    for n in range(8):
        data_copy = data.copy()
        segment_len = len(data_copy['movie'])
        data_copy['movie'] = data_copy['movie'][math.floor(n*segment_len/8):math.floor((n+1)*segment_len/8)]
        with open(f'movie_{n+1}.json', 'w') as outfile:
            json.dump(data_copy, outfile, indent=4)


    
