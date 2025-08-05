-- liquibase formatted sql
-- changeset SAMQA:1754373940463 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.fee_names.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.fee_names.sql:null:18d971893ae80060f2cb891c52eee09c55db9ff8:create

grant alter on samqa.fee_names to newcobra;

grant delete on samqa.fee_names to newcobra;

grant delete on samqa.fee_names to rl_sam_rw;

grant index on samqa.fee_names to newcobra;

grant insert on samqa.fee_names to newcobra;

grant insert on samqa.fee_names to rl_sam_rw;

grant select on samqa.fee_names to rl_sam1_ro;

grant select on samqa.fee_names to newcobra;

grant select on samqa.fee_names to rl_sam_rw;

grant select on samqa.fee_names to rl_sam_ro;

grant update on samqa.fee_names to newcobra;

grant update on samqa.fee_names to rl_sam_rw;

grant references on samqa.fee_names to newcobra;

grant read on samqa.fee_names to newcobra;

grant on commit refresh on samqa.fee_names to newcobra;

grant query rewrite on samqa.fee_names to newcobra;

grant debug on samqa.fee_names to newcobra;

grant flashback on samqa.fee_names to newcobra;

