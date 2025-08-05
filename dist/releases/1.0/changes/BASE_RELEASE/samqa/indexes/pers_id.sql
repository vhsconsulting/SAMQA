-- liquibase formatted sql
-- changeset SAMQA:1754373932837 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pers_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pers_id.sql:null:cddbe1eca88179fa5bdf09f73c38c2cf7e8405e6:create

create index samqa.pers_id on
    samqa.debit_card_updates (
        pers_id
    );

