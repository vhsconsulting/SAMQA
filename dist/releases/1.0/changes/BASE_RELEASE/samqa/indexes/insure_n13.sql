-- liquibase formatted sql
-- changeset SAMQA:1754373931751 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\insure_n13.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/insure_n13.sql:null:9bdb9f67263e962ca14e91e3496f441f37981ec8:create

create index samqa.insure_n13 on
    samqa.insure (
        insurance_member_id
    );

