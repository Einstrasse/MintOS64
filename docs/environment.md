# Environment Settings

## Basic
```
- OS : Ubuntu 16.04
- Kernel : 4.15.0-43-generic #46~16.04.1-Ubuntu SMP Fri Dec 7 13:31:08 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
```

## Packages
```
apt install -y binutils bison flex gcc libtool make patchutils nasm

```


## Interoperability between Win and Ubuntu (Build Level)
There is something to fix to sustain compatibility.
First of all, you should install nasm(netwide assembler).

And fix makefile describing gcc, ld, objcopy for cygwin to linux.

Finally, ImageMaker.c source code file, you extract io.h header file and ommiting O_BINARY option for open function.

## Q Emulator