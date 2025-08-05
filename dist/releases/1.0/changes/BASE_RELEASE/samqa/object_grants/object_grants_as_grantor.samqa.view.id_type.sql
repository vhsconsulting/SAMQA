-- liquibase formatted sql
-- changeset SAMQA:1754373944371 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.id_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.id_type.sql:null:347853d8afc3bcbe1275a514eb07207371a59b91:create

grant select on samqa.id_type to rl_sam1_ro;

grant select on samqa.id_type to rl_sam_rw;

grant select on samqa.id_type to rl_sam_ro;

grant select on samqa.id_type to sgali;

