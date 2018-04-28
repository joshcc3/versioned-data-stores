import os

lower = list(range(ord('a'), ord('z') + 1))
upper = list(range(ord('A'), ord('Z') + 1))
nums =  list(range(ord('0'), ord('9') + 1))
alphanum_nonpunc = "".join([chr(x) for x in lower + upper + nums]) + "_-'@"



def wordcount(files):
    def count_words(file):
        assert os.path.isfile(file), file

        def update(ch, state):
            if state['in_word'] and ch not in alphanum_nonpunc:
                state['in_word'] = False
            elif not state['in_word'] and ch in alphanum_nonpunc:
                state['word_count'] += 1
                state['in_word'] = True
            elif not state['in_word'] and ch not in alphanum_nonpunc:
                pass
            elif state['in_word'] and ch in alphanum_nonpunc:
                pass
            else:
                raise Exception("Should never get here")

        with open(file) as f:
            fcs = f.read()

        loop_state = {'word_count': 0, 'in_word': False}
        for ch in fcs:
            update(ch, loop_state)

        return loop_state['word_count']

    acc = 0
    for file in files:
        acc += count_words(file)
        yield (file, acc)

fs = (os.path.join('pfs', 'documents', file) for (_, _, files) in os.walk('/pfs/documents') for file in files)

with open('/pfs/out/rolling_word_count.txt', 'w+') as fd:
    for f, count in wordcount(fs):
        fd.write("{}: {}\n".format(f, count))