-- liquibase formatted sql
-- changeset SAMQA:1754373943740 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.en_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.en_type.sql:null:441ee555dedb6908d954c17b9dd9e52e756ce060:create

grant select on samqa.en_type to rl_sam1_ro;

grant select on samqa.en_type to rl_sam_rw;

grant select on samqa.en_type to rl_sam_ro;

grant select on samqa.en_type to sgali;

