-- liquibase formatted sql
-- changeset SAMQA:1754373930774 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\demo_processed_yn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/demo_processed_yn.sql:null:b7ffcef1eacc23fdfc95f1774726183ece362a50:create

create index samqa.demo_processed_yn on
    samqa.debit_card_updates (
        demo_processed
    );

