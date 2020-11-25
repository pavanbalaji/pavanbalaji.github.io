#! /bin/bash -xv

while [ 1 ] ; do
    dir=/tmp/genpub.${USER}.${RANDOM}
    if test ! -e $dir ; then mkdir $dir ; break ; fi
done

git clone git@github.com:pavanbalaji/balaji-cv ${dir}

cat ${dir}/text/selected_publications.tex | \
    sed -e 's/%.*//g' | \
    awk '{ \
        if ($0 ~ /\\item/)
	   item = 1;
	if ($0 ~ /^$/) {
	   item = 0;
	   printf("\n");
	}
	if (item)
	   printf("%s", $0);
	else
	   print $0;
    }' | \
    egrep -v '(^ |enumerate|vspace)' | \
    awk '{
        if ($0 ~ /^$/ && empty == 0) {
	   empty = 1;
	   print $0;
	}
	else if ($0 !~ /^$/) {
	   empty = 0;
           print $0;
	}
    }' | \
    sed -e 's/  */ /g' \
	-e 's/} *{/}{/g' \
	-e 's/\\\&/\&/g' \
	-e "s/\\\'//g" \
	-e 's/\\item/\*/g' \
	-e 's/\$\\[^{]*{\([^}]*\)\}\$/\1/g' \
	-e 's/\\emph{\([^}]*\)}/**\1**/g' \
	-e 's/\\href{\([^}]*\)}{\([^}]*\)}/[\2](\1)/g' \
	-e 's/\\section{\([^}]*\)}/# \1/g' \
	-e 's/\\subsection{\([^}]*\)}/## \1/g' \
	-e 's+https://www.mcs.anl.gov/~balaji+{{ site.baseurl }}+g' > publications.md

rm -rf ${dir}
