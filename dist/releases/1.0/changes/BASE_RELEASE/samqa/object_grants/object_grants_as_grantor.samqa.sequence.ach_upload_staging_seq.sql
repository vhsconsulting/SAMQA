-- liquibase formatted sql
-- changeset SAMQA:1754373937302 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ach_upload_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ach_upload_staging_seq.sql:null:bec58b7e3d6cce6eb87d7955c72944813ffd3c2d:create

grant select on samqa.ach_upload_staging_seq to rl_sam_rw;

