-- liquibase formatted sql
-- changeset SAMQA:1754373941596 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.payment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.payment.sql:null:5123325e06d908b49bc0cee8930b4322d094e945:create

grant delete on samqa.payment to rl_sam_rw;

grant insert on samqa.payment to rl_sam_rw;

grant select on samqa.payment to rl_sam1_ro;

grant select on samqa.payment to rl_sam_rw;

grant select on samqa.payment to rl_sam_ro;

grant update on samqa.payment to rl_sam_rw;

