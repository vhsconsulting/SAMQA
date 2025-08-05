-- liquibase formatted sql
-- changeset SAMQA:1754373932180 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_errors_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_errors_n5.sql:null:f3dc65906e434f296a495230b86e303d8ff7a59a:create

create index samqa.metavante_errors_n5 on
    samqa.metavante_errors ( trunc(last_update_date) );

