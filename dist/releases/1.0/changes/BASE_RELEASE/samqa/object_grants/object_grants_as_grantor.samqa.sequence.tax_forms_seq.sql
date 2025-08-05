-- liquibase formatted sql
-- changeset SAMQA:1754373938293 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.tax_forms_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.tax_forms_seq.sql:null:82e82ba55879177490c5aba2e334f4df6d492ed7:create

grant select on samqa.tax_forms_seq to rl_sam_rw;

