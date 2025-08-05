-- liquibase formatted sql
-- changeset SAMQA:1754373938435 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.account_preference.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.account_preference.sql:null:c5b2955e49d0a0dfdad2911ad3a8dc568cbc7ac5:create

grant delete on samqa.account_preference to rl_sam_rw;

grant insert on samqa.account_preference to rl_sam_rw;

grant select on samqa.account_preference to rl_sam1_ro;

grant select on samqa.account_preference to rl_sam_rw;

grant select on samqa.account_preference to rl_sam_ro;

grant update on samqa.account_preference to rl_sam_rw;

