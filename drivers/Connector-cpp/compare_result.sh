#!/bin/bash
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
std_result_dir=${1-"std_result"}
real_result_dir=${2-"sql_cover_log"}
cmp_std_res_dir=cmp_${std_result_dir}
cmp_real_res_dir=cmp_${real_result_dir}

#echo "generate real diff files"
generate_simple_cmp_file () {
	files=$(ls $1| egrep -v "*_pass.log|balance")

    for s in $files; do
        if [ -d "$1/$s" ]; then
#            echo "$s is dir"
            generate_simple_cmp_file "$1/$s" "$2/$s"
		else
#		    echo "source: $1/$s, dest:"$2/$s""
            mkdir -p "$2"
            grep '===file:' "$1/$s" > "$2/$s"
            #added by zhaohongjie(for driver testing)
            #grep '===id:' "$1/$s" >> "$2/$s"
        fi
    done
}

rm -rf ${cmp_std_res_dir} && mkdir ${cmp_std_res_dir}
rm -rf ${cmp_real_res_dir} && mkdir ${cmp_real_res_dir}
generate_simple_cmp_file ${std_result_dir} ${cmp_std_res_dir}
generate_simple_cmp_file ${real_result_dir} ${cmp_real_res_dir}

res=`diff -qwr ${cmp_std_res_dir} ${cmp_real_res_dir}`
