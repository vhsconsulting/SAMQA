-- liquibase formatted sql
-- changeset SAMQA:1754374151903 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bank_accounts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bank_accounts.sql:null:68c8ae4940c5bb16bfc0d8df7c703c750ab766c7:create

create table samqa.bank_accounts (
    bank_acct_id               number not null enable,
    entity_id                  number not null enable,
    entity_type                varchar2(255 byte) default 'ACCOUNT' not null enable,
    display_name               varchar2(255 byte),
    bank_acct_type             varchar2(2 byte) not null enable,
    bank_routing_num           varchar2(9 byte) not null enable,
    bank_acct_num              varchar2(20 byte) not null enable,
    bank_name                  varchar2(255 byte) not null enable,
    last_updated_by            number,
    created_by                 number,
    last_update_date           date,
    creation_date              date,
    status                     varchar2(1 byte) default 'A',
    bank_account_usage         varchar2(30 byte) default 'ONLINE',
    authorized_by              varchar2(50 byte),
    note                       varchar2(2000 byte),
    inactive_reason            varchar2(30 byte),
    inactive_date              date default null,
    bank_acct_code             varchar2(30 byte) default '22',
        masked_bank_acct_num       varchar2(40 byte) generated always as ( translate(
            substr(bank_acct_num,
                   1,
                   length(bank_acct_num) - 4),
            '1234567890',
            'XXXXXXXXXX'
        )
                                                                     || substr(bank_acct_num,
                                                                               length(bank_acct_num) - 3) ) virtual,
    source                     varchar2(50 byte) default 'WEBSITE',
    giac_response              varchar2(1000 byte),
    giac_authenticate          varchar2(500 byte),
    giac_verify                varchar2(5 byte),
    business_name              varchar2(500 byte),
    bank_acct_verified         varchar2(1 byte),
        giac_bank_account_verified varchar2(1 byte) generated always as ( decode(
            nvl(giac_verify, 'N'),
            'N',
            'N',
            'Y'
        ) ) virtual
);

