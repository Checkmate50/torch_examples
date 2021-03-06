import random, sys

def foo(x, y, z):
    return x*x+x*y+y*z+z*z

def main():
    if len(sys.argv) == 1:
        print("number of output file must be given")
        exit(0)

    f = open("cftests/" + sys.argv[1] + ".txt", 'w')
    count = 512
    if len(sys.argv) == 3:
        count = int(sys.argv[2])

    for i in range(count):
        x = random.random()*2-1
        y = random.random()*2-1
        z = random.random()*2-1
        out = foo(x, y, z)
        f.write(str(x) + "\t" + str(y) + "\t" + str(z) + "\t" + str(out) + "\n")

    f.close()

if __name__ == "__main__":
    main()
