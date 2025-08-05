-- liquibase formatted sql
-- changeset samqa:1754373926454 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\all_audit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/all_audit.sql:null:1ee36957bdfbdac7c9c5e5a64db812af30f5f7c3:create

comment on table samqa.all_audit is
    'Application log';

comment on column samqa.all_audit.cod1 is
    'Primary key, first field';

