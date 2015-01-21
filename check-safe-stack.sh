#! /bin/bash

file="$1"
OS=$(uname -s)
ARCH=$(uname -i)

function usage()
{
    echo ./check-safe-stack.sh '<binary>'
    exit
}

if [[ $# -eq 0 ]] ; then
    usage
fi

if ! [[ -r "$file" ]] ; then
    echo "$file: permission denied"
    exit 1
fi

if objdump -x "$file" | grep '\.note\.SafeStack' ; then
    echo "found SafeStack note."
else
    echo "SafeStack note missing."
    exit 1
fi

if [[ "$OS" = "FreeBSD" -a "$ARCH" = "amd64" ]] ; then
    if objdump -d "$file" | grep '%fs:0x18' ; then
        echo "found SafeStack usage."
    else
        echo "SafeStack usage missing."
        exit 1
    fi
elif [[ "$OS" = "FreeBSD" -a "$ARCH" = "i386" ]] ; then
    if objdump -d "$file" | grep '%gs:0xc' ; then
        echo "found SafeStack usage."
    else
        echo "SafeStack usage missing."
        exit 1
    fi
else
    if objdump -x "$file" | grep '__safestack_init' ; then
        echo "found __safestack_init."
    else
        echo "__safestack_init missing."
        exit 1
    fi
fi

echo "$file sounds good ;-)"

