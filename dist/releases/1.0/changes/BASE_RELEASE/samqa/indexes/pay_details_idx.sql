-- liquibase formatted sql
-- changeset SAMQA:1754373932609 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pay_details_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pay_details_idx.sql:null:011976905c6f977206a9afd28413a052b3955ab3:create

create index samqa.pay_details_idx on
    samqa.pay_details (
        ben_plan_id
    );

