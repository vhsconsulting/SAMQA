-- liquibase formatted sql
-- changeset SAMQA:1754373930504 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\cobra_disbursement_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/cobra_disbursement_detail.sql:null:5b77cd3da68923241368369ac60b625169c0aefd:create

create index samqa.cobra_disbursement_detail on
    samqa.cobra_disbursement_detail (
        cobra_disbursement_id
    );

