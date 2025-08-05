-- liquibase formatted sql
-- changeset SAMQA:1754373944602 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.myclaimn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.myclaimn.sql:null:a1c2c843bfa07aa197c9d9e781cf5540c44ababc:create

grant select on samqa.myclaimn to rl_sam1_ro;

grant select on samqa.myclaimn to rl_sam_rw;

grant select on samqa.myclaimn to rl_sam_ro;

grant select on samqa.myclaimn to sgali;

