-- liquibase formatted sql
-- changeset SAMQA:1754373933152 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\receivable_details_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/receivable_details_n2.sql:null:7b0c20e39b57e5333347f615c660d3ffe6e031b9:create

create index samqa.receivable_details_n2 on
    samqa.receivable_details (
        group_acc_id
    );

