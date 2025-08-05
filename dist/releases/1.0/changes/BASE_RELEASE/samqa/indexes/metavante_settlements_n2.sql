-- liquibase formatted sql
-- changeset SAMQA:1754373932229 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_settlements_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_settlements_n2.sql:null:f18d297911f097223d9d18041002eea9f1fb11df:create

create index samqa.metavante_settlements_n2 on
    samqa.metavante_settlements (
        acc_num,
        acc_id
    );

