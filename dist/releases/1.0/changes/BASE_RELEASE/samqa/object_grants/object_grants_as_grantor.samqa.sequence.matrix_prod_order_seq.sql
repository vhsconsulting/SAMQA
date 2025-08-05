-- liquibase formatted sql
-- changeset SAMQA:1754373937978 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.matrix_prod_order_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.matrix_prod_order_seq.sql:null:5ff603347011b74a02e09579be21d1cc164a389e:create

grant select on samqa.matrix_prod_order_seq to rl_sam_rw;

