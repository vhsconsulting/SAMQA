-- liquibase formatted sql
-- changeset SAMQA:1754373932009 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_adj_outbound_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_adj_outbound_n2.sql:null:d3262f56b11bc62d54618ecba5ccded239d47acf:create

create index samqa.metavante_adj_outbound_n2 on
    samqa.metavante_adjustment_outbound (
        acc_id
    );

