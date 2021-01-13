#!/bin/bash
docker cp /opt/behave/dble-test-suite/behave_dble/compose/setalias/dble.sh dble-1:/opt/dble.sh
docker cp /opt/behave/dble-test-suite/behave_dble/compose/setalias/dble.sh dble-2:/opt/dble.sh
docker cp /opt/behave/dble-test-suite/behave_dble/compose/setalias/dble.sh dble-3:/opt/dble.sh

#docker exec -it behave bash "/init_assets/dble-test-suite/behave_dble/compose/setalias/behave.sh"
docker exec -it dble-1 bash "/opt/dble.sh"
docker exec -it dble-2 bash "/opt/dble.sh"
docker exec -it dble-3 bash "/opt/dble.sh"

docker exec -it behave bash "/opt/behave/dble-test-suite/behave_dble/compose/setalias/behave.sh"

/bin/bash
