-- liquibase formatted sql
-- changeset SAMQA:1754373938964 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.beneficiary.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.beneficiary.sql:null:004d52e8801fb5240bbcb8734c6704283c4efcec:create

grant delete on samqa.beneficiary to rl_sam_rw;

grant insert on samqa.beneficiary to rl_sam_rw;

grant select on samqa.beneficiary to rl_sam1_ro;

grant select on samqa.beneficiary to rl_sam_rw;

grant select on samqa.beneficiary to rl_sam_ro;

grant update on samqa.beneficiary to rl_sam_rw;

