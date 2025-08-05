-- liquibase formatted sql
-- changeset SAMQA:1754373935373 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_quarter_date.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_quarter_date.sql:null:b37aba911101dc240fe8be076e13e64fcdb72949:create

grant execute on samqa.get_quarter_date to rl_sam_ro;

