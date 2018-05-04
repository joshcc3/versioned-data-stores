import os
import sys


def file_path(f):
    assert os.path.exists(f)
    return f

def not_file_path(f):
    assert not os.path.exists(f)
    return f

def empty_file_path(f):
    f1 = file_path(f)
    assert len(os.listdir(f1)) == 0
    return f1


def non_empty_file_path(f):
    f1 = file_path(f)
    assert len(os.listdir(f1)) > 0
    return f1


def read_args(n, checks=None, distinct = True):
    args = sys.argv[1:]
    assert len(args) == n, args
    assert not checks or len(checks) == n, checks
    [check(a) for a, check in zip(args, checks)] if checks else []
    assert len(set(args)) == n if distinct else []
    return args