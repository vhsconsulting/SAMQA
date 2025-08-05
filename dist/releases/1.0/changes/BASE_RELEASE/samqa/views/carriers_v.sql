-- liquibase formatted sql
-- changeset SAMQA:1754374169675 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\carriers_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/carriers_v.sql:null:576738f4fef42b5f9694539ab5d756ec8a4dbb37:create

create or replace force editionable view samqa.carriers_v (
    carrier_id,
    carrier_name
) as
    select
        entrp_id carrier_id,
        name     carrier_name
    from
        enterprise
    where
        en_code = 3;

