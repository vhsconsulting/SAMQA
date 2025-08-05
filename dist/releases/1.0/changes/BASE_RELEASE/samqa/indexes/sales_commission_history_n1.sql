-- liquibase formatted sql
-- changeset SAMQA:1754373933241 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sales_commission_history_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sales_commission_history_n1.sql:null:5bc798324d39a47ffa0fea042fc7ea495f3b0439:create

create index samqa.sales_commission_history_n1 on
    samqa.sales_commission_history (
        acc_num
    );

