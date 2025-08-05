-- liquibase formatted sql
-- changeset SAMQA:1754373933546 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\update_id_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/update_id_pk.sql:null:d74474e19c10c6bfd9ab7d572602c5c5ad8c6c03:create

create unique index samqa.update_id_pk on
    samqa.debit_card_updates (
        update_id
    );

