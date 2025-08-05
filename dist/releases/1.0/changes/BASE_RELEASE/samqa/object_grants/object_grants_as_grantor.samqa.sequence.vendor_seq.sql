-- liquibase formatted sql
-- changeset SAMQA:1754373938341 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.vendor_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.vendor_seq.sql:null:f69aea133a4c0780bbc6ace7b354574b46fc11e1:create

grant select on samqa.vendor_seq to rl_sam_rw;

