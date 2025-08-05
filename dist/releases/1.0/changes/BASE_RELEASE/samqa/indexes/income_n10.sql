-- liquibase formatted sql
-- changeset SAMQA:1754373931676 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\income_n10.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/income_n10.sql:null:57865f684ab795270a4464f17140df581ccaa7a6:create

create index samqa.income_n10 on
    samqa.income ( nvl(fee_code,(-1)) );

