-- liquibase formatted sql
-- changeset SAMQA:1754373930782 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deposit_register_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deposit_register_n1.sql:null:94121b4a465209b51c8c3eaf963c3dd531859648:create

create index samqa.deposit_register_n1 on
    samqa.deposit_register (
        acc_id
    );

