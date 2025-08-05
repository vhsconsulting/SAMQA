-- liquibase formatted sql
-- changeset SAMQA:1754373932195 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_outbound_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_outbound_n1.sql:null:417e34054cef9a0aa4bf5f229bbd280ea4aa743c:create

create index samqa.metavante_outbound_n1 on
    samqa.metavante_outbound (
        action,
        processed_flag
    );

