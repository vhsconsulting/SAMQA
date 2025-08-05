-- liquibase formatted sql
-- changeset SAMQA:1754373931486 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\external_files_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/external_files_u1.sql:null:c0eadca62a49d68e79900d2089fbfdc79401ccf0:create

create index samqa.external_files_u1 on
    samqa.external_files (
        file_id
    );

