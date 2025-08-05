-- liquibase formatted sql
-- changeset SAMQA:1754373944017 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_fee_invoices_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_fee_invoices_v.sql:null:a06d3457928064e82c35c49729871b0f9226e7dd:create

grant select on samqa.fsa_fee_invoices_v to rl_sam1_ro;

grant select on samqa.fsa_fee_invoices_v to rl_sam_rw;

grant select on samqa.fsa_fee_invoices_v to rl_sam_ro;

grant select on samqa.fsa_fee_invoices_v to sgali;

