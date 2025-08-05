-- liquibase formatted sql
-- changeset SAMQA:1754373930365 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_func.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_func.sql:null:5b81f16649681e55ac8b4229735ab5449fdfbfc1:create

create index samqa.claimn_func on
    samqa.claimn ( trunc(approved_date) );

