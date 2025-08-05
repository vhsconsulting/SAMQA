-- liquibase formatted sql
-- changeset SAMQA:1754373931370 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enterprise_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enterprise_n4.sql:null:0784c2bb0a5407483ac9c18fca8880688c5d82d2:create

create index samqa.enterprise_n4 on
    samqa.enterprise (
        cobra_id_number
    );

