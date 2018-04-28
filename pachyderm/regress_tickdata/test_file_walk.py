import os

for (dirpath, dirnames, fnames) in os.walk('/test_dir', topdown=False):
    print("Dirpath: {}".format(dirpath))
    print("Dirnames: {}".format(dirnames))
    print("Fnames: {}".format(fnames))
    print("----------------------------")
    test = input("Continue")