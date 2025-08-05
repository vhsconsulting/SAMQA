-- liquibase formatted sql
-- changeset SAMQA:1754373932507 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_renewals_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_renewals_idx.sql:null:340ceace3b277ccbcdd4110113a4563a6301f148:create

create index samqa.online_renewals_idx on
    samqa.online_renewals (
        creation_date
    );

