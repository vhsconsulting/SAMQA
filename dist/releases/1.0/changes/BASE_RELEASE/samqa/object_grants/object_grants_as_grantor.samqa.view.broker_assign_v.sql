-- liquibase formatted sql
-- changeset SAMQA:1754373943071 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_assign_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_assign_v.sql:null:a782dc54151fc71fc2eae88078c016e1d81ec2f8:create

grant select on samqa.broker_assign_v to rl_sam1_ro;

grant select on samqa.broker_assign_v to rl_sam_rw;

grant select on samqa.broker_assign_v to rl_sam_ro;

grant select on samqa.broker_assign_v to sgali;

