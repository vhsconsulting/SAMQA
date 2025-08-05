-- liquibase formatted sql
-- changeset SAMQA:1754373938198 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.reports_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.reports_seq.sql:null:6bb1a906ccd0263a721c2a229d08210f21b5dfc9:create

grant select on samqa.reports_seq to rl_sam_rw;

