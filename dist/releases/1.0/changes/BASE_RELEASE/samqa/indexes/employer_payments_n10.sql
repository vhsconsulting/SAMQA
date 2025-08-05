-- liquibase formatted sql
-- changeset SAMQA:1754373931136 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_n10.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_n10.sql:null:f643a4cbab77fdb70be20b2446d75619312c46d9:create

create index samqa.employer_payments_n10 on
    samqa.employer_payments (
        entrp_id,
        check_number
    );

