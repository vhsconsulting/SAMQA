-- liquibase formatted sql
-- changeset SAMQA:1754373931549 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\gp_ap_ar_txn_outbnd_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/gp_ap_ar_txn_outbnd_n1.sql:null:08cc31f3047ccfa934f9f188b4746313a4dde6e5:create

create index samqa.gp_ap_ar_txn_outbnd_n1 on
    samqa.gp_ap_ar_txn_outbnd (
        entity_id,
        entity_type
    );

