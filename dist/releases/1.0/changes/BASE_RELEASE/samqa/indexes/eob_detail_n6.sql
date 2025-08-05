-- liquibase formatted sql
-- changeset SAMQA:1754373931379 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\eob_detail_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/eob_detail_n6.sql:null:463ce4e8a90f51c333855036dae1d7a0a02c2b99:create

create index samqa.eob_detail_n6 on
    samqa.eob_detail (
        eob_id
    );

