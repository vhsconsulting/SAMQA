-- liquibase formatted sql
-- changeset SAMQA:1754373944858 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.payment_statement_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.payment_statement_v.sql:null:d83f8dd4b933b5c0a58fa04107b4a12d2278b8f6:create

grant select on samqa.payment_statement_v to rl_sam1_ro;

grant select on samqa.payment_statement_v to rl_sam_rw;

grant select on samqa.payment_statement_v to rl_sam_ro;

grant select on samqa.payment_statement_v to sgali;

