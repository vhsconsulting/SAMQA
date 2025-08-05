-- liquibase formatted sql
-- changeset SAMQA:1754373937740 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.er_bal_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.er_bal_register_seq.sql:null:8d0df252eae5ec895e7edc17933e67253ee39ef6:create

grant select on samqa.er_bal_register_seq to rl_sam_rw;

