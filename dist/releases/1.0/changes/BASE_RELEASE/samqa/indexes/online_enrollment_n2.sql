-- liquibase formatted sql
-- changeset SAMQA:1754373932416 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_enrollment_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_enrollment_n2.sql:null:7ec2bd559cd0edf2bd36c1977fd4066a89f41bce:create

create index samqa.online_enrollment_n2 on
    samqa.online_enrollment (
        ssn
    );

