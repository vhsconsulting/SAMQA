-- liquibase formatted sql
-- changeset SAMQA:1754373938230 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.sam_roles_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.sam_roles_seq.sql:null:53c93f6c5f4793a7515be0ba220736ce133a8411:create

grant select on samqa.sam_roles_seq to rl_sam_rw;

