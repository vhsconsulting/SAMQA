-- liquibase formatted sql
-- changeset SAMQA:1754373932244 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_settlements_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_settlements_n4.sql:null:01da9e74c3d5319c233d501b292c23fac73b3164:create

create index samqa.metavante_settlements_n4 on
    samqa.metavante_settlements (
        acc_num
    );

