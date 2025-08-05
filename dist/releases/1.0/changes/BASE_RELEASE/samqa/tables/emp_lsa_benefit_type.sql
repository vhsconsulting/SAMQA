-- liquibase formatted sql
-- changeset SAMQA:1754374155911 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\emp_lsa_benefit_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/emp_lsa_benefit_type.sql:null:1e87e48a56be987700b1d1a00aa708fdd6acc6aa:create

create table samqa.emp_lsa_benefit_type (
    acc_id               number,
    lsa_benefit_type     varchar2(50 byte),
    other_wellness_desc  varchar2(4000 byte),
    other_emot_desc      varchar2(4000 byte),
    other_finance_desc   varchar2(4000 byte),
    custom_desc          varchar2(4000 byte),
    creation_date        date,
    created_by           number,
    last_update_date     date,
    last_updated_by      number,
    lsa_benefit_type_val varchar2(1 byte)
);

