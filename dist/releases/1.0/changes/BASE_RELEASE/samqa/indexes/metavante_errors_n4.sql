-- liquibase formatted sql
-- changeset SAMQA:1754373932172 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_errors_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_errors_n4.sql:null:65c3eb85c0f9bdc81692926658b5281f1f778e18:create

create index samqa.metavante_errors_n4 on
    samqa.metavante_errors (
        action_code
    );

