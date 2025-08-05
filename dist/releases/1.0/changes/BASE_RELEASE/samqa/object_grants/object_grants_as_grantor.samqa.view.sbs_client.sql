-- liquibase formatted sql
-- changeset SAMQA:1754373945078 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.sbs_client.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.sbs_client.sql:null:84d7ab8c6b5b8fa7acd3267224c545e22857189f:create

grant select on samqa.sbs_client to rl_sam_ro;

grant select on samqa.sbs_client to rl_sam_rw;

