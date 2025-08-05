-- liquibase formatted sql
-- changeset SAMQA:1754373928851 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\accres_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/accres_n3.sql:null:9014778554b24128d3b6162ba5ce9b4691e80418:create

create index samqa.accres_n3 on
    samqa.accres (
        acc_id
    );

