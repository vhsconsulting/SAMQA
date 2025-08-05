-- liquibase formatted sql
-- changeset SAMQA:1754373938198 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.rgst_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.rgst_seq.sql:null:e326848dd8b36418a2db26ea852505db0c721013:create

grant select on samqa.rgst_seq to rl_sam_rw;

