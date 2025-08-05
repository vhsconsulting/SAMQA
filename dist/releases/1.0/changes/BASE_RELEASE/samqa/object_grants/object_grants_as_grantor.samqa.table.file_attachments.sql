-- liquibase formatted sql
-- changeset SAMQA:1754373940477 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.file_attachments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.file_attachments.sql:null:ff8cbb5fb2662c2c999e1150b0e64cd8bb8048ac:create

grant select on samqa.file_attachments to rl_sam_ro;

