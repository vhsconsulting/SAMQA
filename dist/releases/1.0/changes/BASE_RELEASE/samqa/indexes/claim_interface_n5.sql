-- liquibase formatted sql
-- changeset SAMQA:1754373930300 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claim_interface_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claim_interface_n5.sql:null:572297fa649adab557230f0660cae2f0d56c4be1:create

create index samqa.claim_interface_n5 on
    samqa.claim_interface (
        acc_num
    );

