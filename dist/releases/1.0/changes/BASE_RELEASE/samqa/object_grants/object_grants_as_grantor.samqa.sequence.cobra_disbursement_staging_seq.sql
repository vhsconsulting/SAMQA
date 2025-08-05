-- liquibase formatted sql
-- changeset SAMQA:1754373937497 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.cobra_disbursement_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.cobra_disbursement_staging_seq.sql:null:7dbc0b48f6e967948312b0163ce9891e382f6fb7:create

grant select on samqa.cobra_disbursement_staging_seq to rl_sam_rw;

