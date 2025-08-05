-- liquibase formatted sql
-- changeset SAMQA:1754373937603 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.demo_cust_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.demo_cust_seq.sql:null:c602b6b7b55cf4ed153a4f7df6a278d1a93c505f:create

grant select on samqa.demo_cust_seq to rl_sam_rw;

