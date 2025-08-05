-- liquibase formatted sql
-- changeset SAMQA:1754373930692 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\crm_interfaces_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/crm_interfaces_n2.sql:null:8267b29d2aa1f9e4e27d6527579894432ceffa32:create

create index samqa.crm_interfaces_n2 on
    samqa.crm_interfaces (
        entity_id
    );

