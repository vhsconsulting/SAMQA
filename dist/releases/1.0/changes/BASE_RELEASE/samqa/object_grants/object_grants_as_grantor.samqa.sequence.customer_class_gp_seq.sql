-- liquibase formatted sql
-- changeset SAMQA:1754373937568 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.customer_class_gp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.customer_class_gp_seq.sql:null:161cd2c4bf5278b3bea383e92d3820bcdc5e6482:create

grant select on samqa.customer_class_gp_seq to rl_sam_rw;

