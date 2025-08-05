-- liquibase formatted sql
-- changeset SAMQA:1754373932928 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\person_n8.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/person_n8.sql:null:7d85ec95f4903bc268934ee54282516cb3323ecd:create

create index samqa.person_n8 on
    samqa.person ( reverse(acc_numc) );

