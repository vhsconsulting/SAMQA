-- liquibase formatted sql
-- changeset SAMQA:1754373933530 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\temp_gp_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/temp_gp_n1.sql:null:0e442eb133a74972c39d80daf5cf56e7212359aa:create

create index samqa.temp_gp_n1 on
    samqa.temp_gp (
        acc_num
    );

