-- liquibase formatted sql
-- changeset SAMQA:1754373939228 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.check_result_ext_cnb.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.check_result_ext_cnb.sql:null:4382961ad0b25f9bd9116b4e72dbf65d3f9dd7bd:create

grant select on samqa.check_result_ext_cnb to rl_sam_ro;

