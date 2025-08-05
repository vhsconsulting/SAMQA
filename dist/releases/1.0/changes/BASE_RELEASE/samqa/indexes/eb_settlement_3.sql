-- liquibase formatted sql
-- changeset SAMQA:1754373930862 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\eb_settlement_3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/eb_settlement_3.sql:null:35b67b1d6650ada5edd315d7e91070447a03b37e:create

create index samqa.eb_settlement_3 on
    samqa.eb_settlement (
        pers_id
    );

