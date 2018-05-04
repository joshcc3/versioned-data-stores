import pandas as pd
import sys
from util import not_file_path, file_path, read_args

def read_from_source(fname, f2):
    return pd.read_csv(fname), pd.read_csv(f2)


def transform(s, match):
    assert 'match1' in match, match
    assert 'code1' in s, s
    assert 'code2' in s, s
    def match_func(row):
        result = match[(match['code1'].str.contains(row['code1'])) & (match['code2'] == row['code2'])]
        assert len(result.values) <= 1, result
        return result['match1'].values[0] if len(result.values) == 1 else float('Nan')

    s['match1'] = s.apply(match_func, axis=1)
    return s

def check(s):
    total_len = len(s.values)
    assert total_len > 3, s
    assert 'match1' in s, s
    assert len(s[s['status'] != 'alive']) == 0, s
    assert len(s[s['match1'].notna()])/total_len > 0.25


if __name__ == '__main__':
    input, matcher_input, output = read_args(3, [file_path, file_path, not_file_path])

    source, match = read_from_source(input, matcher_input)

    transformed = transform(source, match)
    check(transformed)
    transformed.to_csv(output,index=False)