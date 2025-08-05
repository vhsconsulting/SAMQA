-- liquibase formatted sql
-- changeset SAMQA:1754373931871 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\item_class_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/item_class_u1.sql:null:e9889a565e222b660f81acb8b915245a16d2d9d6:create

create unique index samqa.item_class_u1 on
    samqa.item_class (
        item_class_code
    );

