-- liquibase formatted sql
-- changeset SAMQA:1754373944745 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.new_list_bill_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.new_list_bill_v.sql:null:2986ec2b1f276000589e832b27c10be50c6552dc:create

grant select on samqa.new_list_bill_v to rl_sam1_ro;

grant select on samqa.new_list_bill_v to rl_sam_rw;

grant select on samqa.new_list_bill_v to rl_sam_ro;

grant select on samqa.new_list_bill_v to sgali;

