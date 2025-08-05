-- liquibase formatted sql
-- changeset SAMQA:1754374156222 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_online_product_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_online_product_staging.sql:null:768a6a8d1beb391608e82317137778683b9c5289:create

create table samqa.employer_online_product_staging (
    enrollment_id    number,
    batch_number     number,
    ein              varchar2(20 byte),
    entrp_id         number(9, 0),
    account_type     varchar2(30 byte),
    acc_num          varchar2(20 byte),
    plan_code        number,
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

