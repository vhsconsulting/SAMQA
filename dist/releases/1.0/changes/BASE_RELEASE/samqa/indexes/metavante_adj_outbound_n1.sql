-- liquibase formatted sql
-- changeset SAMQA:1754373932001 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_adj_outbound_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_adj_outbound_n1.sql:null:b5ba913becc57d117eba0766709c2aee8fe3da06:create

create index samqa.metavante_adj_outbound_n1 on
    samqa.metavante_adjustment_outbound (
        acc_num
    );

