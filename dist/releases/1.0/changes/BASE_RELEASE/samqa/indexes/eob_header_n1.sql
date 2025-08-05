-- liquibase formatted sql
-- changeset SAMQA:1754373931387 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\eob_header_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/eob_header_n1.sql:null:9f5321e7c056bd991c17d1ce2a17daf3552b95c8:create

create index samqa.eob_header_n1 on
    samqa.eob_header (
        user_id
    );

