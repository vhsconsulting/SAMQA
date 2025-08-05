-- liquibase formatted sql
-- changeset SAMQA:1754373941110 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.medicare_pers_record.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.medicare_pers_record.sql:null:e6b4c78d96bbd386e1c5598dcc9c814260c2457e:create

grant delete on samqa.medicare_pers_record to rl_sam_rw;

grant insert on samqa.medicare_pers_record to rl_sam_rw;

grant select on samqa.medicare_pers_record to rl_sam1_ro;

grant select on samqa.medicare_pers_record to rl_sam_rw;

grant select on samqa.medicare_pers_record to rl_sam_ro;

grant update on samqa.medicare_pers_record to rl_sam_rw;

