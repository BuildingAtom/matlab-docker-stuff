#! /bin/bash

# Download all products page
wget -q https://www.mathworks.com/products/alphabetical.html

# Isolate the product list
grep /products/ alphabetical.html   \
    | grep \<li\>                   \
    | grep -Po \"\>[\\w\\s-]+       \
    | cut -c 3-                     \
    > all-matlab-products.txt

# Delete alphabetical.html
rm alphabetical.html

# Figure out where to cutoff
cutoff=`cat all-matlab-products.txt \
    | cut -c -3                     \
    | sort -c 2>&1 >/dev/null       \
    | grep -Eo [0-9]+`
cutoff=$(($cutoff-1))

# Save
head -n $cutoff all-matlab-products.txt \
    | sed -e "s/[[:space:]]*$//"        \
    | sed "s/ /_/g"                     \
    > all-matlab-products.txt.new
mv all-matlab-products.txt.new all-matlab-products.txt
