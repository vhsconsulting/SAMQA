-- liquibase formatted sql
-- changeset SAMQA:1754373930790 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deposit_register_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deposit_register_n2.sql:null:d551c18561e7c0def7c7fcf82fd5c97becd9768e:create

create index samqa.deposit_register_n2 on
    samqa.deposit_register (
        check_number
    );

