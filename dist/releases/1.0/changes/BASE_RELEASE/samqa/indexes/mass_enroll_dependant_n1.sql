-- liquibase formatted sql
-- changeset SAMQA:1754373931898 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enroll_dependant_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enroll_dependant_n1.sql:null:02d66da8e623bb71e99fd0c9bbc4c8ad43e1961b:create

create index samqa.mass_enroll_dependant_n1 on
    samqa.mass_enroll_dependant (
        ssn
    );

