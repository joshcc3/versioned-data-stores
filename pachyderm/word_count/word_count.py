import os
from itertools import takewhile, dropwhile

def scanl(gen, accumF, seed):
    for a in gen:
        yield seeds
        seed = accumF(seed, a)
    yield seed

def foldl(gen, accumF, seed):
    for a in gen:
        seed = accumF(seed, a)
    return seed

def unfold(gen, seed):
  seed = gen(seed)

  while seed:
    seed, value = seed
    yield value
    seed = gen(seed)


lower = range(ord('a'), ord('z') + 1)
upper = range(ord('A'), ord('Z') + 1)
nums =  range(ord('0'), ord('9') + 1)
alphanum_nonpunc = "".join([chr(x) for x in lower + upper + nums]) + "_-'@"


def accumF(count, document):
    assert os.path.isfile(document)

    def split_word(s):
        if not s:
            return None
        else:
            word = takewhile(lambda x: x in alphanum_nonpunc, s)
            rest_of_string = dropwhile(lambda x: x not in alphanum_nonpunc, s[len(word)+1:])
            return rest_of_string, word

    with open(document) as f:
        doc_contents = f.read()

    return count + foldl(unfold(split_word, doc_contents), lambda (a, b): a + 1, 0)


fs = (file for (_, _, files) in os.walk('/pfs/documents') for file in files)

with open('/pfs/out/rolling_word_count.txt', 'w+') as f:
    for f, count in zip([''] + fs, scanl(fs, accumF, 0)):
        f.write("{}: {}\n".format(f, count))