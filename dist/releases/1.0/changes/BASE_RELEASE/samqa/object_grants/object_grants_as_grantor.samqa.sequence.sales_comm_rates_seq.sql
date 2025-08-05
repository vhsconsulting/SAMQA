-- liquibase formatted sql
-- changeset SAMQA:1754373938214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.sales_comm_rates_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.sales_comm_rates_seq.sql:null:8f7391b213ef5de7c01c3c02640f0af920fe9f9b:create

grant select on samqa.sales_comm_rates_seq to rl_sam_rw;

