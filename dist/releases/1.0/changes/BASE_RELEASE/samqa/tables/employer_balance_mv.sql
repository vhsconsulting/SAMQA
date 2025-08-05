-- liquibase formatted sql
-- changeset SAMQA:1754374155987 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_balance_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_balance_mv.sql:null:15713e1b658b97deb51b124f7ef1d21db4660019:create

create table samqa.employer_balance_mv (
    acc_num             varchar2(100 byte),
    er_balance          number,
    claim_reimbursed_by varchar2(100 byte),
    css                 varchar2(100 byte),
    product_type        varchar2(100 byte),
    employer_name       varchar2(1000 byte),
    funding_options     varchar2(100 byte)
);

