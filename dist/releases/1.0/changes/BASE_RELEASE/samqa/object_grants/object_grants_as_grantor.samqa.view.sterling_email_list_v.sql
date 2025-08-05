-- liquibase formatted sql
-- changeset SAMQA:1754373945127 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.sterling_email_list_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.sterling_email_list_v.sql:null:7033c228dd81318f1d98f163d9a6f140cb5b4cbe:create

grant select on samqa.sterling_email_list_v to rl_sam1_ro;

grant select on samqa.sterling_email_list_v to rl_sam_rw;

grant select on samqa.sterling_email_list_v to rl_sam_ro;

grant select on samqa.sterling_email_list_v to sgali;

