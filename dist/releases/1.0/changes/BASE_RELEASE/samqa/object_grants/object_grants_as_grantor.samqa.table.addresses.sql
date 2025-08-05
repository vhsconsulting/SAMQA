-- liquibase formatted sql
-- changeset SAMQA:1754373938540 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.addresses.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.addresses.sql:null:e5fa6b60c5283ed6c7297c9f1ce087feebd11201:create

grant delete on samqa.addresses to rl_sam_rw;

grant insert on samqa.addresses to rl_sam_rw;

grant select on samqa.addresses to rl_sam1_ro;

grant select on samqa.addresses to rl_sam_ro;

grant select on samqa.addresses to rl_sam_rw;

grant update on samqa.addresses to rl_sam_rw;

