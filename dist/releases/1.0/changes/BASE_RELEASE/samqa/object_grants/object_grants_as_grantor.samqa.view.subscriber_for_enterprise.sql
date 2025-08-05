-- liquibase formatted sql
-- changeset SAMQA:1754373945146 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_for_enterprise.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_for_enterprise.sql:null:1345f67a5d8cfda805dc1f53577c44a50d7991fb:create

grant select on samqa.subscriber_for_enterprise to rl_sam_rw;

grant select on samqa.subscriber_for_enterprise to rl_sam_ro;

grant select on samqa.subscriber_for_enterprise to sgali;

grant select on samqa.subscriber_for_enterprise to rl_sam1_ro;

