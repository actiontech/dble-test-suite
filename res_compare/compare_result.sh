model_result=${1-"model_result"}
real_result=${2-"real_result"}
<<<<<<< HEAD

res=`diff -qr $1 $2`

if [ ${#res} -gt 0 ]; then
    echo "Oops! result is different with the standard one"
    exit 1
else
    echo "pass"
    exit 0
fi
=======
echo hello

diff $1 $2

echo diffover
>>>>>>> 4068dd40576e96ef79842f053fda0edab74ba0c6
