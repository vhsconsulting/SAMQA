-- liquibase formatted sql
-- changeset SAMQA:1754374153617 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cnb_check_payer_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cnb_check_payer_detail.sql:null:4b35da664237916e5850a75ee166b470505bab39:create

create table samqa.cnb_check_payer_detail (
    account_type      varchar2(30 byte),
    payer_name        varchar2(16 byte),
    payer_acct_id     varchar2(9 byte),
    payer_acct_type   varchar2(3 byte),
    payer_bank_id     varchar2(9 byte),
    payer_bankid_type varchar2(3 byte)
);

