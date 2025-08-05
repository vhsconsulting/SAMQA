-- liquibase formatted sql
-- changeset SAMQA:1754374156081 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_discount_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_discount_staging.sql:null:26ead078d00a0613d6cf3c67de21613e15cc0519:create

create table samqa.employer_discount_staging (
    acc_id                       number,
    discount_type                varchar2(40 byte),
    imp_year                     varchar2(30 byte),
    ongoing_renewal              varchar2(30 byte),
    discount_start_date          varchar2(15 byte),
    discount_exp_date            varchar2(15 byte),
    renewal_fee                  varchar2(100 byte),
    renewal_fee_calc_type        varchar2(30 byte),
    option_service_fee           varchar2(100 byte),
    option_service_fee_calc_type varchar2(30 byte),
    discount_reason              varchar2(100 byte),
    note                         varchar2(4000 byte),
    creation_date                date,
    created_by                   number,
    last_update_date             date,
    last_updated_by              number,
    batch_number                 number,
    acc_num                      varchar2(30 byte),
    process_status               varchar2(1 byte),
    error_message                varchar2(4000 byte),
    error_column                 varchar2(30 byte),
    error_value                  varchar2(100 byte),
    discount_rec_no              number
);

