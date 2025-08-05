-- liquibase formatted sql
-- changeset SAMQA:1754373937617 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.demo_order_items_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.demo_order_items_seq.sql:null:d8d19c48a12d9550d139d39474e626a021fd6ab0:create

grant select on samqa.demo_order_items_seq to rl_sam_rw;

