-- liquibase formatted sql
-- changeset SAMQA:1754373931252 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enrollment_edi_detail_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enrollment_edi_detail_n1.sql:null:d1f0356d2d8da14fcdf52b6cd978569b5fc1a928:create

create index samqa.enrollment_edi_detail_n1 on
    samqa.enrollment_edi_detail (
        subscriber_number
    );

