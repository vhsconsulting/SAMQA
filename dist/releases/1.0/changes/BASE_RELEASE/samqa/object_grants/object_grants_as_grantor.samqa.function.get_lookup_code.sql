-- liquibase formatted sql
-- changeset SAMQA:1754373935332 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_lookup_code.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_lookup_code.sql:null:6813908d2bf77ac8b31414553d79bcc7bdd90984:create

grant execute on samqa.get_lookup_code to rl_sam_ro;

grant execute on samqa.get_lookup_code to rl_sam_rw;

grant execute on samqa.get_lookup_code to rl_sam1_ro;

grant debug on samqa.get_lookup_code to sgali;

grant debug on samqa.get_lookup_code to rl_sam_rw;

grant debug on samqa.get_lookup_code to rl_sam1_ro;

