-- liquibase formatted sql
-- changeset SAMQA:1754373938002 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.mig_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.mig_seq.sql:null:85e9f27542904674f663564e30f87a5dc3a177f6:create

grant select on samqa.mig_seq to rl_sam_rw;

