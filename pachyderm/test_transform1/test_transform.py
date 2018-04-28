

with open('/pfs/input/numbers.txt') as f:
    squares = [str(int(x)*int(x)) for x in f.read().split("\n") if x and x.isdigit()]

with open('/pfs/out/squares.txt', 'w+') as f:
    f.write("\n".join(squares))

