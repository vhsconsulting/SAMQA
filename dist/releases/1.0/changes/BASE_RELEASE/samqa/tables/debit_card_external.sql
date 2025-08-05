-- liquibase formatted sql
-- changeset SAMQA:1754374154506 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\debit_card_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/debit_card_external.sql:null:9082527222444857b96da9a864ca872d84fe6de7:create

create table samqa.debit_card_external (
    line number,
    txt  varchar2(4000 byte)
);

