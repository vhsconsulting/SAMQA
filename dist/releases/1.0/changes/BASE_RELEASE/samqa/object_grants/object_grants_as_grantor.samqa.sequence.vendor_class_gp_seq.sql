-- liquibase formatted sql
-- changeset SAMQA:1754373938333 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.vendor_class_gp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.vendor_class_gp_seq.sql:null:814c6be343d5c449a2590ec4649504f47c6fdcda:create

grant select on samqa.vendor_class_gp_seq to rl_sam_rw;

