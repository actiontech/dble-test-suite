#!/bin/bash
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
DIR="$( cd "$( dirname "$0" )" && pwd )"
echo '=======                       package                                ======='
cd ${DIR} && /usr/local/apache-maven/bin/mvn -DskipTest clean package assembly:assembly

echo '=======                        driver test                           ======='
cd ${DIR}/ && source do_run_connector_J.sh Jconnector-5.1.35-jar-with-dependencies.jar -c
if [ ${#res} -gt 0 ]; then
    echo "Oop! results are different with the standard ones, try 'diff -wr ${cmp_std_res_dir} ${cmp_real_res_dir}' to see the details"
    echo "${res}"
    exit 1
else
    echo "pass"
    exit 0
fi