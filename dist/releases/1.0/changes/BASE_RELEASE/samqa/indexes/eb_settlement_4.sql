-- liquibase formatted sql
-- changeset SAMQA:1754373930869 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\eb_settlement_4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/eb_settlement_4.sql:null:77999e9ff55117fc2bd32141aefedb791b4c23e5:create

create index samqa.eb_settlement_4 on
    samqa.eb_settlement (
        acc_id
    );

