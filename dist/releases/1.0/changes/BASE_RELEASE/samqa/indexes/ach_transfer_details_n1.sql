-- liquibase formatted sql
-- changeset SAMQA:1754373928860 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_transfer_details_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_transfer_details_n1.sql:null:573f8db80825441581fd6c7e3f24e57e530159c3:create

create index samqa.ach_transfer_details_n1 on
    samqa.ach_transfer_details (
        transaction_id,
        group_acc_id
    );

