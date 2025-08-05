-- liquibase formatted sql
-- changeset SAMQA:1754374161770 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\page_validity.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/page_validity.sql:null:04909172d16ebf201d538f0fa036414e5d363e83:create

create table samqa.page_validity (
    batch_number     number,
    entrp_id         number,
    page_no          varchar2(10 byte),
    block_name       varchar2(100 byte),
    validity         varchar2(1 byte),
    account_type     varchar2(100 byte),
    created_by       number,
    creation_date    date,
    last_updated_by  number,
    last_update_date date
);

