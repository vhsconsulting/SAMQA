-- liquibase formatted sql
-- changeset SAMQA:1754373931615 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\income_acc_fk_i.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/income_acc_fk_i.sql:null:47b0df992af10634662f1696bb87e55c8c13fe69:create

create index samqa.income_acc_fk_i on
    samqa.income (
        acc_id
    );

