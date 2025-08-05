-- liquibase formatted sql
-- changeset SAMQA:1754373932522 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_renewals_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_renewals_n2.sql:null:628c775a1776ead89f80e672eb5e53582b9dac1a:create

create index samqa.online_renewals_n2 on
    samqa.online_renewals (
        acc_id
    );

