-- liquibase formatted sql
-- changeset SAMQA:1754373933256 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sales_commission_history_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sales_commission_history_n2.sql:null:5aae0227418e2a93ece3fc2f8445ed881a388b38:create

create index samqa.sales_commission_history_n2 on
    samqa.sales_commission_history (
        ga_id
    );

