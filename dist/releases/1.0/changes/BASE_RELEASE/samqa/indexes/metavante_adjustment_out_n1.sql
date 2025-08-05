-- liquibase formatted sql
-- changeset SAMQA:1754373932026 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_adjustment_out_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_adjustment_out_n1.sql:null:a803a34b31e48935cf692b8af09ad3c5119b033e:create

create index samqa.metavante_adjustment_out_n1 on
    samqa.metavante_adjustment_outbound ( to_char(change_num) );

