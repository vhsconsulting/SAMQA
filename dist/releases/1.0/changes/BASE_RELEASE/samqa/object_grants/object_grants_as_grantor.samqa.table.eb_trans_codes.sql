-- liquibase formatted sql
-- changeset SAMQA:1754373939833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eb_trans_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eb_trans_codes.sql:null:d0b0d08cc8aadf4a8837d03689a46776cfd746b7:create

grant delete on samqa.eb_trans_codes to rl_sam_rw;

grant insert on samqa.eb_trans_codes to rl_sam_rw;

grant select on samqa.eb_trans_codes to rl_sam1_ro;

grant select on samqa.eb_trans_codes to rl_sam_rw;

grant select on samqa.eb_trans_codes to rl_sam_ro;

grant update on samqa.eb_trans_codes to rl_sam_rw;

