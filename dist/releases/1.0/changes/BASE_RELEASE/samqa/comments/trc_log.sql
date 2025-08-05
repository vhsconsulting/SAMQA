-- liquibase formatted sql
-- changeset samqa:1754373926779 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\trc_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/trc_log.sql:null:0da746196e0e2a9fc6a0e18240a94a6b131d3158:create

comment on table samqa.trc_log is
    'Trace log table for debug purpose';

