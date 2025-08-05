-- liquibase formatted sql
-- changeset SAMQA:1754373941325 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.news.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.news.sql:null:7c8e769d978670e59a0feccec88c6db7c99fe6d5:create

grant delete on samqa.news to rl_sam_rw;

grant insert on samqa.news to rl_sam_rw;

grant select on samqa.news to rl_sam1_ro;

grant select on samqa.news to rl_sam_rw;

grant select on samqa.news to rl_sam_ro;

grant update on samqa.news to rl_sam_rw;

