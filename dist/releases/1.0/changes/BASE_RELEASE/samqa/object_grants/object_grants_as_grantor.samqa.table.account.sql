-- liquibase formatted sql
-- changeset SAMQA:1754373938384 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.account.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.account.sql:null:b5e925a438318faee1cb68ac74caa40a52681938:create

grant alter on samqa.account to newcobra;

grant delete on samqa.account to newcobra;

grant delete on samqa.account to rl_sam_rw;

grant index on samqa.account to newcobra;

grant insert on samqa.account to newcobra;

grant insert on samqa.account to rl_sam_rw;

grant insert on samqa.account to cobra;

grant select on samqa.account to rl_sam1_ro;

grant select on samqa.account to newcobra;

grant select on samqa.account to reportdb_ro;

grant select on samqa.account to rl_sam_rw;

grant select on samqa.account to rl_sam_ro;

grant select on samqa.account to asis;

grant select on samqa.account to cobra;

grant update on samqa.account to newcobra;

grant update on samqa.account to rl_sam_rw;

grant update on samqa.account to cobra;

grant references on samqa.account to newcobra;

grant read on samqa.account to newcobra;

grant on commit refresh on samqa.account to newcobra;

grant query rewrite on samqa.account to newcobra;

grant debug on samqa.account to newcobra;

grant flashback on samqa.account to newcobra;

