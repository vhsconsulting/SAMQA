-- liquibase formatted sql
-- changeset SAMQA:1754373932830 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pers_acc_numc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pers_acc_numc.sql:null:653542053c159b7a060754ca1f5dac6e3e621cee:create

create index samqa.pers_acc_numc on
    samqa.person (
        acc_numc
    );

