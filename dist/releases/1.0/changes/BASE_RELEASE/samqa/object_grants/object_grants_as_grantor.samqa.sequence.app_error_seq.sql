-- liquibase formatted sql
-- changeset SAMQA:1754373937329 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.app_error_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.app_error_seq.sql:null:171717be3de41cbacc6e187c92d768b7bdac90c2:create

grant select on samqa.app_error_seq to rl_sam_rw;

