-- liquibase formatted sql
-- changeset SAMQA:1754373938150 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.portfolio_accounts_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.portfolio_accounts_seq.sql:null:d159ed3c2c0d6340e48dc0bf909ffd402b7cbb9a:create

grant select on samqa.portfolio_accounts_seq to rl_sam_rw;

