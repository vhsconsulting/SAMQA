-- liquibase formatted sql
-- changeset SAMQA:1754373945402 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.user_bank_acct_ga_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.user_bank_acct_ga_v.sql:null:9b533f0c71f131dac5c89b294bee4635d1ad854f:create

grant select on samqa.user_bank_acct_ga_v to rl_sam_ro;

