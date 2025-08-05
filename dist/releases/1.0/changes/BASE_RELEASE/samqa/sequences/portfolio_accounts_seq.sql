-- liquibase formatted sql
-- changeset SAMQA:1754374149747 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\portfolio_accounts_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/portfolio_accounts_seq.sql:null:ed9c719428c2c47ef5451e220ff52cbf517fbc56:create

create sequence samqa.portfolio_accounts_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 36601 cache 20
noorder nocycle nokeep noscale global;

