-- liquibase formatted sql
-- changeset SAMQA:1754373932203 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_outbound_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_outbound_u1.sql:null:7aab74adf828a350cb284078e36d94cd7985e152:create

create unique index samqa.metavante_outbound_u1 on
    samqa.metavante_outbound (
        pers_id,
        action
    );

