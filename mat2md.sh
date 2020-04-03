#!/bin/bash

rm -r docs/mfiles

SRC_FOLDERS=("01_generator" "02_splitter" "03_parser")

for SRC in "${SRC_FOLDERS[@]}"; do
    echo "--------------------------------------------"
    echo "I am in folder $SRC"
    echo "--------------------------------------------"

    cd $SRC
    # find all m-files in current folder but ignore the folder 'auxfuns'
    for i in `find . -iname '*.m' -not -path './auxfuns/*'`
    do
        cp $i ../;
    done
    cd ..
    make all mfiledir=docs/mfiles/$SRC
    rm *.m
done

mkdocs build --clean
