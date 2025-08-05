-- liquibase formatted sql
-- changeset SAMQA:1754373937833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.gp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.gp_seq.sql:null:80cee5bc7588122d67f95c16a2d4aa9e955da5a2:create

grant select on samqa.gp_seq to rl_sam_rw;

