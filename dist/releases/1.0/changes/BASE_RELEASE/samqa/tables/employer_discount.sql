-- liquibase formatted sql
-- changeset SAMQA:1754374156026 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_discount.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_discount.sql:null:9582bc90080be1b1f00bb8416eb32758b5b61449:create

create table samqa.employer_discount (
    acc_id                       number,
    discount_type                varchar2(40 byte),
    imp_year                     varchar2(4 byte),
    ongoing_renewal              varchar2(4 byte),
    discount_start_date          date,
    discount_exp_date            date,
    setup_fee                    number,
    setup_fee_calc_type          varchar2(30 byte),
    renewal_fee                  number,
    renewal_fee_calc_type        varchar2(30 byte),
    monthly_fee_maint            number,
    monthly_fee_maint_calc_type  varchar2(30 byte),
    option_service_fee           number,
    option_service_fee_calc_type varchar2(30 byte),
    pppm_fee                     number,
    pppm_fee_calc_type           varchar2(30 byte),
    discount_reason              varchar2(100 byte),
    note                         varchar2(4000 byte),
    creation_date                date,
    created_by                   number,
    last_update_date             date,
    last_updated_by              number,
    discount_rec_no              number,
    batch_number                 number
);

