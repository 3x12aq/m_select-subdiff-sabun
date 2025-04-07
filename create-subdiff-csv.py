"""
for m_select test_subdiff
"""

import gzip
import json
import glob

table_list = []
for bmt_filepath in glob.glob('../../table/*.bmt'):
    with gzip.GzipFile(bmt_filepath) as f:
        d = json.load(f)
        table_name = d['name']
        if  'おすすめ譜面表' in table_name or 'BMS Search' in table_name:
            continue
        table_list.append((bmt_filepath, d['tag']))
table_list.sort(key=lambda x: x[1])

subdiff_data = {}

for bmt_filepath, table_tag in table_list:
    with gzip.GzipFile(bmt_filepath) as f:
        d = json.load(f)

        for d2 in d['folder']:
            subdiff_name = d2['name']
            for d3 in d2['songs']:
                if 'md5' in d3:
                    key = ('md5', d3['md5'])
                elif 'sha256' in d3:
                    key = ('sha256', d3['sha256'])
                else:
                    print(subdiff_name, d3)
                    raise Exception

                if key not in subdiff_data:
                    subdiff_data[key] = []
                subdiff_data[key].append(subdiff_name)

csv_list = ['md5,sha256,subdiff']
for key, value in subdiff_data.items():
    md5 = key[1] if key[0] == 'md5' else ''
    sha256 = key[1] if key[0] == 'sha256' else ''
    subdiff = ' / '.join(value)
    csv_list.append(f'{md5},{sha256},{subdiff}')

with open('subdiff.csv', 'w', encoding='utf-8') as f:
    f.write('\n'.join(csv_list))

