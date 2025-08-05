-- liquibase formatted sql
-- changeset SAMQA:1754374177062 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\myhealthplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/myhealthplan.sql:null:f58d7e078b01937c7a058d8d50befe2c5ce883ac:create

create or replace force editionable view samqa.myhealthplan (
    id,
    name,
    entrp_id
) as
    (
        select
            entrp_id as id,
            name,
            entrp_id
        from
            enterprise
        where
            en_code = 3
    );

