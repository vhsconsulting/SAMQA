-- liquibase formatted sql
-- changeset SAMQA:1754373938214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.sales_comm_paid_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.sales_comm_paid_seq.sql:null:cbeab96d67df91046eea741382d9fe759c9a9e9e:create

grant select on samqa.sales_comm_paid_seq to rl_sam_rw;

