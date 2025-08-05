-- liquibase formatted sql
-- changeset SAMQA:1754373935258 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_cursor.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_cursor.sql:null:cc7faa7aa1a7d3f9e797b83f1f4ad3e1199fe13e:create

grant execute on samqa.get_cursor to rl_sam_ro;

