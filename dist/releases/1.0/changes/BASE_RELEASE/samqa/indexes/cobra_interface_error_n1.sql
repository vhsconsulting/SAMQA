-- liquibase formatted sql
-- changeset SAMQA:1754373930520 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\cobra_interface_error_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/cobra_interface_error_n1.sql:null:8f5120ceb24a4bc69e6c25f6e22163f3e07b1672:create

create index samqa.cobra_interface_error_n1 on
    samqa.cobra_interface_error (
        entity_type
    );

