-- liquibase formatted sql
-- changeset SAMQA:1754373930529 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\cobra_interface_error_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/cobra_interface_error_n2.sql:null:5770db4fffcc38766d8435d107aa423d553a46af:create

create index samqa.cobra_interface_error_n2 on
    samqa.cobra_interface_error (
        entity_id
    );

