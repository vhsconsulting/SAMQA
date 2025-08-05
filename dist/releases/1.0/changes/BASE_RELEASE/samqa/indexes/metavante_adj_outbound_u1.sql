-- liquibase formatted sql
-- changeset SAMQA:1754373932017 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_adj_outbound_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_adj_outbound_u1.sql:null:fae3c2947b46318005da842068feba873683e3ba:create

create index samqa.metavante_adj_outbound_u1 on
    samqa.metavante_adjustment_outbound (
        change_num
    );

