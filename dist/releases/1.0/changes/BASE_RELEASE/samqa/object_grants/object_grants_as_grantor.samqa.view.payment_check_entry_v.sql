-- liquibase formatted sql
-- changeset SAMQA:1754373944842 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.payment_check_entry_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.payment_check_entry_v.sql:null:95a21ebb9266fbf080dfe06a2b2da15f017cf1d8:create

grant select on samqa.payment_check_entry_v to rl_sam1_ro;

grant select on samqa.payment_check_entry_v to rl_sam_rw;

grant select on samqa.payment_check_entry_v to rl_sam_ro;

grant select on samqa.payment_check_entry_v to sgali;

