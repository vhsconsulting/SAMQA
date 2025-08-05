-- liquibase formatted sql
-- changeset SAMQA:1754374163767 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ticker_setup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ticker_setup.sql:null:404e36ad7830603fa15038c03c8669923bbcbe2d:create

create table samqa.ticker_setup (
    label_name   varchar2(100 byte),
    account_type varchar2(30 byte),
    target_page  number,
    setup_query  varchar2(2000 byte),
    entity_type  char(1 byte),
    seq_no       number
);

