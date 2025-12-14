#!/bin/bash
echo "empieza el programa enciende todas\n"

{ printf "practica\ncos\n1\n9\n1\nyes\n\n\033\0334\n"; } | telnet 158.42.181.244

echo "acabado el programa enciende todas\n"
