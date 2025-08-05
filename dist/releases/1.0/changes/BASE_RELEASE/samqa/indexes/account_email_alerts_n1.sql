-- liquibase formatted sql
-- changeset SAMQA:1754373928740 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\account_email_alerts_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/account_email_alerts_n1.sql:null:1e9c058f95073ef1624709b47511c6cce54dee66:create

create index samqa.account_email_alerts_n1 on
    samqa.account_email_alerts (
        acc_id
    );

