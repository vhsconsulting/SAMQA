-- liquibase formatted sql
-- changeset SAMQA:1754373942650 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.varchar2_4000_tbl.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.varchar2_4000_tbl.sql:null:0ddf0d4098c5a1113a7ebb416e5ef0db4f1d3819:create

grant execute on samqa.varchar2_4000_tbl to rl_sam1_ro;

grant execute on samqa.varchar2_4000_tbl to rl_sam_ro;

grant execute on samqa.varchar2_4000_tbl to rl_sam_rw;

