-- liquibase formatted sql
-- changeset SAMQA:1754373932515 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_renewals_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_renewals_n1.sql:null:e22ba9c03c6a8576b87e3d2f19476ccf99a922d2:create

create index samqa.online_renewals_n1 on
    samqa.online_renewals (
        entrp_id
    );

