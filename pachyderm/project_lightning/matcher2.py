import pandas as pd
import sys
from util import read_args, file_path, not_file_path


def read_from_source(fname, f2):
    return pd.read_csv(fname), pd.read_csv(f2)


def transform(s, match):
    def match_func(row):
        result = match[(match['code1'] == row['code1']) & (match['match1'] == row['match1'])]
        assert len(result.values) <= 1, result
        return result['match2'].values[0] if len(result.values) == 1 else float('Nan')

    s['match2'] = s.apply(match_func, axis=1)
    return s


def check(s):
    total_len = len(s.values)
    assert total_len > 3, s
    assert 'match2' in s, s
    assert len(s[s['status'] != 'alive']) == 0, s
    assert len(s[s['match2'].notna()])/total_len > 0.1, s

if __name__ == '__main__':
    input, matcher_input, output = read_args(3, [file_path, file_path, not_file_path])

    source, m2 = read_from_source(input, matcher_input)

    transformed = transform(source, m2)
    check(transformed)
    transformed.to_csv(output, index=False)