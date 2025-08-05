-- liquibase formatted sql
-- changeset SAMQA:1754373931720 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\index2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/index2.sql:null:0ad7d528bb7bb1ee9a4086cebfe16a3fee11db90:create

create index samqa.index2 on
    samqa.crm_interfaces (
        entity_name,
        entity_id
    );

