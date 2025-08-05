-- liquibase formatted sql
-- changeset SAMQA:1754374155756 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eb_acct_updates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eb_acct_updates.sql:null:8d5bc0f47fa2b79e19b6deaa623c691ccb898dbf:create

create table samqa.eb_acct_updates (
    pers_id number(9, 0) not null enable,
    acc_num varchar2(20 byte)
);

