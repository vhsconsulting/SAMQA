-- liquibase formatted sql
-- changeset SAMQA:1754373938119 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.payment_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.payment_register_seq.sql:null:b1977f301fe98c365b96d3f96a1f7934aada4b5e:create

grant select on samqa.payment_register_seq to rl_sam_rw;

