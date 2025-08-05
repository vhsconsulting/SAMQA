-- liquibase formatted sql
-- changeset SAMQA:1754373945237 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_sfo_term_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_sfo_term_v.sql:null:2f90fe9bd7b48937d4eb25197f65dea1bcf7053f:create

grant select on samqa.subscriber_sfo_term_v to rl_sam_rw;

grant select on samqa.subscriber_sfo_term_v to rl_sam_ro;

grant select on samqa.subscriber_sfo_term_v to sgali;

grant select on samqa.subscriber_sfo_term_v to rl_sam1_ro;

