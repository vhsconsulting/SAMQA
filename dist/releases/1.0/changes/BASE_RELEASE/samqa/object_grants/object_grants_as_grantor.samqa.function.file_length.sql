-- liquibase formatted sql
-- changeset SAMQA:1754373935208 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.file_length.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.file_length.sql:null:72bb52881c6a661e954cd7428865c236bd25399e:create

grant execute on samqa.file_length to rl_sam_ro;

