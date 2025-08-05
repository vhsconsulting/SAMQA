-- liquibase formatted sql
-- changeset SAMQA:1754373931762 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\insure_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/insure_n3.sql:null:434c92decff8e19c094ff238db68f729230c4710:create

create index samqa.insure_n3 on
    samqa.insure (
        insur_id
    );

