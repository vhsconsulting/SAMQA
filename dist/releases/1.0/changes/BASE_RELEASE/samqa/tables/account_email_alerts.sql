-- liquibase formatted sql
-- changeset SAMQA:1754374150928 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\account_email_alerts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/account_email_alerts.sql:null:9a9246fedd560470ec6af7c558fe6fabb349dcc8:create

create table samqa.account_email_alerts (
    acc_id            number,
    over_contribution varchar2(1 byte) default 'N',
    suspension        varchar2(1 byte) default 'N'
);

