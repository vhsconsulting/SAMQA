-- liquibase formatted sql
-- changeset SAMQA:1754373928877 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_transfer_details_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_transfer_details_n3.sql:null:a18d3d0696f04ac49b3e632bacc75a35b3ed8117:create

create index samqa.ach_transfer_details_n3 on
    samqa.ach_transfer_details (
        transaction_id,
        group_acc_id,
        acc_id
    );

