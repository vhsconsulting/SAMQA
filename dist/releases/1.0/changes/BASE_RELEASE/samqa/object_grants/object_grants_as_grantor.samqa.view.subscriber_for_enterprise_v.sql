-- liquibase formatted sql
-- changeset SAMQA:1754373945154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_for_enterprise_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_for_enterprise_v.sql:null:ad7d3023e91297dc88516203ca7fb05601d45b1a:create

grant select on samqa.subscriber_for_enterprise_v to rl_sam_rw;

grant select on samqa.subscriber_for_enterprise_v to rl_sam_ro;

grant select on samqa.subscriber_for_enterprise_v to sgali;

grant select on samqa.subscriber_for_enterprise_v to rl_sam1_ro;

