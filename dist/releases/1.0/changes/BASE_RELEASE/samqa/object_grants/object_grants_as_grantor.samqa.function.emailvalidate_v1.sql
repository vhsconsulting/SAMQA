-- liquibase formatted sql
-- changeset SAMQA:1754373935194 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.emailvalidate_v1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.emailvalidate_v1.sql:null:4bcf263c5fdd37b07bec97dec5f536c43671c00e:create

grant execute on samqa.emailvalidate_v1 to rl_sam_ro;

grant execute on samqa.emailvalidate_v1 to rl_sam_rw;

grant execute on samqa.emailvalidate_v1 to rl_sam1_ro;

grant debug on samqa.emailvalidate_v1 to sgali;

grant debug on samqa.emailvalidate_v1 to rl_sam_rw;

grant debug on samqa.emailvalidate_v1 to rl_sam1_ro;

