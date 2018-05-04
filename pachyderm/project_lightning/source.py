import pandas as pd
import sys
from util import read_args, file_path, not_file_path


def read_from_source(fname):
    return pd.read_csv(fname)


def transform(s):
    assert 'status' in s, s
    assert 'type' in s, s
    assert 'code1' in s, s
    assert 'code2' in s, s

    return s[(s['status'] == 'alive') & (s['type'] == 'equity')]


def check(s):
    assert len(s.values) > 3, s
    assert 'code1' in s, s
    assert 'code2' in s, s

    assert len(s[s['status'] != 'alive']) == 0, s


if __name__ == '__main__':
    input, output = read_args(2, [file_path, not_file_path])

    source = read_from_source(input)
    transformed = transform(source)
    check(transformed)
    transformed.to_csv(output, index=False)