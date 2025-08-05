-- liquibase formatted sql
-- changeset SAMQA:1754373937735 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.eob_header_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.eob_header_seq.sql:null:ce3c960f802dfd1da9c5e50b07dae9db3622acc9:create

grant select on samqa.eob_header_seq to rl_sam_rw;

