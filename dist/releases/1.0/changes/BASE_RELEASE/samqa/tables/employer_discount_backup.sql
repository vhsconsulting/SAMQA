-- liquibase formatted sql
-- changeset SAMQA:1754374156040 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_discount_backup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_discount_backup.sql:null:7c9d447393ebbacb05661db1f15a6e7562b6cff1:create

create table samqa.employer_discount_backup (
    acc_id             number,
    imp_year           varchar2(4 byte),
    ongoing_renewal    varchar2(4 byte),
    discount_exp_date  date,
    setup_fee          number,
    renewal_fee        number,
    monthly_fee_maint  number,
    option_service_fee number,
    pppm_fee           number,
    discount_reason    varchar2(4000 byte),
    note               varchar2(4000 byte)
);

