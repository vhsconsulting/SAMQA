-- liquibase formatted sql
-- changeset SAMQA:1754373941836 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.receivable_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.receivable_details.sql:null:f47f35bc222ce4f01219209160ae8d0a39ed9e65:create

grant delete on samqa.receivable_details to rl_sam_rw;

grant insert on samqa.receivable_details to rl_sam_rw;

grant select on samqa.receivable_details to rl_sam1_ro;

grant select on samqa.receivable_details to rl_sam_rw;

grant select on samqa.receivable_details to rl_sam_ro;

grant update on samqa.receivable_details to rl_sam_rw;

