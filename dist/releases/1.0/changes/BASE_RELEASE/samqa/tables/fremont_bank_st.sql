-- liquibase formatted sql
-- changeset SAMQA:1754374158758 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\fremont_bank_st.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/fremont_bank_st.sql:null:dfed48623eed8a75d9ebc48845f38e3d0aaed798:create

create table samqa.fremont_bank_st (
    acc_id        number,
    pay_type      number,
    amount        number,
    creation_date date
);

