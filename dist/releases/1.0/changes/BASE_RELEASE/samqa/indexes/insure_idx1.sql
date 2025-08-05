-- liquibase formatted sql
-- changeset SAMQA:1754373931738 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\insure_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/insure_idx1.sql:null:f35c9fa8a9923ff0e5a0add06bfbb634f474e455:create

create index samqa.insure_idx1 on
    samqa.insure (
        pers_id,
        insur_id
    );

