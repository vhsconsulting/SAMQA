-- liquibase formatted sql
-- changeset SAMQA:1754373938198 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.sales_assignment_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.sales_assignment_staging_seq.sql:null:90872a48076e04741e4f82bb64e0d700468fc7c3:create

grant select on samqa.sales_assignment_staging_seq to rl_sam_rw;

