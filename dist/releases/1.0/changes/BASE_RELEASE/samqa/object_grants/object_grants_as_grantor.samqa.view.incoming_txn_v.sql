-- liquibase formatted sql
-- changeset SAMQA:1754373944427 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.incoming_txn_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.incoming_txn_v.sql:null:0a0b26573a8f3b7295368f4bd3b5cf853c28bc36:create

grant select on samqa.incoming_txn_v to rl_sam1_ro;

grant select on samqa.incoming_txn_v to rl_sam_rw;

grant select on samqa.incoming_txn_v to rl_sam_ro;

grant select on samqa.incoming_txn_v to sgali;

