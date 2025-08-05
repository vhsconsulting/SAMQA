-- liquibase formatted sql
-- changeset SAMQA:1754373928772 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_n3.sql:null:a78acb6ff8d2dc00d00c7ea5d65ecb669d765f38:create

create index samqa.account_n3 on
    samqa.account (
        bps_acc_num
    );

