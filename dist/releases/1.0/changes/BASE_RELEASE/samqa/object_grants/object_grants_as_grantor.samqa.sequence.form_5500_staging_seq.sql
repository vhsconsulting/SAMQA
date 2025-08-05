-- liquibase formatted sql
-- changeset SAMQA:1754373937817 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.form_5500_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.form_5500_staging_seq.sql:null:242d89467cb612d0ec1a0ecc9c5a78405698a8cc:create

grant select on samqa.form_5500_staging_seq to rl_sam_rw;

