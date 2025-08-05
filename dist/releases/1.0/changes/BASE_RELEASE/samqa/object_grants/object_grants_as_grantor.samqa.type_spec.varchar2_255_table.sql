-- liquibase formatted sql
-- changeset SAMQA:1754373942645 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.varchar2_255_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.varchar2_255_table.sql:null:1439c593362c10936c66b5c803d559ae0d6f6ef8:create

grant execute on samqa.varchar2_255_table to rl_sam1_ro;

grant execute on samqa.varchar2_255_table to rl_sam_ro;

grant execute on samqa.varchar2_255_table to rl_sam_rw;

