-- liquibase formatted sql
-- changeset SAMQA:1754373930002 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\cards_status_gt_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/cards_status_gt_n2.sql:null:1c788fbbc78e5a1257be55c9f216b70235c583f9:create

create index samqa.cards_status_gt_n2 on
    samqa.cards_status_gt (
        card_number
    );

