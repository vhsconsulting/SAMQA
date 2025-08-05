-- liquibase formatted sql
-- changeset SAMQA:1754373942576 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.chart_table_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.chart_table_type.sql:null:3f0e457f367551a26d944dd54aaf64f46b0249a0:create

grant execute on samqa.chart_table_type to rl_sam_rw;

grant execute on samqa.chart_table_type to rl_sam1_ro;

grant execute on samqa.chart_table_type to rl_sam_ro;

