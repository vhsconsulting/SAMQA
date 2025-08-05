-- liquibase formatted sql
-- changeset SAMQA:1754373944810 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.pay_source.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.pay_source.sql:null:74a9a80a22346c066d7689b8bf5941b5d92c69be:create

grant select on samqa.pay_source to rl_sam1_ro;

grant select on samqa.pay_source to rl_sam_rw;

grant select on samqa.pay_source to rl_sam_ro;

grant select on samqa.pay_source to sgali;

