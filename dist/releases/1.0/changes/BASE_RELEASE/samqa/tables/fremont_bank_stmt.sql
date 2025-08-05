-- liquibase formatted sql
-- changeset SAMQA:1754374158769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\fremont_bank_stmt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/fremont_bank_stmt.sql:null:5102e505a6898afa5dd0487277c5ef3e9b3eef80:create

create table samqa.fremont_bank_stmt (
    acc_id        number,
    pay_type      number,
    amount        number,
    creation_date date,
    claim_id      number
);

