-- liquibase formatted sql
-- changeset SAMQA:1754373931994 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\medicare_pers_record_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/medicare_pers_record_n1.sql:null:c1b33a4e2df07e710583e71f5bd358242aca5889:create

create index samqa.medicare_pers_record_n1 on
    samqa.medicare_pers_record (
        pers_id
    );

