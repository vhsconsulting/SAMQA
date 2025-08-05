-- liquibase formatted sql
-- changeset SAMQA:1754373937946 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.man_trans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.man_trans.sql:null:711db2d4dd1a54b90d2112aaa0f14ed21ace680c:create

grant select on samqa.man_trans to rl_sam_rw;

