-- liquibase formatted sql
-- changeset SAMQA:1754373931906 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enroll_dependant_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enroll_dependant_n2.sql:null:d521b018eacf6cd54bd57a705949a1eba60fe719:create

create index samqa.mass_enroll_dependant_n2 on
    samqa.mass_enroll_dependant (
        subscriber_ssn
    );

