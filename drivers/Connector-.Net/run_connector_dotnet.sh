#!/bin/bash
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
DIR="$( cd "$( dirname "$0" )" && pwd )"

echo '=======                       compile                                ======='
cd ${DIR}/netdriver && csc -out:test.exe -r:MySql.Data.dll -r:YamlDotNet.dll *.cs
echo '=======                        driver test                           ======='
cd ${DIR} && source do_run_connector_dotnet.sh -c
if [ ${#res} -gt 0 ]; then
    echo "Oop! results are different with the standard ones, try 'diff -wr ${cmp_std_res_dir} ${cmp_real_res_dir}' to see the details"
    echo "${res}"
    exit 1
else
    echo "pass"
    exit 0
fi