-- liquibase formatted sql
-- changeset SAMQA:1754374163890 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\user_bank_acct_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/user_bank_acct_staging.sql:null:56e0c622699b53668fc4cd45bd0929839f56e564:create

create table samqa.user_bank_acct_staging (
    user_bank_acct_stg_id  number,
    entrp_id               number,
    batch_number           number,
    account_type           varchar2(50 byte),
    acct_usage             varchar2(50 byte),
    display_name           varchar2(255 byte),
    bank_acct_type         varchar2(15 byte),
    bank_routing_num       varchar2(9 byte),
    bank_acct_num          varchar2(20 byte),
    bank_name              varchar2(255 byte),
    validity               varchar2(1 byte) not null enable,
    last_updated_by        number,
    created_by             number,
    creation_date          date,
    last_update_date       date,
    bank_authorize         varchar2(1 byte),
    acc_num                varchar2(20 byte),
    acc_id                 number,
    error_status           varchar2(1 byte),
    error_message          varchar2(3000 byte),
    enrollment_source      varchar2(255 byte),
    renewed_by             varchar2(20 byte),
    business_name          varchar2(500 byte),
    giac_response          varchar2(1000 byte),
    giac_verify            varchar2(5 byte),
    giac_authenticate      varchar2(500 byte),
    bank_acct_verified     varchar2(1 byte),
    bank_status            varchar2(5 byte),
    giac_verified_response varchar2(1 byte),
    bank_acct_id           number,
    annual_optional_remit  varchar2(10 byte),
    bank_details           clob,
    website_api_request_id number,
    processed_flag         varchar2(1 byte)
);

alter table samqa.user_bank_acct_staging add primary key ( user_bank_acct_stg_id )
    using index enable;

