-- liquibase formatted sql
-- changeset SAMQA:1754373942582 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.date_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.date_table.sql:null:f02f393f4bc9dee4a87cbbd44e2c9320913a7970:create

grant execute on samqa.date_table to rl_sam1_ro;

grant execute on samqa.date_table to rl_sam_rw;

grant execute on samqa.date_table to rl_sam_ro;

