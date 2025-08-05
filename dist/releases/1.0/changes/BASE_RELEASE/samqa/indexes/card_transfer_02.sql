-- liquibase formatted sql
-- changeset SAMQA:1754373929988 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\card_transfer_02.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/card_transfer_02.sql:null:be56b08a723bd89a7bbb4f19907281f191547cf3:create

create index samqa.card_transfer_02 on
    samqa.card_transfer (
        transfer_id,
        card_id
    );

