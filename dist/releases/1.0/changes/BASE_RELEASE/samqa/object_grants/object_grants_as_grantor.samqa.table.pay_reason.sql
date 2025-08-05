-- liquibase formatted sql
-- changeset SAMQA:1754373941588 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.pay_reason.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.pay_reason.sql:null:2a71820867796841edd77194c8802dfea2a91d21:create

grant delete on samqa.pay_reason to rl_sam_rw;

grant insert on samqa.pay_reason to rl_sam_rw;

grant select on samqa.pay_reason to rl_sam1_ro;

grant select on samqa.pay_reason to rl_sam_rw;

grant select on samqa.pay_reason to rl_sam_ro;

grant select on samqa.pay_reason to reportdb_ro;

grant update on samqa.pay_reason to rl_sam_rw;

