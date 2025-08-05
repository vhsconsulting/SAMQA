-- liquibase formatted sql
-- changeset SAMQA:1754373944192 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.funding_option.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.funding_option.sql:null:07b001d859a1542b1f28728896c42bdb19bb0c3b:create

grant select on samqa.funding_option to rl_sam1_ro;

grant select on samqa.funding_option to rl_sam_rw;

grant select on samqa.funding_option to rl_sam_ro;

grant select on samqa.funding_option to sgali;

