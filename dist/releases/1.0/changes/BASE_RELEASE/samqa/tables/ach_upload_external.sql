-- liquibase formatted sql
-- changeset SAMQA:1754374151196 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ach_upload_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ach_upload_external.sql:null:4932a70261f18894d200c7012e2ee089f254b4f6:create

create table samqa.ach_upload_external (
    tpa_id              varchar2(100 byte),
    group_name          varchar2(100 byte),
    group_id            varchar2(100 byte),
    first_name          varchar2(100 byte),
    last_name           varchar2(100 byte),
    ssn                 varchar2(100 byte),
    contribution_reason varchar2(100 byte),
    er_amount           varchar2(100 byte),
    ee_amount           varchar2(100 byte),
    er_fee_amount       varchar2(100 byte),
    ee_fee_amount       varchar2(100 byte),
    total_amount        varchar2(100 byte),
    bank_name           varchar2(100 byte),
    bank_routing_num    varchar2(100 byte),
    bank_acct_num       varchar2(100 byte),
    account_type        varchar2(10 byte),
    acc_num             varchar2(100 byte),
    transaction_date    varchar2(30 byte),
    pay_code            varchar2(30 byte),
    plan_type           varchar2(30 byte),
    invoice_id          varchar2(30 byte),
    note                varchar2(3200 byte)
)
organization external ( type oracle_loader
    default directory bank_serv_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'ach_upload.bad'
            logfile 'ach_upload.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null reject rows with all null fields
    ) location ( bank_serv_dir : '2025-04-25IntelligentBrandsInc_HSA_Contribution_W_04252025.csv' )
) reject limit 0;

