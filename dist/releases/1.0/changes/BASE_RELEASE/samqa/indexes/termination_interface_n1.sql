-- liquibase formatted sql
-- changeset SAMQA:1754373933546 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\termination_interface_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/termination_interface_n1.sql:null:c146989d718237682053b88bd4c7240b40c89c60:create

create index samqa.termination_interface_n1 on
    samqa.termination_interface (
        ssn
    );

