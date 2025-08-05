-- liquibase formatted sql
-- changeset SAMQA:1754373938533 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.activity_statement_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.activity_statement_detail.sql:null:08b969f9ebff1607938bca7e1ffacdfdad3c8069:create

grant delete on samqa.activity_statement_detail to rl_sam_rw;

grant insert on samqa.activity_statement_detail to rl_sam_rw;

grant select on samqa.activity_statement_detail to rl_sam1_ro;

grant select on samqa.activity_statement_detail to rl_sam_rw;

grant select on samqa.activity_statement_detail to rl_sam_ro;

grant update on samqa.activity_statement_detail to rl_sam_rw;

