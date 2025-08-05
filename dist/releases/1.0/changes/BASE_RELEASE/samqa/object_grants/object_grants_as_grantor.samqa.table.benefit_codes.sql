-- liquibase formatted sql
-- changeset SAMQA:1754373938979 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.benefit_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.benefit_codes.sql:null:5ae130ea6a112ee403eee5dfcc291fb90154ef85:create

grant delete on samqa.benefit_codes to rl_sam_rw;

grant insert on samqa.benefit_codes to rl_sam_rw;

grant select on samqa.benefit_codes to rl_sam1_ro;

grant select on samqa.benefit_codes to rl_sam_rw;

grant select on samqa.benefit_codes to rl_sam_ro;

grant update on samqa.benefit_codes to rl_sam_rw;

