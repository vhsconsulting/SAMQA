-- liquibase formatted sql
-- changeset SAMQA:1754373935226 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.format_ssn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.format_ssn.sql:null:f40b3047eb2031dfb1677ed21464b3157d8546a1:create

grant execute on samqa.format_ssn to rl_sam_ro;

