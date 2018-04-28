# We have data in yyyy/MM/dd/hh/mm.csv, this converts it into, hh/mm/yyyy/MM-dd.csv
# Since we're only shuffling files around, we will turn on empty files -
# pachyderm won't actually download the files to the pod

import shutil
import os
import re
import sys

assert len(sys.argv) == 2, "Expected 1 argument - the root of the dirs to re organize"
root = sys.argv[1][:-1] if sys.argv[1][-1] == "/" else sys.argv[1]
d_regex = "%s/(\d{4})/(\d{2})/(\d{2})/(\d{2})" % root
f_regex = "(\d{2}).csv"

print("root: {}, dir regex: {}, file regex: {}".format(root, d_regex, f_regex))


def bin_dirs(parsed_location):
    assert len(parsed_location) == 5

    year = parsed_location[0]
    month = parsed_location[1]
    day = parsed_location[2]
    hour = parsed_location[3]
    minute = parsed_location[4]

    assert "1000" <= year <= "9999", year
    assert "01" <= month <= "12", month
    assert "01" <= day <= "31", day
    assert "00" <= hour <= "23", hour
    assert "00" <= minute <= "59", minute

    return "/pfs/out/{}/{}/{}.csv".format(hour, minute, "{}-{}-{}".format(year, month, day))


def parse_dpath(dpath):
    assert os.path.isdir(dpath)

    d_matches = re.match(d_regex, dpath)
    assert d_matches and d_matches.lastindex == 4

    year, month, day, hour = d_matches[1], d_matches[2], d_matches[3], d_matches[4]

    return year, month, day, hour


def parse_fname(dpath, fname):
    assert os.path.isfile(os.path.join(dpath, fname))

    f_matches = re.match(f_regex, fname)
    assert f_matches and f_matches.lastindex == 1

    return f_matches[1]


def file_tree(bin_root):
    assert os.path.isdir(bin_root)
    assert bin_root[-1] != '/'

    def skip_condition(dpath, fnames):
        return not fnames and not re.match(d_regex, dpath)

    for (dirpath, dirnames, fnames) in os.walk(bin_root, topdown=False):
        print("Processing {}".format(dirpath))
        if skip_condition(dirpath, fnames):
            print("Skipping path {}, this is not a leaf directory".format(dirpath))
            continue

        assert(not skip_condition(dirpath, fnames))

        (year, month, day, hour) = parse_dpath(dirpath)
        for fname in fnames:

            minute = parse_fname(dirpath, fname)
            filepath = os.path.join(dirpath, fname)

            assert "1000" <= year <= "9999", year
            assert "01" <= month <= "12", month
            assert "01" <= day <= "31", day
            assert "00" <= hour <= "23", hour
            assert "00" <= minute <= "59", minute
            assert os.path.isfile(filepath), filepath

            yield ((year, month, day, hour, minute), filepath)


def move_to_new_loc(fpath, new_fpath):
    assert not os.path.isfile(new_fpath)

    if not os.path.isdir(os.path.dirname(new_fpath)):
        os.makedirs(os.path.dirname(new_fpath), exist_ok=True)

    shutil.move(fpath, new_fpath)


if __name__ == "__main__":
    count = 0
    for parsed_loc, fpath in file_tree(root):
        new_fpath = bin_dirs(parsed_loc)
        move_to_new_loc(fpath, new_fpath)
        count += 1

    assert count >= 1, "No files were processed, either an empty directory or doesn't obey the expected input fmt"
