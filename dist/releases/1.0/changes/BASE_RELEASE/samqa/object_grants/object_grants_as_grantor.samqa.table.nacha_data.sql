-- liquibase formatted sql
-- changeset SAMQA:1754373941294 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.nacha_data.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.nacha_data.sql:null:a655a360cac16824b5d590ff984da7ec26cd18f1:create

grant delete on samqa.nacha_data to rl_sam_rw;

grant insert on samqa.nacha_data to rl_sam_rw;

grant select on samqa.nacha_data to rl_sam1_ro;

grant select on samqa.nacha_data to rl_sam_rw;

grant select on samqa.nacha_data to rl_sam_ro;

grant update on samqa.nacha_data to rl_sam_rw;

