-- liquibase formatted sql
-- changeset SAMQA:1754373937448 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.checkbook_gp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.checkbook_gp_seq.sql:null:f5c468e2c5a25334f08bbeda334bf4d1bcae97a5:create

grant select on samqa.checkbook_gp_seq to rl_sam_rw;

